import "CoreLibs/object"
import "../credits/CreditsScreen.lua"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("FlyToCreditsViewModel").extends()

function FlyToCreditsViewModel:init()
    FlyToCreditsViewModel.super.init(self)
    self.rocketShipY = screenHeight
    self.rocketShipHeight = 0 -- set by View
end

function FlyToCreditsViewModel:update()
    self.rocketShipY = self.rocketShipY - 4
    if self.rocketShipY < -self.rocketShipHeight then
        popScreen()
        pushScreen(CreditsScreen())
    end
end

function FlyToCreditsViewModel:pause()
end

function FlyToCreditsViewModel:resume()
end
