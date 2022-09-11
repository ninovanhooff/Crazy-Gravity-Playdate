import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("CreditsViewModel").extends()

function CreditsViewModel:init()
    CreditsViewModel.super.init(self)
end

function CreditsViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function CreditsViewModel:pause()
end

function CreditsViewModel:resume()
end
