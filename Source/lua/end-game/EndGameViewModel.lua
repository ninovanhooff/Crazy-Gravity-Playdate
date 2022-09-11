import "CoreLibs/object"
import "FlyToCreditsScreen"

local gfx <const> = playdate.graphics
local getCrankChange <const> = playdate.getCrankChange
local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local floor <const> = math.floor

local calcTimeStep <const> = CalcTimeStep
local tileSize <const> = tileSize
local PlatformId <const> = "endGamePlatform"
local BarrierId <const> = "endGameBarrier"
local AirlockLId <const> = "endGameAirlockL"
local AirlockRId <const> = "endGameAirlockR"
local targetPlanePosX <const> = 200
local loadPlaneDurationMs <const> = 1700
local returnPlatformDurationMs <const> = loadPlaneDurationMs

local states = enum({"LoadPlane", "ReturnPlatform", "LiftOff", "OpenAirlock", "FlyAway"})

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)

    self.planePosX = planePos[1]*tileSize + planePos[3]
    self.planePosY = planePos[2]*tileSize + planePos[4]

    local findSpecial = function(targetId)
        return lume.match(specialT, function(item) return item.id == targetId end)
    end

    self.platform = findSpecial(PlatformId)
    self.barrier = findSpecial(BarrierId)
    self.airlockL = findSpecial(AirlockLId)
    self.airlockR = findSpecial(AirlockRId)
    self.airLockROverridePos = 9*tileSize
    self.crankFrame = 0 -- 0-based
    self.numCrankFrames = 0 -- set by View
    self.maxAirlockRPos = self.airlockR.pos
    self.origPlatformX = self.platform.x
    self.closedBarrierPos = self.barrier.pos
    self.platformOffsetX = self.platform.x*tileSize - self.planePosX

    self.liftOffSpeed = 0.1

    self:setState(states.LoadPlane)
    self:setState(states.OpenAirlock)
    self.planePosX = 200
    camPos[1] = 1
end

function EndGameViewModel:initState(state)
    print("init state", state.name)
    if state == states.LoadPlane then
        self.planeAnimator = gfx.animator.new(loadPlaneDurationMs, self.planePosX, targetPlanePosX)
        self.controlRoomAnimator = gfx.animator.new(loadPlaneDurationMs, -600, 0)
    elseif state == states.LiftOff then
        self.camOverrideY = camPos[2]*tileSize+camPos[4]
    elseif state == states.OpenAirlock then
        self.camOverrideY = 10 * tileSize
    elseif state == states.FlyAway then
        self.liftOffSpeed = 4
        self.planePosY = (gameHeightTiles + 10) * tileSize -- right outside frame, offset to also place rocketShip outside frame
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
    if self.airLockROverridePos == 0 then
        self:setState(states.FlyAway)
    end

    local changeDirection = 0 -- 1 for close, -1 for open
    if getCrankChange() > 5 and self.airLockROverridePos < self.maxAirlockRPos then
        changeDirection = 1
    elseif getCrankChange() < -5 and self.airLockROverridePos > 0 then
        changeDirection = -1
    end
    self.crankFrame = math.abs((self.crankFrame + changeDirection) % (self.numCrankFrames))
    self.airLockROverridePos = lume.clamp(self.airLockROverridePos + changeDirection * 2, 0, self.maxAirlockRPos)

end

function EndGameViewModel:FlyAwayUpdate()
    self.planePosY = self.planePosY - self.liftOffSpeed
    if self.planePosY < 0 then
        self:onEnded()
    end
end

local stateUpdaters = {
    [states.LoadPlane] = EndGameViewModel.LoadPlaneUpdate,
    [states.ReturnPlatform] = EndGameViewModel.ReturnPlatformUpdate,
    [states.LiftOff] = EndGameViewModel.LiftOffUpdate,
    [states.OpenAirlock] = EndGameViewModel.OpenAirlockUpdate,
    [states.FlyAway] = EndGameViewModel.FlyAwayUpdate,
}

function EndGameViewModel:update()
    calcTimeStep()
    stateUpdaters[self.state](self)
    planePos[1] = floor(self.planePosX / tileSize)
    planePos[2] = floor(self.planePosY / tileSize)
    planePos[3] = self.planePosX % tileSize
    planePos[4] = self.planePosY % tileSize

    self.airlockL.pos = 0 -- fully open
    self.airlockR.pos = self.airLockROverridePos

    if self.camOverrideY then
        camPos[2] = floor(self.camOverrideY / tileSize)
        camPos[4] = self.camOverrideY % tileSize
    end
end
