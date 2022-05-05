import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB
local selectButtons <const> = playdate.kButtonLeft | playdate.kButtonRight

class("GameOverViewModel").extends()

function GameOverViewModel:init()
    self.title = "GAME OVER!"
    self.levelSelectSelected = false
    self.retrySelected = true
end

function GameOverViewModel:isRetrySelected()
    return self.retrySelected
end

function GameOverViewModel:isLevelSelectSelected()
    return not self.retrySelected
end

local function quitLevel()
    -- back to LevelSelect
    popScreen() -- (this) GameOverScreen
    popScreen() -- underlying GameScreen
end

local function retryGame()
    -- back to game
    popScreen()
end

function GameOverViewModel:update()
    if justPressed(selectButtons) then
        self.retrySelected = not self.retrySelected
    elseif justPressed(buttonA) then
        if self.retrySelected then
            retryGame()
        else
            quitLevel()
        end
    elseif justPressed(buttonB) then
        quitLevel()
    end
end
