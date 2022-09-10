import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local floor <const> = math.floor

local calcTimeStep <const> = CalcTimeStep
local tileSize <const> = tileSize
local PlatformId <const> = "endGamePlatform"
local targetPlanePosX <const> = 200

local states = enum({"LoadPlane", "ReturnPlatform"})

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)

    self.planePosX = planePos[1]*tileSize + planePos[3]
    self.planePosY = planePos[2]*tileSize + planePos[4]
    self.platform = lume.match(specialT, function(item) return item.id == PlatformId end)
    self.origPlatformX = self.platform.x
    self.state = states.LoadPlane
end

function EndGameViewModel:pause()
end

function EndGameViewModel:resume()
    self.platform.arrows = false
end

function EndGameViewModel:LoadPlaneUpdate()
    local speed = 2
    if self.planePosX > targetPlanePosX then
        self.planePosX = self.planePosX - speed
        self.platform.x = self.platform.x - speed/tileSize
        planePos[1] = floor(self.planePosX / tileSize)
        planePos[3] = self.planePosX % tileSize
    else
        self.state = states.ReturnPlatform
    end
end

function EndGameViewModel:ReturnPlatformUpdate()
    local platform = self.platform
    local speedPx = 2
    if platform.x < self.origPlatformX then
        self.platform.x = self.platform.x + speedPx /tileSize
    end
end

local stateUpdaters = {
    [states.LoadPlane] = EndGameViewModel.LoadPlaneUpdate,
    [states.ReturnPlatform] = EndGameViewModel.ReturnPlatformUpdate
}

function EndGameViewModel:update()
    stateUpdaters[self.state](self)

    calcTimeStep()

    if justPressed(buttonB) then
        popScreen()
    end
end
