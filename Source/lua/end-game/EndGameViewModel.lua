import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("EndGameViewModel").extends()

function EndGameViewModel:init()
    EndGameViewModel.super.init(self)
    self.displayText = "Hello, this is EndGame screen"
end

function EndGameViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function EndGameViewModel:pause()
end

function EndGameViewModel:resume()

end
