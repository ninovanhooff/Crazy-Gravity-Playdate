import "CoreLibs/object"

local gfx <const> = playdate.graphics
local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local floor <const> = math.floor

local calcTimeStep <const> = CalcTimeStep
local tileSize <const> = tileSize
local PlatformId <const> = "endGamePlatform"
local BarrierId <const> = "endGameBarrier"
local panSpeed <const> = 2
local targetPlanePosX <const> = 200

local states = enum({"LoadPlane", "ReturnPlatform"})

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)

    self.planePosX = planePos[1]*tileSize + planePos[3]
    self.planePosY = planePos[2]*tileSize + planePos[4]
    self.rocketShipY = 208*tileSize

    self.platform = lume.match(specialT, function(item) return item.id == PlatformId end)
    self.barrier = lume.match(specialT, function(item) return item.id == BarrierId end)
    self.origPlatformX = self.platform.x
    self.closedBarrierPos = self.barrier.pos
    self.platformOffsetX = self.platform.x*tileSize - self.planePosX
    self.loadPlaneDurationMs = 5000

    self.planeAnimator = gfx.animator.new(self.loadPlaneDurationMs, self.planePosX, targetPlanePosX)
    self.controlRoomAnimator = gfx.animator.new(self.loadPlaneDurationMs, -600, 0)

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
        planePos[1] = floor(self.planePosX / tileSize)
        planePos[3] = self.planePosX % tileSize
    else
        self.state = states.ReturnPlatform
    end
end

function EndGameViewModel:ReturnPlatformUpdate()
    local platform = self.platform
    if platform.x < self.origPlatformX then
        self.platform.x = self.platform.x + panSpeed /tileSize
    end
    if self.overriddenBarrierPos and self.overriddenBarrierPos < self.closedBarrierPos then
        self.overriddenBarrierPos = self.overriddenBarrierPos + 2
    end
    if not self.overriddenBarrierPos and self.platform.x > self.barrier.x then
        self.overriddenBarrierPos = 0
    end
    if self.overriddenBarrierPos then
        self.barrier.pos = self.overriddenBarrierPos
    end
end

local stateUpdaters = {
    [states.LoadPlane] = EndGameViewModel.LoadPlaneUpdate,
    [states.ReturnPlatform] = EndGameViewModel.ReturnPlatformUpdate
}

function EndGameViewModel:update()
    calcTimeStep()
    stateUpdaters[self.state](self)


    if justPressed(buttonB) then
        popScreen()
    end
end
