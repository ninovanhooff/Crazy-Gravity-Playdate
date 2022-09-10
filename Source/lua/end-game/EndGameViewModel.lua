import "CoreLibs/object"
import "FlyToCreditsScreen"

local gfx <const> = playdate.graphics
local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local floor <const> = math.floor

local calcTimeStep <const> = CalcTimeStep
local tileSize <const> = tileSize
local PlatformId <const> = "endGamePlatform"
local BarrierId <const> = "endGameBarrier"
local targetPlanePosX <const> = 200
local loadPlaneDurationMs <const> = 1700
local returnPlatformDurationMs <const> = loadPlaneDurationMs

local states = enum({"LoadPlane", "ReturnPlatform", "LiftOff", "OpenAirlock"})

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)

    self.planePosX = planePos[1]*tileSize + planePos[3]
    self.planePosY = planePos[2]*tileSize + planePos[4]

    self.platform = lume.match(specialT, function(item) return item.id == PlatformId end)
    self.barrier = lume.match(specialT, function(item) return item.id == BarrierId end)
    self.origPlatformX = self.platform.x
    self.closedBarrierPos = self.barrier.pos
    self.platformOffsetX = self.platform.x*tileSize - self.planePosX

    self.liftOffSpeed = 0.1

    self:setState(states.LoadPlane)
end

function EndGameViewModel:initState(state)
    if state == states.LoadPlane then
        self.planeAnimator = gfx.animator.new(loadPlaneDurationMs, self.planePosX, targetPlanePosX)
        self.controlRoomAnimator = gfx.animator.new(loadPlaneDurationMs, -600, 0)
    elseif state == states.LiftOff then
        self.camOverrideY = camPos[2]*tileSize+camPos[4]
    elseif state == states.OpenAirlock then
        self.camOverrideY = 4 * tileSize
    end
    end

function EndGameViewModel:setState(state)
    self:initState(state)
    self.state = state
end

function EndGameViewModel:pause()
end

function EndGameViewModel:resume()
    self.platform.arrows = false
end

function EndGameViewModel:onEnded()
    popScreen() -- pop self
    pushScreen(FlyToCreditsScreen())
end

function EndGameViewModel:LoadPlaneUpdate()
    if not self.planeAnimator:ended() then
        self.planePosX = floor(self.planeAnimator:currentValue())
        self.platform.x = (self.planePosX + self.platformOffsetX)/tileSize
    else
        self:setState(states.ReturnPlatform)
    end
end

function EndGameViewModel:ReturnPlatformUpdate()

    if not self.returnPlatformAnimator then
        self.returnPlatformAnimator = gfx.animator.new(
            returnPlatformDurationMs,
            self.platform.x,
            self.origPlatformX
        )
    end
    self.platform.x = self.returnPlatformAnimator:currentValue()

    if self.platform.x > self.barrier.x then
        self.barrier.actW = 1 -- starts closing the barrier because the plane is now outside activation zone
    end

    if self.returnPlatformAnimator:ended() then
        self:setState(states.LiftOff)
    end
end

function EndGameViewModel:LiftOffUpdate()
    self.planePosY = self.planePosY - self.liftOffSpeed
    self.liftOffSpeed = self.liftOffSpeed * 1.01 -- accelerate
    if self.liftOffSpeed > 1.5 then
        self.camOverrideY = self.camOverrideY - 4
    end
    if self.planePosY < 100 * tileSize then
        self:setState(states.OpenAirlock)
    end
end

function EndGameViewModel:OpenAirlockUpdate()
    if self.planePosY < 0 then
        self:onEnded()
    end
end

local stateUpdaters = {
    [states.LoadPlane] = EndGameViewModel.LoadPlaneUpdate,
    [states.ReturnPlatform] = EndGameViewModel.ReturnPlatformUpdate,
    [states.LiftOff] = EndGameViewModel.LiftOffUpdate,
    [states.OpenAirlock] = EndGameViewModel.OpenAirlockUpdate,
}

function EndGameViewModel:update()
    calcTimeStep()
    stateUpdaters[self.state](self)
    planePos[1] = floor(self.planePosX / tileSize)
    planePos[2] = floor(self.planePosY / tileSize)
    planePos[3] = self.planePosX % tileSize
    planePos[4] = self.planePosY % tileSize

    if self.camOverrideY then
        camPos[2] = floor(self.camOverrideY / tileSize)
        camPos[4] = self.camOverrideY % tileSize
    end
end
