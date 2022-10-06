---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/09/2022 22:15
---



local inputManager <const> = inputManager
local throttle <const> = InputManager.actionThrottle
local selfRight <const> = InputManager.actionSelfRight
local left <const> = InputManager.actionLeft
local right <const> = InputManager.actionRight
local sinThrustT <const> = sinThrustT
local cosThrustT <const> = cosThrustT
local screenWidth <const> = screenWidth
local screenHeight <const> = screenHeight


class("PlanePhysicsViewModel").extends()

function PlanePhysicsViewModel:init()
    PlanePhysicsViewModel.super.init(self)
    self.flying = true -- always true for StartScreen
    self.planeX, self.planeY = 100,100
    self.vx,self.vy,self.planeRot,self.thrust = 0,0,18,0
    --- counter for the current rotation timeout. positive is clockwise timeout, negative is ccw timeout
    self.rotationTimeout = 0
end

function PlanePhysicsViewModel:calcPlane()
    self.vx = self.vx*drag
    self.vy = (self.vy+gravity)*drag
    self.planeX = self.planeX + self.vx
    self.planeY = self.planeY + self.vy
    if self.planeX > screenWidth or self.planeX + planeSize < 0 then
        self.planeX = self.planeX % screenWidth
    end
    if self.planeY > screenHeight or self.planeY + planeSize < 0 then
        self.planeY = self.planeY % screenHeight
    end
end

function PlanePhysicsViewModel:processInputs()
    -- self.thrust
    if (inputManager:isInputPressed(throttle)) then
        if Sounds and self.thrust == 0 then thrust_sound:play(0) end
        self.thrust = 1
        if not self.flying then
            self.vx = 0
            self.vy = 0
        end
        self.flying = true
        self.vx = self.vx + cosThrustT[self.planeRot]*thrustPower
        self.vy = self.vy - sinThrustT[self.planeRot]*thrustPower
    elseif self.thrust == 1 then
        if Sounds then thrust_sound:stop() end
        self.thrust = 0
    end

    -- rotation
    if inputManager:isInputPressed(selfRight) then
        if self.planeRot~=18 then
            if self.planeRot>18 or self.planeRot<6 then
                self.planeRot = self.planeRot-1
            else
                self.planeRot = self.planeRot+1
            end
        end
        if self.planeRot<0 then self.planeRot = 23 end
        self.rotationTimeout = 0
    elseif inputManager:isInputPressed(left) then
        if self.rotationTimeout > 0 then
            -- cancel clockwise rotation timeout
            self.rotationTimeout = 0
        end
        if self.flying  and self.rotationTimeout == 0 then
            self.planeRot = self.planeRot - 1
            if self.planeRot<0 then
                self.planeRot = 23
            end
            self.rotationTimeout = -rotationDelay -- negative for left rotation
        else
            self.rotationTimeout = self.rotationTimeout + 1
        end
    elseif inputManager:isInputPressed(right) then
        if self.rotationTimeout < 0 then
            -- cancel counter-clockwise rotation timeout
            self.rotationTimeout = 0
        end
        if self.flying and self.rotationTimeout == 0 then
            self.planeRot = self.planeRot + 1
            self.planeRot = self.planeRot % 24
            self.rotationTimeout = rotationDelay
        else
            self.rotationTimeout = self.rotationTimeout - 1
        end
    else
        self.rotationTimeout = 0
    end
end
