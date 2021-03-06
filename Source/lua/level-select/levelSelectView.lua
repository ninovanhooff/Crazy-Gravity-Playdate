---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 24/04/2022 22:42levelsc
---

import "CoreLibs/object"
import "CoreLibs/ui"
import "lockExplosion.lua"

local gfx <const> = playdate.graphics
local rect <const> = playdate.geometry.rect
local defaultFont <const> = gfx.getFont()
local monoFont <const> = monoFont
local hudIcons <const> = sprite -- hud icons are placed at origin of sprite
local thumbs <const> = gfx.imagetable.new("images/level-thumbs/level-thumbs")
local banners <const> = gfx.imagetable.new("images/level-banners/level-banners")

--- size of various content spacing
local gutter <const> = 4
--- includes border, the image is 2px smaller
local thumbSize <const> = 58
local lockSize <const> = 32
local lockOffsetPoint <const> = playdate.geometry.point.new(gutter + (thumbSize -lockSize)/2, gutter +(thumbSize -lockSize)/2)
--- x offset of info column
local infoOffsetX <const> = thumbSize + 3*gutter
local viewModel

local listRect <const> = playdate.geometry.rect.new(gutter, 0, 192, 240)
local detailRect <const> = playdate.geometry.rect.new(200+gutter, gutter, 200-gutter*2, 224 - gutter*2)
local listView = playdate.ui.gridview.new(0, thumbSize + 2* gutter)
listView:setCellPadding(0, 0, gutter, gutter) -- left, right , top, bottom

class("LevelSelectView").extends()

