import "CoreLibs/object"
import "../credits/CreditsScreen.lua"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local tileSize <const> = tileSize
local planeOffset <const> = 8 * tileSize

class("FlyToCreditsViewModel").extends()

FlyToCreditsViewModel.bgTypes = enum({"surface", "asteroids", "stars"})

function FlyToCreditsViewModel:init()
    FlyToCreditsViewModel.super.init(self)
    self:resetRocketShip()
    self.rocketShipHeight = 0 -- set by View
    self.bgType = FlyToCreditsViewModel.bgTypes.surface
    self.swish_sound = playdate.sound.sampleplayer.new("sounds/hollow-swish-airy-short.wav")

end

function FlyToCreditsViewModel:update()
    if self.planeY < -self.rocketShipHeight then
        if self.bgType == FlyToCreditsViewModel.bgTypes.surface then
            self.bgType = FlyToCreditsViewModel.bgTypes.asteroids
            self:resetRocketShip()
        elseif self.bgType == FlyToCreditsViewModel.bgTypes.asteroids then
            -- enter hyperspace
            self.bgType = FlyToCreditsViewModel.bgTypes.stars
            self:resetRocketShip()
            self.swish_sound:play()
        else
            popScreen()
            pushScreen(CreditsScreen())
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
end

function FlyToCreditsViewModel:resetRocketShip()
    self.rocketShipY = screenHeight
    self.planeY = self.rocketShipY + planeOffset
end

function FlyToCreditsViewModel:pause()
end

function FlyToCreditsViewModel:resume()
end
