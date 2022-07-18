---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/04/2022 21:24
---

import "CoreLibs/object"
import "CoreLibs/animator"
import "CoreLibs/easing"
import "../level-select/levelSelectScreen.lua"
import "../bonus-content/BonusContentScreen.lua"
import "../settings/SettingsScreen.lua"
import "../GameScreen.lua"

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
local logoEndX <const> = 6
local logoEndY <const> = 6
local buttonStartAlign <const> = 240
local buttonStartY <const> = 40
local buttonSpacingV <const> = 50
local buttonWidth <const> = 100
local buttonHeight <const> = 24


local inputManager <const> = inputManager
local throttle <const> = InputManager.actionThrottle
local selfRight <const> = InputManager.actionSelfRight
local left <const> = InputManager.actionLeft
local right <const> = InputManager.actionRight
local sinThrustT <const> = sinThrustT
local cosThrustT <const> = cosThrustT

local flying
local planeX, planeY
local vx,vy,planeRot,thrust
local planeSize <const> = planeSize

local function updateViewState(self)
    self.viewState.buttonProgress = buttonTimer.value
    self.viewState.planeRot = planeRot
    self.viewState.planeX, self.viewState.planeY = planeX, planeY
    self.viewState.thrust = thrust
    return self.viewState
end

class("StartViewModel").extends()

local function resetPlane()
    flying = true -- always true for StartScreen
    planeX, planeY = 100,100
    vx,vy,planeRot,thrust = 0,0,18,0 -- thrust only 0 or 1; use thrustPower to adjust.
end

local function createLogoEnterAnimator()
    return animator.new(enterDuration, 0, 1, enterEasing)
end

--- param buttonIdx: 0-based
local function createButtonEnterAnimator(buttonIdx)
    local y = buttonStartY + buttonIdx*buttonSpacingV
    local segment = lineSegment.new(screenWidth, y, buttonStartAlign, y)
    return animator.new(enterDuration, segment, enterEasing, enterButtonTimeGap*buttonIdx)
end

function StartViewModel:init()
    resetPlane()
    self.viewState = {}
    self.viewState.logoAnimator = createLogoEnterAnimator()
    self.viewState.buttons = {
        {
            text = "Campaign",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function() return LevelSelectScreen() end,
            animator = createButtonEnterAnimator(0)
        },
        {
            text = "Quick Start",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function() return GameScreen(levelPath(3)) end,
            animator = createButtonEnterAnimator(1)
        },
        {
            text = "Bonus",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function() return BonusContentScreen()  end,
            animator = createButtonEnterAnimator(2)
        },
        {
            text = "Settings",
            w = buttonWidth, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function() return SettingsScreen()  end,
            animator = createButtonEnterAnimator(3)
        }
    }
    updateViewState(self)
end

local function processInputs()
    -- thrust
    if (inputManager:isInputPressed(throttle)) then
        if Sounds and thrust == 0 then thrust_sound:play(0) end
        thrust = 1
        if not flying then
            vx = 0
            vy = 0
        end
        flying = true
        vx = vx + cosThrustT[planeRot]*thrustPower
        vy = vy - sinThrustT[planeRot]*thrustPower
    elseif thrust == 1 then
        if Sounds then thrust_sound:stop() end
        thrust = 0
    end

    -- rotation
    if inputManager:isInputPressed(selfRight) then
        if planeRot~=18 then
            if planeRot>18 or planeRot<6 then
                planeRot = planeRot-1
            else
                planeRot = planeRot+1
            end
        end
        if planeRot<0 then planeRot = 23 end
    elseif inputManager:isInputPressed(left) then
        if flying then
            planeRot = planeRot - 1
            if planeRot<0 then
                planeRot = 23
            end
        end
    elseif inputManager:isInputPressed(right) then
        if flying then
            planeRot = planeRot + 1
            planeRot = planeRot % 24
        end
    end
end

local function calcPlane()
    vx = vx*drag
    vy = (vy+gravity)*drag
    planeX = planeX + vx
    planeY = planeY + vy
    if planeX > screenWidth or planeX + planeSize < 0 then
        planeX = planeX % screenWidth
    end
    if planeY > screenHeight or planeY + planeSize < 0 then
        planeY = planeY % screenHeight
    end
end

-- returns true if this rect may collide with planePos, does not take plane sub-pos ([3] and 4]) into
-- account. When false, it is guaranteed that this rect does not intersect with the plane
local function approxRectCollision(button)
    local x,y = button.animator:currentValue():unpack()
    -- plane size is 24px
    return planeX + 24 > x and planeX < x+button.w  and planeY+24 > y and planeY <y+button.h
end

--- @return Screen button's onClick function if activated; or nil
local function calcButtonCollision(self)
    local anyCollision = false
    for _, button in ipairs(self.viewState.buttons) do
        if approxRectCollision(button) then
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
    processInputs()
    calcPlane()
    calcButtonCollision(self)
    return updateViewState(self)
end

function StartViewModel:pause()
    if Sounds then thrust_sound:stop() end
end
