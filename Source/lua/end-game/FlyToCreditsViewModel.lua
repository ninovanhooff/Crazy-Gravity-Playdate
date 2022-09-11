import "CoreLibs/object"
import "../credits/CreditsScreen.lua"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("FlyToCreditsViewModel").extends()

FlyToCreditsViewModel.bgTypes = enum({"asteroid", "deepSpace"})

function FlyToCreditsViewModel:init()
    FlyToCreditsViewModel.super.init(self)
    self:resetRocketShip()
    self.rocketShipHeight = 0 -- set by View
    self.bgType = FlyToCreditsViewModel.bgTypes.asteroid
end

function FlyToCreditsViewModel:update()
    self.rocketShipY = self.rocketShipY - 4
    if self.rocketShipY < -self.rocketShipHeight then
        if self.bgType == FlyToCreditsViewModel.bgTypes.asteroid then
            self.bgType = FlyToCreditsViewModel.bgTypes.deepSpace
            self:resetRocketShip()
        else
            popScreen()
            pushScreen(CreditsScreen())
        end
    end
end

function FlyToCreditsViewModel:resetRocketShip()
    self.rocketShipY = screenHeight
end

function FlyToCreditsViewModel:pause()
end

function FlyToCreditsViewModel:resume()
end
