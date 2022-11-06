require "lua/gameScreen"
import "FlyToCreditsScreen"

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local getCurrentTime <const> = snd.getCurrentTime
local justPressed <const> = playdate.buttonJustPressed
local justReleased <const> = playdate.buttonJustReleased
local loop <const> = gfx.animation.loop
local rocketExhaustBurnImgTable = gfx.imagetable.new("images/rocket_ship_burn")
local rocketExhaustStartImgTable = gfx.imagetable.new("images/rocket_ship_burn_start")

local clickSample = snd.sample.new("sounds/launch_control_click")
local clickSamplePlayer = snd.sampleplayer.new(clickSample)
assert(clickSamplePlayer)

local getCrankChange <const> = playdate.getCrankChange
local floor <const> = math.floor
local clamp <const> = clamp
local luaMod <const> = luaMod
local musicManager <const> = musicManager

print("Setting calcTimeStep in EndGameVM")
local match <const> = match
local calcTimeStep <const> = CalcTimeStep
local tileSize <const> = tileSize
local PlatformId <const> = "endGamePlatform"
local BarrierId <const> = "endGameBarrier"
local AirlockLId <const> = "endGameAirlockL"
local AirlockRId <const> = "endGameAirlockR"
local targetPlanePosX <const> = 200
local loadPlaneDurationMs <const> = 500
local returnPlatformDurationMs <const> = loadPlaneDurationMs
local airlockCamOverrideY = 10 * tileSize
local directorIntroLaunchButtonEnabledOffset = 1

local states = enum({
    "LoadPlane", "ReturnPlatform", "DirectorIntro", "DirectorLaunchInitiated",
    "LiftOff", "OpenAirlock", "FlyAway"
})

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)

    -- setup start of EndGame scene
    keys = {true,true,true,true} -- have? bool
    camPos[1] = 35
    camPos[2] = 210
    planePos[1] = 59
    planePos[2] = 224
    planePos[3] = 4
    planePos[4] = 4
    planeRot = 18
    self.planePosX = planePos[1]*tileSize + planePos[3]
    self.planePosY = planePos[2]*tileSize + planePos[4]
    self.launchTowerY = self.planePosY - 58 + 24

    local findSpecial = function(targetId)
        return match(specialT, function(item) return item.id == targetId end)
    end
    self.platform = findSpecial(PlatformId)
    self.barrier = findSpecial(BarrierId)
    self.airlockL = findSpecial(AirlockLId)
    self.airlockR = findSpecial(AirlockRId)

    self.airLockROverridePos = 9*tileSize
    self.crankFrame = 1
    self.launchButtonFrame = 1
    self.numCrankFrames = 0 -- set by View
    self.maxAirlockRPos = self.airlockR.pos
    self.origPlatformX = self.platform.x
    self.closedBarrierPos = self.barrier.pos
    self.platformOffsetX = self.platform.x*tileSize - self.planePosX

    self.liftOffSpeed = 0.2

    self:setState(states.LoadPlane)
end

function EndGameViewModel:initState(state)
    print("init state", state.name)
    if state == states.LoadPlane then
        self.planeAnimator = gfx.animator.new(loadPlaneDurationMs, self.planePosX, targetPlanePosX)
        self.controlRoomAnimator = gfx.animator.new(loadPlaneDurationMs, -545, 0)
        self.camOverrideY = camPos[2]*tileSize+camPos[4] + 16
    elseif state == states.DirectorIntro then
        self:startVideo("video/director_intro_2")
    elseif state == states.DirectorLaunchInitiated then
        self:startVideo("video/director_t_minus_ten")
        self.launchTime = getCurrentTime() + 6 -- starting countdown, launch 12 seconds into the future
    elseif state == states.LiftOff then
        self.launchButtonFrame = 1
        self.rocketExhaustLoop = loop.new(66, rocketExhaustStartImgTable, false)
        self.exhaustLoopOffsetX = -6
        self.exhaustLoopOffsetY = 106
        self.camOverrideY = camPos[2]*tileSize+camPos[4]
    elseif state == states.OpenAirlock then
        self.camOverrideY = airlockCamOverrideY
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
    musicManager:stop()
    self.platform.arrows = false
end

function EndGameViewModel:onEnded()
    popScreen() -- pop self
    pushScreen(FlyToCreditsScreen(
        {
            ["loop"] = self.rocketExhaustLoop,
            ["offsetX"] = self.exhaustLoopOffsetX,
            ["offsetY"] = self.exhaustLoopOffsetY
        }
    ))
