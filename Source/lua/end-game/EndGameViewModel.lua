require "lua/gameScreen"
import "FlyToCreditsScreen"

local gfx <const> = playdate.graphics
local snd <const> = playdate.sound
local animator <const> = playdate.graphics.animator
local crankIndicator <const> = playdate.ui.crankIndicator
local monitorEasing <const> = playdate.easingFunctions.inOutCubic
local soundManager <const> = soundManager
local monitorDuration <const> = 600
local getCurrentTime <const> = snd.getCurrentTime
local pressed <const> = playdate.buttonIsPressed
local justPressed <const> = playdate.buttonJustPressed
local justReleased <const> = playdate.buttonJustReleased
local loop <const> = gfx.animation.loop
local rocketExhaustBurnImgTable = gfx.imagetable.new("images/rocket_ship_burn")
local rocketExhaustStartImgTable = gfx.imagetable.new("images/rocket_ship_burn_start")

local resourceLoader <const> = GetResourceLoader()
local conveyorBeltPlayer = resourceLoader:getSound("sounds/conveyor_belt")

local rocketEngineStart <const> = resourceLoader:getSound("sounds/rocket_engine_start")
local rocketEngineLoopSamplePlayer <const> = resourceLoader:getSound("sounds/rocket_engine_loop")
local barrierPlayer = soundManager.sounds.barrier.player
assert(barrierPlayer)

local clickSamplePlayer = resourceLoader:getSound("sounds/launch_control_click")
assert(clickSamplePlayer)

local getCrankChange <const> = playdate.getCrankChange
local floor <const> = math.floor
local abs <const> = math.abs
local round <const> = round
local clamp <const> = clamp
local musicManager <const> = musicManager

local match <const> = match
local calcTimeStep <const> = CalcTimeStep
local tileSize <const> = tileSize
local PlatformId <const> = "endGamePlatform"
local BarrierId <const> = "endGameBarrier"
local AirlockLId <const> = "endGameAirlockL"
local AirlockRId <const> = "endGameAirlockR"
local targetPlanePosX <const> = 200
local loadPlaneDurationMs <const> = 5000--5000
local returnPlatformDurationMs <const> = loadPlaneDurationMs
local airlockCamOverrideY <const> = 10 * tileSize
local directorIntroLaunchButtonEnabledDelay <const> = 11--11
local launchInitiatedLiftOffDelay <const> = 12--12 -- starting countdown, launch 12 seconds into the future
local chargingSpeed <const> = 0.01--0.01

local states = enum({
    "LoadPlane", "ReturnPlatform", "DirectorIntro", "DirectorLaunchInitiated",
    "LiftOff", "OpenAirlock", "FlyAway"
})

local openAirlockStates = enum({"WaitForCrank", "DeployCrank", "Charge", "PowerIncorrect", "PowerCorrect"})

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)

    self.batteryProgress = 0
    self.batteryMonitorAnimator = nil

    -- setup start of EndGame scene
    keys = {true,true,true,true} -- have? bool
    camPos[1] = 35
    camPos[2] = 210
    planePos[1] = 59
    planePos[2] = 224
    planePos[3] = 0
    planePos[4] = 4
    planeRot = 18
    self.planePosX = planePos[1]*tileSize + planePos[3]
    self.planePosY = planePos[2]*tileSize + planePos[4]
    self.launchTowerY = self.planePosY - 58 + 24

    local findSpecial = function(targetId)
        return match(specialT, function(item) return item.id == targetId end)
    end
    self.platform = findSpecial(PlatformId)
    --- the barrier that separates the launch shaft from the rest of the level
    self.barrier = findSpecial(BarrierId)
    self.airlockL = findSpecial(AirlockLId)
    self.airlockR = findSpecial(AirlockRId)

    self.openAirlockBatteryBlinker = gfx.animation.blinker.new()
    self.airLockROverridePos = 8*tileSize
    self.crankFrame = 1
    self.launchButtonFrame = 1
    self.numCrankEnterFrames = 11
    self.numCrankLoopFrames = 6
    self.numCrankFrames = self.numCrankEnterFrames + self.numCrankLoopFrames
    self.maxAirlockRPos = self.airlockR.pos
    self.origPlatformX = self.platform.x
    self.closedBarrierPos = self.barrier.pos
    self.platformOffsetX = self.platform.x*tileSize - self.planePosX

    self.liftOffSpeed = 0.2 -- 0.2

    self:setState(states.LoadPlane)
