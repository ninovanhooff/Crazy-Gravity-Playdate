---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 24/04/2022 22:42levelsc
---

import "lockAnimation"

local gfx <const> = playdate.graphics
local rect <const> = playdate.geometry.rect
local unFlipped <const> = gfx.kImageUnflipped
local defaultFont <const> = gfx.getFont()
local monoFont <const> = monoFont
local hudIcons <const> = sprite -- hud icons are placed at origin of sprite
local thumbs <const> = gfx.imagetable.new("images/level_thumbs")
local console <const> = gfx.image.new("images/level-select/console")
local dPad <const> = gfx.imagetable.new("images/level-select/d_pad")
local aButton <const> = gfx.imagetable.new("images/level-select/a_button")
local largeChallengeIcons <const> = gfx.imagetable.new("images/level-select/large_challenge_icons")
local connector <const> = gfx.image.new("images/level-select/connector")
local challengeBg <const> = gfx.image.new("images/level-select/challenge_bg", 14,11,14,8)

--- size of various content spacing
local gutter <const> = 4
--- includes border, the image is 2px smaller
local thumbSize <const> = 58
local lockSize <const> = 32
local contentCenterX <const> = 298
local lockOffsetPoint <const> = playdate.geometry.point.new(gutter + (thumbSize -lockSize)/2, gutter +(thumbSize -lockSize)/2)
--- x offset of info column
local infoOffsetX <const> = thumbSize + 3*gutter
local viewModel
local numChallenges <const> = numChallenges
local challengeNames <const> = challengeNames

local listRect <const> = playdate.geometry.rect.new(gutter, 0, 174, 240)
local detailRect <const> = playdate.geometry.rect.new(400-238, 0, 238, 240)
local listView = playdate.ui.gridview.new(0, thumbSize + 2* gutter)
listView:setCellPadding(0, 0, gutter, gutter) -- left, right , top, bottom

local challengeRect <const> = playdate.geometry.rect.new(217, 98, 164, 71)
local challengeListView = playdate.ui.gridview.new(challengeRect.width, challengeRect.height)
challengeListView:setNumberOfColumns(numChallenges)
challengeListView:setNumberOfRows(1)
challengeListView.backgroundImage = challengeBg

class("LevelSelectView").extends()

function LevelSelectView:initLockAnimation(idx, type)
    local x,y = listView:getCellBounds(1, idx, 1, listRect.width)
    self.lockAnimation = LockAnimation(
        rect.new(x+gutter*2,y+gutter, thumbSize, thumbSize):insetBy(1,1),
        type
    )
end

