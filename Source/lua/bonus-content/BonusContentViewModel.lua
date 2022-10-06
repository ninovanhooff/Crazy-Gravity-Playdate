

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("BonusContentViewModel").extends()

function BonusContentViewModel:init()
    self.displayText = "TODO: A selection of 20-40 levels out of 278 fan-made Crazy Gravity levels, which are already converted to Gravity Express format but need some QA and TLC"
end

function BonusContentViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function BonusContentViewModel:pause()
end

function BonusContentViewModel:resume()
end
