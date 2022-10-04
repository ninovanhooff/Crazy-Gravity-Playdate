import "CoreLibs/object"
import "CoreLibs/ui"
import "../input/InputManager.lua"
import "ResourceLoader"

class('Options').extends()

local playdate <const> = playdate
local gfx <const> = playdate.graphics
local timer <const> = playdate.timer
local itemHeight <const> = 28
local resourceLoader <const> = ResourceLoader()

--- NOTES Nino
-- KEY_REPEAT and KEY_REPEAT_INITIAL not defined
-- drawRectSwitch is unused
-- added fixes to show menu on arbitrary x position
-- added missing imports CoreLibs/object and ui
-- added Options.super.init()

local KEY_REPEAT_INITIAL = 300
local KEY_REPEAT = 200

local displayWidth <const> = playdate.display.getWidth()

local toggleVals <const> = {false, true}
local STYLE_VALS <const> = { "playdate", "classic"}
local DEBUG_KEY <const> = "debug"
local BG_KEY <const> = "background"
local BG_VALS <const> = { "black", "white", "win95"}
local GRAPHICS_STYLE_KEY <const> = "graphicsStyle"
local PATTERN_KEY <const> = "brickPattern"
local PATTERN_VALS <const> = {"lighter", "light", "dark", "darker", "white", "default"}
local INVERT_KEY <const> = "invertDisplay"
local SPEED_KEY <const> = "gameFps"
local SPEED_VALS <const> = {15, 20, 25, 30, 0}
local ROTATION_DELAY_KEY <const> = "rotationDelay"
local ROTATION_DELAY_VALS <const> = {
    {label="Slow", value = 2},
    {label="Medium", value = 1},
    {label="Fast", value = 0}
 }
local AUDIO_STYLE_KEY <const> = "audioStyle"
local AUDIO_VOLUME_KEY <const> = "audioVolume"
local AUDIO_VOLUME_VALS <const> = { "off", 10, 20, 30, 40 , 50 , 60 , 70, 80, 90, 100 }
local MUSIC_VOLUME_KEY <const> = "musicVolume"

local BUTTON_VALS <const> = {
    {label="_⬆_️", keys = playdate.kButtonUp},
    {label="_️⬇_", keys = playdate.kButtonDown},
    {label="_️⬅_", keys = playdate.kButtonLeft},
    {label="_➡_", keys = playdate.kButtonRight},
    {label="_️Ⓐ_", keys = playdate.kButtonA},
    {label="_Ⓑ_", keys = playdate.kButtonB},
    {label="_⬆,Ⓐ_", keys = playdate.kButtonUp + playdate.kButtonA},
    {label="_⬆,Ⓑ_", keys = playdate.kButtonUp + playdate.kButtonB},
    {label="_️⬇,Ⓐ_", keys = playdate.kButtonDown + playdate.kButtonA},
    {label="_️⬇,Ⓑ_", keys = playdate.kButtonDown + playdate.kButtonB},
    {label="_⬅,Ⓐ_", keys = playdate.kButtonLeft + playdate.kButtonA},
    {label="_⬅,Ⓑ_", keys = playdate.kButtonLeft + playdate.kButtonB},
    {label="_️➡,Ⓐ_", keys = playdate.kButtonRight + playdate.kButtonA},
    {label="_️➡,Ⓑ_", keys = playdate.kButtonRight + playdate.kButtonB}
}
local TURN_LEFT_KEY <const> = "turnLeftMapping"
local TURN_RIGHT_KEY <const> = "turnRightMapping"
local THROTTLE_KEY <const> = "throttleMapping"
local SELF_RIGHT_KEY <const> = "selfRightMapping"

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
            { name='Debug', key='debug', values=toggleVals, default=1},
            { name='Turn speed', key=ROTATION_DELAY_KEY, values= ROTATION_DELAY_VALS, default=2},
            { name='Game speed', key=SPEED_KEY, values= SPEED_VALS, default=4},
        }
    },
    {
        header = 'Graphics',
        options = {
            { name='Style', key= GRAPHICS_STYLE_KEY, values= STYLE_VALS, default=1},
            { name='Background', key=BG_KEY, values= BG_VALS, default=1},
            { name='Brick pattern', key=PATTERN_KEY, values= PATTERN_VALS, default=6},
            { name='Invert colors', key=INVERT_KEY, values= toggleVals, default=1},
        }
    },
    {
        header = 'Audio',
        options = {
            { name='Style', key= AUDIO_STYLE_KEY, values= STYLE_VALS, default=1},
            { name='Sound Volume', key= AUDIO_VOLUME_KEY, values= AUDIO_VOLUME_VALS, default=11},
            { name='Music Volume', key= MUSIC_VOLUME_KEY, values= AUDIO_VOLUME_VALS, default=11},
        }
    },
    {
        header = 'Button mapping',
        options = {
            { name='Turn left', key= TURN_LEFT_KEY, values= BUTTON_VALS, default=3},
            { name='Turn right', key= TURN_RIGHT_KEY, values= BUTTON_VALS, default=4},
            { name='Throttle', key= THROTTLE_KEY, values= BUTTON_VALS, default=7},
            { name='Self-right', key= SELF_RIGHT_KEY, values= BUTTON_VALS, default=10},
        }
    },
}

