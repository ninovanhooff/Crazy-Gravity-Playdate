class('Options').extends()

local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local itemHeight <const> = 24

--- NOTES Nino
-- KEY_REPEAT and KEY_REPEAT_INITIAL not defined
-- drawRectSwitch unused
-- added fixes to show menu on the right side of the screen

local KEY_REPEAT_INITIAL = 300
local KEY_REPEAT = 200

local toggleVals <const> = {false, true}
local backgroundVals <const> = {"black", "white", "win95"}

local gameOptions = {
    -- name (str): option's display name in menu
    -- key (str): indentifier for the option in the userOptions table
        -- if key is not provided, lowercase name is used as the key
    -- values (table): table of possible values. if boolean table, will draw as toggle switch
    -- default (num): index of value that should be set as default
    -- preview (bool): hide the options menu while the option is changing to more easily preview changes
    -- dirtyRead (bool): if true, a read on this option returns nil if it hasn't changed. useful for event-driven updates
    {
        header = 'Gameplay',
        options = {
            --{name='Tileset', values=TILESETS.names, default=7, preview=true, dirtyRead=true},
            --{name='Background', values=BACKGROUNDS.names, default=11, preview=true, dirtyRead=true},
            {name='Debug', key='debug', values=toggleVals, default=2},
            {name='Background', key='background', values=backgroundVals, default=1, dirtyRead=true},
            {name='Show Tile Count', key='remaining', values=toggleVals, default=2, dirtyRead=true},
            {name='Auto Deselect', key='autodeselect', values=toggleVals, default=2},
        }
    },
    {
        header = 'Audio',
        options = {
            {name='Track', values={'silence in D minor', 'broken speakers', 'earmuff sounds'}, default=1, dirtyRead=true},
            {name='Sound', values=toggleVals, default=2},
            {name='Music', values=toggleVals, default=2}
        }
    },
    {
        header = 'Debug',
        options = {
            {name='Deal Animation', key='animate', values=toggleVals, default=2},
            {name='Deal Style', key='dealstyle', values={'all up', 'all down', 'top layer up'}, default=1},
            {name='Allow Any Matches', key='anymatch', values=toggleVals, default=1},
            {name='Save on Exit', key='save', values=toggleVals, default=2},
            -- {name='To Editor', values=toggleVals, default=1}
        }
    }
}

local editorOptions = {}

function Options:init()
    self.menu = playdate.ui.gridview.new(0, itemHeight)

    -- list of available options based on option screen (indexed by section/row for easy selection)
    self.currentOptions = {}
    -- current values for each option. (indexed by key for easy reads)
    self.userOptions = {}
    self.dirty = false
    self.visible = false 
    self.previewMode = false

    self:menuInit()
    self:userOptionsInit()

    function self.menu.drawCell(menuSelf, section, row, column, selected, x, y, width, height)
        local right <const> = x + width
        local textPadding = 5
        local val = self:getValue(section, row)
        local label = self:getLabel(section, row)
        if self.previewMode and not selected then return end

        gfx.pushContext()
        if selected then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRoundRect(x, y, width, height+textPadding, 4)
            gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        -- draw option
        -- gfx.setFont(font)
        local labelWidth, _ = gfx.getTextSize(label)
        labelWidth = math.min(width, labelWidth) 
        gfx.drawTextInRect(label, x+textPadding, y+textPadding, labelWidth, height, nil, '...', kTextAlignment.left)

        -- draw switch as glyph
        if val ~= 'n/a' and val ~= nil then
            if type(val) == 'boolean' then
                Options.drawRoundSwitch(right - 42, y+textPadding-1, val, selected)
            else
                -- draw value as text
                local optionWidth = right - 8 - (labelWidth+textPadding)
                gfx.drawTextInRect('*'..val, labelWidth+textPadding, y+textPadding, optionWidth, height, nil, '...', kTextAlignment.right)
            end
        end

        gfx.popContext()
    end

    function self.menu.drawSectionHeader(menuSelf, section, x, y, width, height)
        if self.previewMode then return end

        local textPadding = 5
        local text = '*'..self.currentOptions[section].header:upper()..'*'
        gfx.pushContext()
            -- gfx.setImageDrawMode(gfx.kDrawModeCopy)
            gfx.setFont(font)
            gfx.drawTextInRect(text, x+textPadding, y+textPadding, width, height, nil, '...', kTextAlignment.center)
        gfx.popContext()

    end

    self.keyTimer = {}
    self.controls = {
        -- move
        leftButtonDown = function() self:toggleCurrentOption(-1) end,
        rightButtonDown = function() self:toggleCurrentOption(1) end,
        upButtonDown = function()
            self.keyTimer['U'] = timer.keyRepeatTimerWithDelay(KEY_REPEAT_INITIAL, KEY_REPEAT, function() self:selectPreviousRow() end)
        end,
        upButtonUp = function() if self.keyTimer['U'] then self.keyTimer['U']:remove() end end,
        downButtonDown = function()
            self.keyTimer['D'] = timer.keyRepeatTimerWithDelay(KEY_REPEAT_INITIAL, KEY_REPEAT, function() self:selectNextRow() end)
        end,
        downButtonUp = function() if self.keyTimer['D'] then self.keyTimer['D']:remove() end end,
    
        -- action
        AButtonDown = function() self:toggleCurrentOption(1, true) end,
        BButtonDown = function() self:hide() end,
        -- turn with crank
        -- cranked = function(change, acceleratedChange) end,
    }

