local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB
local buttonLeft <const> = playdate.kButtonLeft
local buttonRight <const> = playdate.kButtonRight

class("GameOverViewModel").extends()

function GameOverViewModel:init(config)
    GameOverViewModel.super.init()
    if config == "GAME_OVER" then
        self.title = "GAME OVER!"
        self.selectedButtonIdx = 2
        self.buttonSourceOffsetsX = {192, 240}
    elseif config == "LEVEL_CLEARED" then
        self.title = "WELL DONE!"
        self.selectedButtonIdx = 3
        if currentLevel == numLevels then
            -- last button is start endgame button
            self.buttonSourceOffsetsX = {192, 240, 336}
        else
            -- last button is next level button
            self.buttonSourceOffsetsX = {192, 240, 288}
        end
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
    if currentLevel < numLevels then
        InitGame(currentLevel + 1, firstUnCompletedChallenge(currentLevel) or 1)
        popScreen()

    else
        -- initiate endgame
        require "lua/video-player/VideoPlayerScreen"
        require "lua/end-game/EndGameScreen"
        clearNavigationStack()
        pushScreen(VideoPlayerScreen(
            "video/congratulations",
            function()
                return EndGameScreen()
            end
        ))
    end

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

    self.selectedButtonIdx = clamp(self.selectedButtonIdx, 1, #self.buttonSourceOffsetsX)
end
