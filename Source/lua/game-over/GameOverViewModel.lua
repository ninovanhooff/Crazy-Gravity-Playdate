import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB

class("GameOverViewModel").extends()

function GameOverViewModel:init()
    self.title = "Game Over!"
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
