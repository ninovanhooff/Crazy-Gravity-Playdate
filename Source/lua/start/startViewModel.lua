---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/04/2022 21:24
---


require "lua/common/PlanePhysicsViewModel"

local animator <const> = playdate.graphics.animator
local lineSegment <const> = playdate.geometry.lineSegment
local enterEasing <const> = playdate.easingFunctions.inOutCubic
local enterDuration <const> = 300
--- time between start of button enter animations
local enterButtonTimeGap <const> = 20

local buttonTimer <const> = playdate.timer.new(1500, 0, 1) -- duration, start, end
buttonTimer.discardOnCompletion = false
buttonTimer:pause()  -- disable auto start

local screenWidth <const> = screenWidth
local buttonStartAlign <const> = 240
local buttonStartY <const> = 40
local buttonSpacingV <const> = 50
local buttonWidth <const> = 100
local buttonHeight <const> = 24

local function updateViewState(self)
    self.viewState.buttonProgress = buttonTimer.value
    self.viewState.planeRot = self.planeRot
    self.viewState.planeX, self.viewState.planeY = self.planeX, self.planeY
    self.viewState.thrust = self.thrust
    return self.viewState
end

class("StartViewModel").extends(PlanePhysicsViewModel)

function StartViewModel:resetPlane(initialPlaneX, initialPlaneY)
    self.flying = true -- always true for StartScreen
    self.planeX, self.planeY = initialPlaneX or -22, initialPlaneY or 130
    if not initialPlaneX and not initialPlaneY then
        self.vx,self.vy,self.planeRot,self.thrust = 5,-5,21,0 -- thrust only 0 or 1; use thrustPower to adjust.
    else
        self.vx,self.vy,self.planeRot,self.thrust = vx,vy,planeRot,thrust
    end
end

function StartViewModel:loadFullResources()
    printT("Before full options apply")
    Options():apply(false)
    printT("After full options apply")
end

local function createLogoEnterAnimator()
    return animator.new(enterDuration, 0, 1, enterEasing)
end

--- create a GameScreen for the level and challenge the player is most likely to want to play next
function StartViewModel:quickStartScreen()
    self:loadFullResources()
    require "lua/gameScreen"
    local selectLevelNum, challengeIdx = nextUnfinishedLevel()
    local levelPath = levelPath(selectLevelNum)
    gameHUD.selectedChallenge = challengeIdx
    gameHUD.challengeTarget = getChallengesForPath(levelPath)[challengeIdx]
    currentLevel = selectLevelNum
    return GameScreen(levelPath, challengeIdx)
end

--- param buttonIdx: 0-based
local function createButtonEnterAnimator(buttonIdx)
    local y = buttonStartY + buttonIdx*buttonSpacingV
    local segment = lineSegment.new(screenWidth, y, buttonStartAlign, y)
    return animator.new(enterDuration, segment, enterEasing, enterButtonTimeGap*buttonIdx)
end

function StartViewModel:init(initialPlaneX, initialPlaneY)
    StartViewModel.super.init(self)
    self:resetPlane(initialPlaneX, initialPlaneY)
    self.viewState = {}
    self.shouldPlayEnterSound = true
    self.viewState.logoAnimator = createLogoEnterAnimator()
    self.viewState.buttons = {
        {
            text = "Campaign",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function()
                require "lua/level-select/levelSelectScreen"
                self:loadFullResources()
                return LevelSelectScreen()
            end,
            animator = createButtonEnterAnimator(0)
        },
        {
            text = "Quick Start",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function()
                return self:quickStartScreen()
            end,
            animator = createButtonEnterAnimator(1)
        },
        {
            text = "Bonus",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function()
                require "lua/bonus-content/BonusContentScreen"
                return BonusContentScreen()
            end,
            animator = createButtonEnterAnimator(2)
        },
        {
            text = "Settings",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function()
                require "lua/settings/SettingsScreen"
                return SettingsScreen()
            end,
            animator = createButtonEnterAnimator(3)
        }
    }
    updateViewState(self)
end

-- returns true if this rect may collide with planePos, does not take plane sub-pos ([3] and 4]) into
-- account. When false, it is guaranteed that this rect does not intersect with the plane
function StartViewModel:approxRectCollision(button)
    local x,y = button.animator:currentValue():unpack()
    -- plane size is 24px
    return self.planeX + 24 > x and self.planeX < x+button.w  and self.planeY+24 > y and self.planeY <y+button.h
end

--- Screen button's onClick function if activated; or nil
function StartViewModel:calcButtonCollision()
    local anyCollision = false
    for _, button in ipairs(self.viewState.buttons) do
        if self:approxRectCollision(button) then
            buttonTimer:start() -- does nothing when already running
            button.progress = buttonTimer.value
            if button.progress >= 1.0 then
                pushScreen(button.onClickScreen())
                return
            end
            anyCollision = true
        else
            button.progress = 0
        end
    end

    if not anyCollision then
        buttonTimer:reset()
    end

end

function StartViewModel:calcTimeStep()
    if self.shouldPlayEnterSound then
        swish_sound_reverse:play() -- play once
        self.shouldPlayEnterSound = false
    end
    self:processInputs()
    self:calcPlane()
    self:calcButtonCollision()
    return updateViewState(self)
end

function StartViewModel:pause()
    if Sounds then thrust_sound:stop() end
end
