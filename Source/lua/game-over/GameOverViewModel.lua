local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB
local buttonLeft <const> = playdate.kButtonLeft
local buttonRight <const> = playdate.kButtonRight

class("GameOverViewModel").extends()

GAME_OVER_CONFIGS = enum({"GAME_OVER_NO_SKIP", "GAME_OVER_MAY_SKIP", "LEVEL_CLEARED"})

function GameOverViewModel:init(config)
    GameOverViewModel.super.init(self)
    if config == GAME_OVER_CONFIGS.GAME_OVER_NO_SKIP then
        self.title = "GAME OVER!"
        self.selectedButtonIdx = 2
        self.buttonSourceOffsetsX = {192, 240}
    elseif config == GAME_OVER_CONFIGS.GAME_OVER_MAY_SKIP then
        self.title = "GAME OVER!"
        self.selectedButtonIdx = 2 -- default selection is retry
        -- last button is next level button
        self.buttonSourceOffsetsX = {192, 240, 288}
    elseif config == GAME_OVER_CONFIGS.LEVEL_CLEARED then
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
        ui_confirm:play()
        if self.selectedButtonIdx == 1 then
            quitLevel()
        elseif self.selectedButtonIdx == 2 then
            retryGame()
        elseif self.selectedButtonIdx == 3 then
            if not records[currentLevel] then
                updateRecords(currentLevel, SKIPPED_RECORD)
            end
            nextLevel()
        end
    elseif justPressed(buttonB) then
        ui_cancel:play()
        quitLevel()
    end

    self.selectedButtonIdx = clamp(self.selectedButtonIdx, 1, #self.buttonSourceOffsetsX)
end