end

function EndGameViewModel:updateEngineVolume()
    local rocketShipScreenY = floor(self.planePosY - 7*tileSize - camPos[2]*tileSize-camPos[4])
    local engineVolume = clamp(1-((rocketShipScreenY-50) / 250), 0, 1)
    rocketEngineLoopSamplePlayer:setVolume(engineVolume)
end

function EndGameViewModel:initState(state)
    print("init EndGame state", state.name)
    if state == states.LoadPlane then
        self.planeAnimator = gfx.animator.new(loadPlaneDurationMs, self.planePosX, targetPlanePosX)
        self.controlRoomAnimator = gfx.animator.new(loadPlaneDurationMs, -545, 0)
        self.camOverrideY = camPos[2]*tileSize+camPos[4] + 16
        conveyorBeltPlayer:play()
    elseif state == states.ReturnPlatform then
        conveyorBeltPlayer:stop()
        conveyorBeltPlayer:setPlayRange(1,115000) -- do not play clamp / lock / thud
        conveyorBeltPlayer:play()
    elseif state == states.DirectorIntro then
        -- prevent obstacle sounds from playing
        soundManager.enabled = false
        self:startVideo("video/director_intro_2")
    elseif state == states.DirectorLaunchInitiated then
        self:startVideo("video/director_t_minus_ten")
        self.launchTime = getCurrentTime() + launchInitiatedLiftOffDelay
    elseif state == states.LiftOff then
        self.launchButtonFrame = 1
        self.rocketExhaustLoop = loop.new(66, rocketExhaustStartImgTable, false)
        self.exhaustLoopOffsetX = -6
        self.exhaustLoopOffsetY = 106
        self.camOverrideY = camPos[2]*tileSize+camPos[4]
        rocketEngineStart:setFinishCallback(function()
            rocketEngineLoopSamplePlayer:setVolume(0.5)
            rocketEngineLoopSamplePlayer:play(0)
        end)
        rocketEngineStart:play()
    elseif state == states.OpenAirlock then
        self.camOverrideY = airlockCamOverrideY
        self.batteryMonitorAnimator = animator.new(monitorDuration, 0, 1, monitorEasing)
        self.openAirlockState = openAirlockStates.WaitForCrank
    elseif state == states.FlyAway then
        self:startVideo("video/director_airlock_clear_2")
        self.liftOffSpeed = 4
        self.planePosY = (gameHeightTiles + 20) * tileSize -- a little outside frame, so it doesn't appear immediately when airlock is opened
    end
end

function EndGameViewModel:setState(state)
    self:initState(state)
    self.state = state
end

function EndGameViewModel:onEnded()
    popScreen() -- pop self
    pushScreen(FlyToCreditsScreen(
        {
            ["loop"] = self.rocketExhaustLoop,
            ["offsetX"] = self.exhaustLoopOffsetX,
            ["offsetY"] = self.exhaustLoopOffsetY,
            ["audioPlayer"] = rocketEngineLoopSamplePlayer
        }
    ))
end

function EndGameViewModel:startVideo(path)
    require("lua/video-player/VideoPlayerScreen")
    if self.videoViewModel then
        self.videoViewModel:destroy()
    end
    self.videoViewModel = VideoViewModel(path)
    self.videoViewModel:setVolume(resourceLoader.soundVolume)
    self.videoPlayerView = VideoPlayerView(self.videoViewModel)
    self.videoViewModel.offsetX = 14
    self.videoViewModel.offsetY = 86
    playdate.display.setRefreshRate(self.videoViewModel.framerate)
    self.videoPlayerView:resume()
end

function EndGameViewModel:LoadPlaneUpdate()
    if not self.planeAnimator:ended() then
        self.planePosX = floor(self.planeAnimator:currentValue())
        self.platform.x = (self.planePosX + self.platformOffsetX)/tileSize
    else
        playdate.wait(1500)
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
    if self.videoViewModel:getOffset() > directorIntroLaunchButtonEnabledDelay and not self.launchButtonEnabled then
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
        -- this moment is too epic not to play music.
        -- Therefore we play it at at least 20% volume; even if music is turned off in Settings
        -- This volume is not reset during the current run, but
        -- I'd say that's okay in this occasion.
        musicManager:setVolume(math.max(0.2, musicManager.volume))
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
            self.liftOffCamSpeed = round(self.liftOffSpeed, 2) + 2
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

    self:updateEngineVolume()