end

function Options:menuInit()
    self.currentOptions = (self.currentOptions == gameOptions) and editorOptions or gameOptions

    local sectionRows = {}
    local startRow = 0
    for i, section in ipairs(self.currentOptions) do
        if section.header then
            table.insert(sectionRows, #section.options)
        end
    end

    self.menu:setCellPadding(0,0,2,2)
    self.menu:setContentInset(4, 4, 0, 0)
    self.menu:setSectionHeaderHeight(itemHeight)
    self.menu:setSectionHeaderPadding(0, 0, 2, 0)

    self.menu:setNumberOfRows(table.unpack(sectionRows))
    self.menu:setSelectedRow(1)
end

function Options:userOptionsInit()
    local existingOptions = self:loadUserOptions()
    -- TODO add editor options to init
    for _, section in ipairs(gameOptions) do
        for i, option in ipairs(section.options) do 
            local key = option.key or option.name:lower()
            local default = option.default or 1

            if existingOptions and existingOptions[key] ~= nil then
                local val = existingOptions[key]
                if #val == 2 then val[2] = true end
                self.userOptions[key] = val
                if val[1] == true then
                    option.current = 2
                elseif val[1] == false then 
                    option.current = 1
                else
                    option.current = val[1]
                end
                
            else
                local val = {default}
                if type(option.values[1]) == 'boolean' then
                    val = {option.values[default]}
                end
                if option.dirtyRead then
                    val[2] = true
                end

                self.userOptions[key] = val
                option.current = default
            end
            option.key = key
        end
    end
    printTable('Loaded Options\n', self.userOptions)
end

function Options:saveUserOptions()
    playdate.datastore.write(self.userOptions, 'settings')
end

function Options:loadUserOptions()
    return playdate.datastore.read('settings')
end

function Options:show()
    self.visible = true
    self.previewMode = false
    playdate.inputHandlers.push(self.controls, true)
end

--- Prevents drawMenu() from drawing anything
---and saves the values to disk
function Options:hide()
    self.visible = false
    self:saveUserOptions()
    playdate.inputHandlers.pop()
    self:apply()
    self:markClean()
end

--- Game code uses many globals to read options. Set them here based on current values
function Options:apply()
    Debug = self:read("debug")
    local newBG = backgroundVals[self:read("background")]
    print("newBg", newBG)
    if newBG then
        printf("Changing background to ", newBG)
        if newBG == "white" then
            gameBgColor = gfx.kColorWhite
        elseif newBG == "win95" then
            gameBgColor = gfx.kColorClear
        else
            gameBgColor = gfx.kColorBlack
        end
        if bricksView then
            bricksView = BricksView()
        end
    end
end

-- Returns the option at the given section and row, or the currently selected option if no args
function Options:getSelectedOption(section, row)
    local selectedSection, selectedRow, selectedCol = self.menu:getSelection()
    section = section or selectedSection
    row = row or selectedRow
    return self.currentOptions[section].options[row]
end

function Options:getLabel(section, row)
    local active <const> = self:getValue(section, row) == nil 
    local bold <const> = active and '' or '*'
    gfx.setFontTracking(0)
    return bold..self:getSelectedOption(section, row).name:lower()
end

function Options:getValue(section, row)
    local option = self:getSelectedOption(section, row) 
    return option.values[option.current]
end

function Options:read(key, ignoreDirty)
    local opt = self.userOptions[key]
    if opt == nil then return opt end
    if #opt == 2 and not ignoreDirty then
        if opt[2] then 
            opt[2] = false
            return opt[1]
        end
    else
        if opt[2] then
            opt[2] = false
        end
        return opt[1]
    end
end

function Options:isDirty()
    return self.dirty
end

function Options:markDirty()
    self.dirty = true
end

function Options:markClean()
    self.dirty = false
end

function Options:toggleCurrentOption(incr, forceWrap)
    incr = incr or 1

    local option = self:getSelectedOption()
    local key =  option.key
    local values = option.values
    local currentIdx = option.current  or option.default
    -- pick new option by wrapping around all values
    local newIdx = 1 + (currentIdx+incr-1) % #values
    self.userOptions[key] = {newIdx}
    -- boolean toggles should not wrap
    if type(values[1]) == 'boolean' then
        if not forceWrap then
            newIdx = incr == -1 and 1 or 2
        end
        self.userOptions[key] = {values[newIdx]}
    end


    -- add dirty flag for this option
    if option.dirtyRead then
        self.userOptions[key][2] = newIdx ~= currentIdx
    end

    -- mark entire object dirty
    if newIdx ~= currentIdx then 
        self:markDirty() 
        if option.preview then
            self.previewMode = true
        end
    end

    option.current = newIdx
end

function Options:onCurrentOption()
    local row <const> = self:getCurrentRow()

    if self:getValue(row) == false then
        self:toggleCurrentOption()
    end
end

function Options:offCurrentOption()
    local row <const> = self:getCurrentRow()

    if self:getValue(row) == true then
        self:toggleCurrentOption()
    end
end

function Options:drawMenu()
    if not self.visible then return end

    local w <const> = 200	--198
    local h <const> = 240
    local x <const> = 200
    local y <const> = 0

    gfx.pushContext()

    if not self.previewMode then
        -- draw background
        gfx.setColor(gfx.kColorWhite)
        -- gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.fillRect(x, y, w, h)

        -- draw divider
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(200,0,2,240)	-- divider
    end

    self.menu:drawInRect(x, y, w, h)

    gfx.popContext()
end

function Options:selectPreviousRow()
    self.previewMode = false
    self.menu:selectPreviousRow(true)
end

function Options:selectNextRow()
    self.previewMode = false
    self.menu:selectNextRow(true)
end

--------- STATIC METHODS ---------
function Options.drawRectSwitch(y, val, selected)
    local x <const> = 158
    local y <const> = y

    local r <const> = 5
    local rx <const> = x+9
    local ry <const> = y+7
    local rw <const> = 20
    local rh <const> = r*2

    local cxoff <const> = x+9
    local cxon <const> = x+rw
    local cy <const> = y+7

    gfx.pushContext()
    gfx.setLineWidth(2)
    gfx.setColor(selected and gfx.kColorWhite or gfx.kColorBlack)

    if val then
        gfx.setDitherPattern(0.5)
        gfx.fillRect(rx,ry,rw,rh)

        gfx.setColor(selected and gfx.kColorWhite or gfx.kColorBlack)
        gfx.drawRect(rx,ry,rw,rh)
        gfx.fillRect(cxon,cy,(r*2)-1,rh)
        -- gfx.drawRect(cxon,cy-3,1,6)
    else
        gfx.drawRect(rx,ry,rw,rh)
        gfx.fillRect(cxoff,cy,r*2+1,rh)
        -- gfx.setColor(f and gfx.kColorBlack or gfx.kColorWhite)
        -- gfx.fillRect(cxoff+1,cy+1,(r*2)-2,rh-2)
    end

    gfx.popContext()
end

function Options.drawRoundSwitch(x, y, val, selected)
    local y <const> = y+8

    local r <const> = 6
    local rx <const> = x+9
    local ry <const> = y-5
    local rw <const> = 24
    local rh <const> = r*2+2

    local cxoff <const> = x+16
    local cxon <const> = x+rw+2
    local cy <const> = y+2

    gfx.pushContext()
    gfx.setLineWidth(2)

    gfx.setColor(selected and gfx.kColorWhite or gfx.kColorBlack)

    if val then
        gfx.setDitherPattern(0.5)
        gfx.fillRoundRect(rx,ry,rw,rh, r)

        gfx.setColor(selected and gfx.kColorWhite or gfx.kColorBlack)
        gfx.drawRoundRect(rx,ry,rw,rh, r)
        gfx.fillCircleAtPoint(cxon,cy,r+2)
        -- gfx.drawRect(cxon,cy-3,1,6)
    else
        gfx.drawRoundRect(rx,ry,rw,rh, r)
        gfx.drawCircleAtPoint(cxoff,cy,r+1)
        gfx.setColor(selected and gfx.kColorBlack or gfx.kColorWhite)
        gfx.fillCircleAtPoint(cxoff,cy,r)
    end

    gfx.popContext()
end