function LevelSelectView:init(vm)
    LevelSelectView.super.init(self)
    viewModel = vm
    listView:setNumberOfRows(#vm.menuOptions)
    self.initialRender = true
    self.lastSelectedChallengeIdx = viewModel.selectedChallengeIdx
    if vm.newUnlock then
        self:initLockAnimation(vm.newUnlock, LockAnimation.type.ShakeAndExplode)
    end
end

function listView:drawCell(_, row, _, selected, x, y, width, height)
    local curOption = viewModel.menuOptions[row]
    gfx.setColor(gfx.kColorBlack) -- shape color
    local vDivider = y + 24
    local right = x+width
    local infoX <const> = x + infoOffsetX
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
    defaultFont:drawText("Stage " .. levelNumString(curOption.levelNumber), infoX, y+gutter)
    -- divider
    gfx.drawLine(infoX, vDivider,right-2*gutter, vDivider)

    -- challenges
    monoFont:drawText("Achievements", infoX, vDivider + gutter  - 2)
    local iconY = vDivider + 14 + gutter
    for i = 0,2 do
        hudIcons:draw(infoX+i*39,iconY,unFlipped,64+i*16,
            -- shift 16px down when challenge is not achieved
            boolToNum(not curOption.achievements[i+1])*16,
            16,16
        )
    end
end

local pillWidth <const> = 59
local pillHeight <const> = 16
local pillCornerRadius <const> = pillHeight/2
local function renderChallengePill(x, y, selected, label, value)
    gfx.pushContext()

    if selected then
        gfx.fillRoundRect(x, y, pillWidth, pillHeight, pillCornerRadius)
    else
        gfx.drawRoundRect(x, y , pillWidth, pillHeight, pillCornerRadius)
    end
    gfx.setImageDrawMode(gfx.kDrawModeNXOR) --text color
    monoFont:drawTextAligned(value, x + pillWidth - pillCornerRadius, y + 2, kTextAlignment.right)
    gfx.drawText(label, x + pillWidth + gutter, y)
    gfx.popContext()
end

function challengeListView:drawCell(_, _, challengeIdx, selected, x, y, width, height)
    local centerX <const> = x + width/2
    local option <const> = viewModel:selectedOption()
    local challengeValue <const> = option.challenges[challengeIdx]
    local scores <const> = option.scores
    local achievementUnlocked <const> = option.achievements[challengeIdx]

    -- title
    gfx.drawTextAligned(challengeNames[challengeIdx], centerX, y + 2, kTextAlignment.center)
    -- icon
    largeChallengeIcons:getImage(challengeIdx):draw(x + 12, y + 22)
    -- goal
    renderChallengePill(
        x+53, y+20,
        not achievementUnlocked,
        "Goal",
        challengeValue
    )
    if scores then
        -- personal best
        renderChallengePill(
            x+53, y+39,
            achievementUnlocked,
            "Best",
            scores[challengeIdx]
        )
    end

end


local function renderDetailScreen(info)
    local levelNumber = info.levelNumber
    gfx.pushContext()
    gfx.setClipRect(detailRect)
    -- console
    console:draw(detailRect.x, detailRect.y)
    -- title
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    gfx.drawTextAligned(levelNumString(levelNumber) .. ": " .. info.title, contentCenterX, 12, kTextAlignment.center)

    gfx.popContext()
end

function LevelSelectView:render()
    if viewModel.deniedUnlock then
        self:initLockAnimation(viewModel.deniedUnlock, LockAnimation.type.ShakeAndDenied)
        viewModel.deniedUnlock = nil -- handled
    end
    gfx.setColor(gfx.kColorBlack)
    local needsDetailDisplay = false
    if self.initialRender then
        gfx.clear(gfx.kColorWhite)
        renderDetailScreen(viewModel:selectedOption())
    end

    if listView:getSelectedRow() ~= viewModel.selectedIdx then
        listView:setSelectedRow(viewModel.selectedIdx)
        listView:scrollToRow(viewModel.selectedIdx)
        needsDetailDisplay = true
    end

    if needsDetailDisplay then
        renderDetailScreen(viewModel:selectedOption())
    end

    local challengeChanged = self.lastSelectedChallengeIdx ~= viewModel.selectedChallengeIdx
    if challengeChanged or self.initialRender then
        challengeListView:scrollToCell(1,1, viewModel.selectedChallengeIdx)
    end

    if needsDetailDisplay or challengeListView.needsDisplay or challengeChanged then
        challengeListView:drawInRect(challengeRect.x, challengeRect.y, challengeRect.width, challengeRect.height)
        -- pagination dots
        gfx.setColor(gfx.kColorBlack)
        local selectedChallengeIdx = viewModel.selectedChallengeIdx
        for i = 1, numChallenges do
            local drawFun = selectedChallengeIdx == i and gfx.fillCircleAtPoint or gfx.drawCircleAtPoint
            drawFun(
                challengeRect.x+39 + selectedChallengeIdx*22,
                challengeRect.y+63,
                4
            )
        end

    end

    dPad:getImage(viewModel.dPadImageIdx):draw(223,182)
    aButton:getImage(viewModel.aButtonImageIdx):draw(319,182)

    if listView.needsDisplay or self.lockAnimation then
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(listRect)
        listView:drawInRect(listRect.x, listRect.y, listRect.width, listRect.height)

        -- connector between list and console
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(178,0,10,400)
        local _,y,_, height = listView:getCellBounds(1, viewModel.selectedIdx, 1, listRect.width)
        connector:draw(178, y + height/2 - 9)
        -- redraw part of the console that occludes the list
        gfx.setClipRect(detailRect.x, detailRect.y, 40, 240)
        console:draw(detailRect.x, detailRect.y)
        gfx.clearClipRect()
    end

    local expRunning = self.lockAnimation and self.lockAnimation:update()
    if expRunning then
        gfx.setClipRect(listRect)
        self.lockAnimation:render()
        gfx.clearClipRect()
    else
        self.lockAnimation = nil
    end

    if viewModel.videoPlayerView and not viewModel.videoViewModel.finished then
        viewModel.videoPlayerView:render(viewModel.videoViewModel)
    end

    self.lastSelectedChallengeIdx = viewModel.selectedChallengeIdx
    self.initialRender = false
end
