import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local creditsSpeed <const> = 4

class("CreditsViewModel").extends()

function CreditsViewModel:init()
    CreditsViewModel.super.init(self)
    self.creditsY = 0
end

function CreditsViewModel:update()

    self.creditsY = self.creditsY - creditsSpeed

    if justPressed(buttonB) then
        popScreen()
    end
end

function CreditsViewModel:pause()
end

function CreditsViewModel:resume()
end
