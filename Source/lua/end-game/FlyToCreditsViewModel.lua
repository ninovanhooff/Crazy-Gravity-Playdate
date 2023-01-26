import "../credits/CreditsScreen.lua"

local tileSize <const> = tileSize
local planeOffset <const> = 7 * tileSize

local rocketEngineStop = GetResourceLoader():getSound("sounds/rocket_engine_stop")

class("FlyToCreditsViewModel").extends()

FlyToCreditsViewModel.bgTypes = enum({"surface", "asteroids", "stars"})

function FlyToCreditsViewModel:init(loopSpecs)
    FlyToCreditsViewModel.super.init(self)
    self.exhaustLoopSpecs = loopSpecs
    self:resetRocketShip()
    self.rocketShipHeight = 0 -- set by View
    self.bgType = FlyToCreditsViewModel.bgTypes.surface
    self.swish_sound = GetResourceLoader():getSound("sounds/hollow-swish-airy-short.wav")
end

function FlyToCreditsViewModel:update()
    if self.planeY < -self.rocketShipHeight then
        if self.bgType == FlyToCreditsViewModel.bgTypes.surface then
            self.bgType = FlyToCreditsViewModel.bgTypes.asteroids
            self:resetRocketShip()
            -- create the CreditsScreen while nothing is moving on screen, so no yank is visible
            self.cachedCreditsScreen = CreditsScreen()
        elseif self.bgType == FlyToCreditsViewModel.bgTypes.asteroids then
            -- enter hyperspace
            self.bgType = FlyToCreditsViewModel.bgTypes.stars
            self:resetRocketShip()
            self.swish_sound:play()
        else
            popScreen()
            pushScreen(self.cachedCreditsScreen)
        end
    end

    if self.bgType == FlyToCreditsViewModel.bgTypes.surface then
        self.planeY = self.planeY - 4
    else
        self.planeY = self.planeY - 3
    end
    if self.bgType == FlyToCreditsViewModel.bgTypes.stars then
        self.rocketShipY = self.rocketShipY - 1
    else
        self.rocketShipY = self.planeY - planeOffset
    end
    if self.bgType == FlyToCreditsViewModel.bgTypes.asteroids and self.planeY < 150 and self.exhaustLoopSpecs then
        self.exhaustLoopSpecs.audioPlayer:stop()
        rocketEngineStop:play()
        self.exhaustLoopSpecs = nil
    end
end

function FlyToCreditsViewModel:resetRocketShip()
    self.rocketShipY = screenHeight
    self.planeY = self.rocketShipY + planeOffset
end

function FlyToCreditsViewModel:pause()
end

function FlyToCreditsViewModel:resume()
end
