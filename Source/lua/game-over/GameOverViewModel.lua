import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB
local buttonLeft <const> = playdate.kButtonLeft
local buttonRight <const> = playdate.kButtonRight

class("GameOverViewModel").extends()

function GameOverViewModel:init(config)
    if config == "GAME_OVER" then
        self.title = "GAME OVER!"
        self.selectedButtonIdx = 2
        self.numButtons = 2
    elseif config == "LEVEL_CLEARED" then
        self.title = "WELL DONE!"
        self.selectedButtonIdx = 3
        self.numButtons = 3
    else
        error("Unknown Dialog config " .. config)
    end
end

local function quitLevel()
    -- back to LevelSelect
    popScreen() -- (this) GameOverScreen
    popScreen() -- underlying GameScreen
end

local function retryGame()
    ResetGame()
    -- back to game
    popScreen()
end

local function nextLevel()
    currentLevel = currentLevel + 1
    InitGame(levelPath())
    popScreen()
end

function GameOverViewModel:update()
    if justPressed(buttonLeft) then
        self.selectedButtonIdx = self.selectedButtonIdx - 1
    elseif justPressed(buttonRight) then
        self.selectedButtonIdx = self.selectedButtonIdx + 1
    elseif justPressed(buttonA) then
        if self.selectedButtonIdx == 1 then
            quitLevel()
        elseif self.selectedButtonIdx == 2 then
            retryGame()
        elseif self.selectedButtonIdx == 3 then
            nextLevel()
        end
    elseif justPressed(buttonB) then
        quitLevel()
    end

    self.selectedButtonIdx = clamp(self.selectedButtonIdx, 1, 3)
end
