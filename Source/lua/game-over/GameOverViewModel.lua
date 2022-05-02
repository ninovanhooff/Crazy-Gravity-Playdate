import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB

class("GameOverViewModel").extends()

function GameOverViewModel:init()
    self.displayText = "Hello, this is GameOver screen"
end

function GameOverViewModel:update()
    if justPressed(buttonA) then
        -- back to game
        popScreen()
    elseif justPressed(buttonB) then
        -- back to LevelSelect
        popScreen() -- (this) GameOverScreen
        popScreen() -- underlying GameScreen
    end
end

function GameOverViewModel:pause()
end

function GameOverViewModel:resume()
end