end

function EndGameViewModel:startVideo(path)
    require("lua/video-player/VideoPlayerScreen")
    if self.videoViewModel then
        self.videoViewModel:destroy()
    end
    self.videoViewModel = VideoViewModel(path)
    self.videoPlayerView = VideoPlayerView(self.videoViewModel)
    self.videoViewModel.offsetX = 14
    self.videoViewModel.offsetY = 86
    self.videoPlayerView:resume()
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
        self:setState(states.DirectorIntro)
    end
end

function EndGameViewModel:DirectorIntroUpdate()
    if self.videoViewModel:getOffset() > directorIntroLaunchButtonEnabledOffset and not self.launchButtonEnabled then
        self.launchButtonEnabled = true
        clickSamplePlayer:play(1,2.0)
        self.launchButtonFrame = 2
    end
    if self.launchButtonEnabled then
        if justPressed(playdate.kButtonA) then
            clickSamplePlayer:play()
            self.launchButtonFrame = 3
        elseif justReleased(playdate.kButtonA) then
            self.launchButtonFrame = 1
            clickSamplePlayer:play(1, -1.0)
            self:setState(states.DirectorLaunchInitiated)
        end
    end
end

function EndGameViewModel:DirectorLaunchInitiatedUpdate()
    if self:getLaunchTimeOffset() >= 0 then
        self:setState(states.LiftOff)
    -- music track contains countdown which reaches 0 at t = 7s
    elseif self:getLaunchTimeOffset() >= -7 and not musicManager:isPlaying() then
        musicManager:play("music/the-countdown.mp3")
    end
end

function EndGameViewModel:LiftOffUpdate()
    if not self.rocketExhaustLoop:isValid() then
        -- liftoff animation finished
        -- create the continuous burn loop, which is always valid
        self.exhaustLoopOffsetX = self.exhaustLoopOffsetX + 28
        self.exhaustLoopOffsetY = self.exhaustLoopOffsetY + 7
        self.rocketExhaustLoop = loop.new(66, rocketExhaustBurnImgTable, true)
    end
    self.planePosY = self.planePosY - self.liftOffSpeed
    self.liftOffSpeed = self.liftOffSpeed * 1.01 -- accelerate
    if self.liftOffSpeed > 0.8 then
        if self.liftOffSpeed < 4 then
            self.liftOffCamSpeed = 2
        else
            self.liftOffCamSpeed = roundToNearest(self.liftOffSpeed, 2) + 2
        end
        self.camOverrideY = self.camOverrideY - self.liftOffCamSpeed
        self.camOverrideY = clamp(self.camOverrideY, airlockCamOverrideY,  self.camOverrideY)
    end
    if self:getLaunchTimeOffset() > 7.5 and not self.liftOffStartedAirlockVideo then
        self:startVideo("video/director_open_airlock_3")
        self.liftOffStartedAirlockVideo = true
    end
    if self.camOverrideY == airlockCamOverrideY then
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
    self.crankFrame = luaMod((self.crankFrame + changeDirection), self.numCrankFrames)
    self.airLockROverridePos = clamp(self.airLockROverridePos + changeDirection * 2, 0, self.maxAirlockRPos)

end

function EndGameViewModel:FlyAwayUpdate()
    self.planePosY = self.planePosY - self.liftOffSpeed
    if self.planePosY < 0 then
        self:onEnded()
    end
end

--- negative when launch is in future
function EndGameViewModel:getLaunchTimeOffset()
    if not self.launchTime then
        return nil
    end

    return getCurrentTime() - self.launchTime
end

local stateUpdaters = {
    [states.LoadPlane] = EndGameViewModel.LoadPlaneUpdate,
    [states.ReturnPlatform] = EndGameViewModel.ReturnPlatformUpdate,
    [states.DirectorIntro] = EndGameViewModel.DirectorIntroUpdate,
    [states.DirectorLaunchInitiated] = EndGameViewModel.DirectorLaunchInitiatedUpdate,
    [states.LiftOff] = EndGameViewModel.LiftOffUpdate,
    [states.OpenAirlock] = EndGameViewModel.OpenAirlockUpdate,
    [states.FlyAway] = EndGameViewModel.FlyAwayUpdate,
}

function EndGameViewModel:update()
    calcTimeStep()
    if self.videoViewModel then
        self.videoViewModel:update()
    end
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