function LevelSelectView:init(vm)
    LevelSelectView.super.init()
    viewModel = vm
    listView:setNumberOfRows(#vm.menuOptions)
    self.initialRender = true
    self.lastSelectedChallenge = viewModel.selectedChallenge
    if vm.newUnlock then
        local x,y,width, height = listView:getCellBounds(1, vm.newUnlock, 1, listRect.width)
        self.lockExplosion = LockExplosion(
            rect.new(x+gutter*2,y+gutter, thumbSize, thumbSize):insetBy(1,1)
        )
    end

end

local function renderChallengePill(x, y, selected, hudIdx, text)
    local w = monoFont:getTextWidth(text) + 35
    gfx.pushContext()

    if selected then
        gfx.fillRoundRect(x, y, w, 18, 9)
        gfx.setColor(gfx.kColorWhite)
    else
        gfx.drawRoundRect(x, y , w, 18, 9)
    end
    gfx.setImageDrawMode(gfx.kDrawModeNXOR) --text color
    hudIcons:draw(x + 8,y+1,unFlipped,hudIdx*16,0,16,16)
    monoFont:drawText(text, x+28, y+6)
    gfx.popContext()
    return w
end

function listView:drawCell(section, row, column, selected, x, y, width, height)
    local curOption = viewModel.menuOptions[row]
    gfx.setColor(gfx.kColorBlack) -- shape color
    local vDivider = y + 24
    local right = x+width
    local infoX = x + infoOffsetX
    if selected then
        gfx.fillRoundRect(x, y, width, height, gutter)
        gfx.setColor(gfx.kColorWhite) -- shape color
    else
        gfx.drawRoundRect(x, y, width, height, gutter)
    end
    gfx.setImageDrawMode(gfx.kDrawModeNXOR) --text color

    -- thumb image / lock
    local unlocked = viewModel.menuOptions[row]["unlocked"]
    gfx.drawRect(x+gutter, y+gutter, thumbSize, thumbSize)
    if unlocked and thumbs[row] then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        thumbs[row]:draw(x + gutter + 1, y + gutter + 1)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    end
    if not unlocked then
        -- draw lock
        sprite:draw(x+lockOffsetPoint.x, y+lockOffsetPoint.y, unFlipped, 0, 64, lockSize, lockSize)
    end

    -- title
    defaultFont:drawText(curOption.title, infoX, y+gutter)
    -- divider
    gfx.drawLine(infoX, vDivider,right-2*gutter, vDivider)

    -- challenges
    monoFont:drawText("Achievements", infoX, vDivider + gutter + 1)
    local iconY = vDivider + 14 + gutter

    for i = 0,2 do
        hudIcons:draw(infoX+i*48,iconY,unFlipped,64+i*16,
            -- shift 16px down when challenge is not achieved
            boolToNum(not curOption.achievements[i+1])*16,
            16,16
        )
    end
end

local function drawTextInRectUnderlined(text, rect, font)
    local width, height = gfx.drawTextInRect(
        text,
        rect.x, rect.y, rect.width, rect.height, -- cannot pass rect directly due to bug in SDK https://devforum.play.date/t/5314
        nil, nil,
        kTextAlignment.center, font
    )
    local halfWidth, y, centerX = width*0.5 + 12 , rect.y+height, rect:centerPoint().x
    gfx.drawLine(centerX-halfWidth, y, centerX+halfWidth, y)

end

local function renderDetailScreen(info)
    local levelNumber = info.levelNumber
    gfx.pushContext()
    gfx.setClipRect(detailRect)
    gfx.clear(gfx.kColorWhite)

    local infoY = detailRect.y

    -- title
    drawTextInRectUnderlined(info.title, detailRect, defaultFont)
    infoY = infoY + 30

    -- banner image
    gfx.drawRect(detailRect.x, infoY, detailRect.width, 64)
    if banners[levelNumber] then
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        banners[levelNumber]:draw(detailRect.x + 1, infoY + 1)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    end
    infoY = infoY + 70

    monoFont:drawText("Challenges", detailRect.x, infoY)
    infoY = infoY + 12
    -- challenges
    local challengeX = detailRect.x
    -- time
    challengeX = challengeX + gutter +  renderChallengePill(
        challengeX, infoY,
        viewModel.selectedChallenge == 1,
        4, info.challenges[1]
    )
    -- fuel
    challengeX = challengeX + gutter +  renderChallengePill(
        challengeX, infoY,
        viewModel.selectedChallenge == 2,
        5, info.challenges[2]
    )
    -- lives
    challengeX = challengeX + gutter +  renderChallengePill(
        challengeX, infoY,
        viewModel.selectedChallenge == 3,
        6, info.challenges[3]
    )
    infoY = infoY + 24

    -- scores
    if(info.scores) then
        monoFont:drawText("Personal Best", detailRect.x, infoY)
        infoY = infoY + 12
        for i, item in ipairs(info.scores) do
            hudIcons:draw(detailRect.x,infoY,unFlipped,48+i*16,0,16,16)
            monoFont:drawText(item, detailRect.x + 20, infoY + 5)
            infoY = infoY + 20
        end
    end


    gfx.popContext()
end

local function renderStaticViews()
    gfx.pushContext()
    local originalSystemFont = playdate.graphics.getSystemFont()
    gfx.setFont( originalSystemFont, playdate.graphics.font.kVariantItalic )
    --gfx.setFont(defaultFont)
    gfx.setPattern({0x55, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF, 0x7F, 0xFF})
    gfx.drawLine(200, 0,200, 240)
    gfx.setColor(gfx.kColorBlack) -- clear pattern
    -- draw keymap hint below detail
    --gfx.drawTextInRect('*'.."_???hallo_hee", detailRect.x - 20, detailRect.bottom, detailRect.width, 20, nil, '...', kTextAlignment.right)
    gfx.drawTextInRect("_?????????_ start   _???_ *start*", detailRect.x, detailRect.bottom , detailRect.width, 25, nil, "...", kTextAlignment.center)
    gfx.popContext()
end

function LevelSelectView:render()
    gfx.setColor(gfx.kColorBlack)
    local needsDetailDisplay = self.lastSelectedChallenge ~= viewModel.selectedChallenge
    if self.initialRender then
        gfx.clear(gfx.kColorWhite)
        renderStaticViews()
        renderDetailScreen(viewModel:selectedOption())
        self.initialRender = false
    end

    if listView:getSelectedRow() ~= viewModel.selectedIdx then
        listView:setSelectedRow(viewModel.selectedIdx)
        listView:scrollToRow(viewModel.selectedIdx)
        needsDetailDisplay = true
    end

    if needsDetailDisplay then
        renderDetailScreen(viewModel:selectedOption())
    end

    if listView.needsDisplay or self.lockExplosion then
        gfx.setClipRect(listRect)
        gfx.clear(gfx.kColorWhite)
        listView:drawInRect(listRect.x, listRect.y, listRect.width, listRect.height)
    end

    local expRunning = self.lockExplosion and self.lockExplosion:update()
    if expRunning then
        self.lockExplosion:render()
    else self.lockExplosion = nil
    end

    self.lastSelectedChallenge = viewModel.selectedChallenge
end
