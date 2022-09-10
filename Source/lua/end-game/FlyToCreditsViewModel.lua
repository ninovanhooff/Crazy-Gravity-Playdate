import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("FlyToCreditsViewModel").extends()

function FlyToCreditsViewModel:init()
    FlyToCreditsViewModel.super.init(self)
    self.displayText = "Hello, this is FlyToCredits screen"
end

function FlyToCreditsViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function FlyToCreditsViewModel:pause()
end

function FlyToCreditsViewModel:resume()
end