local editorOptions = {}

function Options:init()
    Options.super.init()
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
            gfx.fillRoundRect(x, y, width, height, 4)
        end
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)

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
                if type(val) == 'table' then
                    val = val.label
                end
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
            --gfx.setFont(font)
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

function Options:createButtonMapping()
    return {
        [InputManager.actionLeft] = BUTTON_VALS[self:read(TURN_LEFT_KEY)].keys,
        [InputManager.actionRight] = BUTTON_VALS[self:read(TURN_RIGHT_KEY)].keys,
        [InputManager.actionThrottle] = BUTTON_VALS[self:read(THROTTLE_KEY)].keys,
        [InputManager.actionSelfRight] = BUTTON_VALS[self:read(SELF_RIGHT_KEY)].keys,
    }
end

--- Game code uses many globals to read options. Set them here based on current values
function Options:apply(onlyStartAssets)
    Debug = self:read(DEBUG_KEY)
    local newBG = BG_VALS[self:read(BG_KEY)]
    if newBG then
        resourceLoader:loadBG(newBG)
    end
    local graphicsStyle = STYLE_VALS[self:read(GRAPHICS_STYLE_KEY)]
    if graphicsStyle then
        resourceLoader:loadGraphicsStyle(graphicsStyle, onlyStartAssets)
    end
    local audioStyle = STYLE_VALS[self:read(AUDIO_STYLE_KEY)]
    if audioStyle then
        resourceLoader:loadSounds(audioStyle, onlyStartAssets)
    end
    local audioVolume = AUDIO_VOLUME_VALS[self:read(AUDIO_VOLUME_KEY)]
    if audioVolume then
        if audioVolume == "off" then
            audioVolume = 0.0
        else
            audioVolume = audioVolume / 100
        end
        resourceLoader:setSoundVolume(audioVolume)
    end

    local musicVolume = AUDIO_VOLUME_VALS[self:read(MUSIC_VOLUME_KEY)]
    if musicVolume then
        if musicVolume == "off" then
            musicVolume = 0.0
        else
            musicVolume = musicVolume / 100
        end
        resourceLoader:setMusicVolume(musicVolume)
    end

    local inverted = self:read(INVERT_KEY)
    print("set inverted:", inverted)
    playdate.display.setInverted(inverted)
    local pattern = self:read(PATTERN_KEY)
    if PATTERN_VALS[pattern] == "default" then
        brickPatternOverride = nil
    else
        brickPatternOverride = pattern+2 -- first brick pattern is 3 ("red"), while first key index = 1
    end
    print("set brickPatternOverride", brickPatternOverride)

    local framerateIdx = self:read(SPEED_KEY)
    if framerateIdx then
        playdate.display.setRefreshRate(SPEED_VALS[framerateIdx])
    end

    --- number of frames to disable rotation after each rotation step.
    --- ie. 2 means after each frame with rotation, 2 frames follow without rotation in the same direction
    rotationDelay = ROTATION_DELAY_VALS[self:read(ROTATION_DELAY_KEY)].value

    inputManager:setButtonMapping(self:createButtonMapping())

    if bricksView then
        bricksView = BricksView()
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

    local w <const> = 200
    local h <const> = 240
    local x <const> = 100
    local y <const> = 0
    local right <const> = x + w

    gfx.pushContext()

    if not self.previewMode then
        -- draw background
        gfx.setColor(gfx.kColorWhite)
        -- gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.fillRect(x, y, w, h)

        -- draw divider
        gfx.setColor(gfx.kColorBlack)

        if x > 0 then
            gfx.fillRect(x-2,0,2,240)	-- left divider
        end
        if right < displayWidth then
            gfx.fillRect(right,0,2,240)	-- left divider
        end

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
