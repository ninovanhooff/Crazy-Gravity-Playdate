---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/04/2022 21:24
---

import "CoreLibs/object"

local buttonTimer <const> = playdate.timer.new(1500, 0, 1) -- duration, start, end
buttonTimer.discardOnCompletion = false
buttonTimer:pause()  -- disable auto start

local buttonWidth <const> = 100
local buttonHeight <const> = 24


local pressed <const> = playdate.buttonIsPressed
local throttle <const> = playdate.kButtonA | playdate.kButtonB | playdate.kButtonUp
local buttonDown <const> = playdate.kButtonDown
local buttonLeft <const> = playdate.kButtonLeft
local buttonRight <const> = playdate.kButtonRight
local thrustSound <const> = thrust_sound
local sinThrustT <const> = sinThrustT
local cosThrustT <const> = cosThrustT

local flying = false
local planeX, planeY = 100,100
local vx,vy,planeRot,thrust = 0,0,18,0 -- thrust only 0 or 1; use thrustPower to adjust.
local planeSize <const> = planeSize

local function updateViewState(self)
    self.viewState.buttonProgress = buttonTimer.value
    self.viewState.planeRot = planeRot
    self.viewState.planeX, self.viewState.planeY = planeX, planeY
    self.viewState.thrust = thrust
    self.viewState.buttonProgress = buttonTimer.value
    return self.viewState
end

class("StartViewModel").extends()

function StartViewModel:init()
    self.viewState = {}
    self.viewState.buttons = {
        {text = "Start Game", x = 200, y = 100, w = buttonWidth, h = buttonHeight,progress = 0.3},
        {text = "Settings", x = 200, y = 150, w = buttonWidth, h = buttonHeight, progress = 0.4}
    }
    updateViewState(self)
end

local function processInputs()
    -- thrust
    if (pressed(throttle)) then
        if Sounds and thrust == 0 then thrustSound:play(0) end
        thrust = 1
        if not flying then
            vx = 0
            vy = 0
        end
        flying = true
        vx = vx + cosThrustT[planeRot]*thrustPower
        vy = vy - sinThrustT[planeRot]*thrustPower
    elseif thrust == 1 then
        if Sounds then thrustSound:stop() end
        thrust = 0
    end

    -- rotation
    if pressed(buttonDown) then
        if planeRot~=18 then
            if planeRot>18 or planeRot<6 then
                planeRot = planeRot-1
            else
                planeRot = planeRot+1
            end
        end
        if planeRot<0 then planeRot = 23 end
    elseif pressed(buttonLeft) then
        if flying then
            planeRot = planeRot - 1
            if planeRot<0 then
                planeRot = 23
            end
        end
    elseif pressed(buttonRight) then
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
local function approxRectCollision(x, y, w, h)
    -- plane size is 24px
    return planeX + 24 > x and planeX < x+w  and planeY+24 > y and planeY <y+h
end

local function calcButtonCollision(self)
    local anyCollision = false
    for _, button in ipairs(self.viewState.buttons) do
        if approxRectCollision(button.x,button.y,button.w,button.h) then
            buttonTimer:start() -- does nothing when already running
            button.progress = buttonTimer.value
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