end

function EndGameViewModel:OpenAirlockUpdate()
    if self.openAirlockState == openAirlockStates.WaitForCrank then
        if playdate.isCrankDocked() then
            if justPressed(playdate.kButtonA | playdate.kButtonB) then
                -- going for button control.
                self.openAirlockState = openAirlockStates.Charge
            elseif not self.crankIndicatorStarted then
                crankIndicator:start()
                self.crankIndicatorStarted = true
            else
                crankIndicator:update()
            end
        else
            self.openAirlockState = openAirlockStates.DeployCrank
        end
    elseif self.openAirlockState == openAirlockStates.DeployCrank then
        self.crankFrame = self.crankFrame + 1
        if self.crankFrame > self.numCrankEnterFrames then
            self.openAirlockState = openAirlockStates.Charge
        end
    elseif self.openAirlockState == openAirlockStates.Charge then
        self.batteryProgress = self.batteryProgress * 0.993
        local changeDirection = 0 -- 1 for close, -1 for open
        if getCrankChange() > 5 or pressed(playdate.kButtonB) then
            changeDirection = 1
        elseif getCrankChange() < -5 or pressed(playdate.kButtonA) then
            changeDirection = -1
        end
        self.crankFrame = self.crankFrame + changeDirection
        if self.crankFrame <= self.numCrankEnterFrames then
            self.crankFrame = self.numCrankFrames
        elseif self.crankFrame > self.numCrankFrames then
            self.crankFrame = self.numCrankEnterFrames+1
        end
        self.batteryProgress = self.batteryProgress + changeDirection * chargingSpeed
        self.batteryProgress = clamp(self.batteryProgress, -1, 1)
        local batteryActivated = abs(self.batteryProgress) == 1
        if batteryActivated then
            if self.correctDirection == nil then
                -- Charge direction is the wrong one
                self.correctDirection = -self.batteryProgress
                self.openAirlockState = openAirlockStates.PowerIncorrect
                self.openAirlockBatteryBlinker:startLoop()
                barrierPlayer:play(0, 0.95)
            elseif self.correctDirection == self.batteryProgress then
                -- fully cranked to the correct direction
                self.openAirlockState = openAirlockStates.PowerCorrect
                self.openAirlockBatteryBlinker:startLoop()
                barrierPlayer:play(0, 1.05)
            end
        elseif self.correctDirection ~= nil and abs(self.batteryProgress) < 0.3 and self.videoViewModel.finished then
            self:startVideo("video/director_impact_imminent_2")
        end
    elseif self.openAirlockState == openAirlockStates.PowerIncorrect then
        self.batteryProgress = self.batteryProgress * 0.99
        self.airLockROverridePos = clamp(self.airLockROverridePos + 2, 0, self.maxAirlockRPos)
        if self.airLockROverridePos == self.maxAirlockRPos then
            self.openAirlockBatteryBlinker.loop = false
            self.openAirlockState = openAirlockStates.Charge
            barrierPlayer:stop()
            self:startVideo("video/director_other_way_2")
        end
    elseif self.openAirlockState == openAirlockStates.PowerCorrect then
        self.airLockROverridePos = clamp(self.airLockROverridePos - 2, 0, self.maxAirlockRPos)
        if self.airLockROverridePos == 0 then
            self.openAirlockBatteryBlinker.loop = false
            self.batteryMonitorAnimator = animator.new(monitorDuration, 1, 0, monitorEasing)
            barrierPlayer:stop()
            self:setState(states.FlyAway)
        end
    end
end

function EndGameViewModel:FlyAwayUpdate()
    self.planePosY = self.planePosY - self.liftOffSpeed
    if self.planePosY < 0 then
        -- the combination of transitioning to a new Screen + glitch is a bit too much
        self.videoViewModel.vcrFilterEnabled = false
        if self.videoViewModel.finished then
            self:onEnded()
        end
    end
    self:updateEngineVolume()
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
    self.platform.tooltip = nil
    if self.videoViewModel then
        self.videoViewModel:update()
    end
    stateUpdaters[self.state](self)
    local planePos <const> = planePos
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

function EndGameViewModel:resume()
    musicManager:fade(0)
    self.platform.arrows = false
end

function EndGameViewModel:pause()
    playdate.display.setRefreshRate(frameRate)
end

function EndGameViewModel:destroy()
    self.pause()
    self.videoPlayerView:destroy()
    soundManager.enabled = true
end
