import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("GameOverViewModel").extends()

function GameOverViewModel:init()
    self.displayText = "Hello, this is GameOver screen"
end

function GameOverViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function GameOverViewModel:pause()
end

function GameOverViewModel:resume()
end
