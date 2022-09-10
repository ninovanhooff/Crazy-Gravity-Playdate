import "CoreLibs/object"

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

local states = enum({"LoadPlane", "ReturnPlatform", "LiftOff"})

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)

    self.planePosX = planePos[1]*tileSize + planePos[3]
    self.planePosY = planePos[2]*tileSize + planePos[4]
    self.rocketShipY = 216.5*tileSize

    self.platform = lume.match(specialT, function(item) return item.id == PlatformId end)
    self.barrier = lume.match(specialT, function(item) return item.id == BarrierId end)
    self.origPlatformX = self.platform.x
    self.closedBarrierPos = self.barrier.pos
    self.platformOffsetX = self.platform.x*tileSize - self.planePosX

    self.planeAnimator = gfx.animator.new(loadPlaneDurationMs, self.planePosX, targetPlanePosX)
    self.controlRoomAnimator = gfx.animator.new(loadPlaneDurationMs, -600, 0)

    self.state = states.LoadPlane
end

function EndGameViewModel:pause()
end

function EndGameViewModel:resume()
    self.platform.arrows = false
end

function EndGameViewModel:LoadPlaneUpdate()
    if not self.planeAnimator:ended() then
        self.planePosX = floor(self.planeAnimator:currentValue())
        self.platform.x = (self.planePosX + self.platformOffsetX)/tileSize
    else
        self.state = states.ReturnPlatform
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
        self.state = states.LiftOff
    end
end

function EndGameViewModel:LiftOffUpdate()
    self.planePosY = self.planePosY * 0.999
end

local stateUpdaters = {
    [states.LoadPlane] = EndGameViewModel.LoadPlaneUpdate,
    [states.ReturnPlatform] = EndGameViewModel.ReturnPlatformUpdate,
    [states.LiftOff] = EndGameViewModel.LiftOffUpdate,
}

function EndGameViewModel:update()
    calcTimeStep()
    stateUpdaters[self.state](self)
    planePos[1] = floor(self.planePosX / tileSize)
    planePos[2] = floor(self.planePosY / tileSize)
    planePos[3] = self.planePosX % tileSize
    planePos[4] = self.planePosY % tileSize


    if justPressed(buttonB) then
        popScreen()
    end
end
