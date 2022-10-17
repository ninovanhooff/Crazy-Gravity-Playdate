import "drawUtil"
import "gameHUD"
import "specialsView"
import "specialsViewModel"
import "gameView"
import "gameInputs"
import "gameViewModel"

local menu <const> = playdate.getSystemMenu()
local calcTimeStep <const> = CalcTimeStep
local processInputs <const> = ProcessInputs
local renderGame <const> = RenderGame
local renderGameDebug <const> = RenderGameDebug

colorT = {"red","green","blue","yellow"}
sumT = {0,8,24}
greySumT = {-1,56,32,0} -- -1:unused


class("GameScreen").extends(Screen)

function GameScreen:init(levelPathOrLevelNumber, challengeIdx)
    GameScreen.super.init(self)
    InitGame(levelPathOrLevelNumber, challengeIdx)
end

function GameScreen:pause()
    gamePaused = true
    if Sounds then thrust_sound:stop() end

    if self.backMenuItem then
        menu:removeMenuItem(self.backMenuItem)
        self.backMenuItem = nil
    end
    if self.settingsMenuItem then
        menu:removeMenuItem(self.settingsMenuItem)
        self.settingsMenuItem = nil
    end
    if self.restartMenuItem then
        menu:removeMenuItem(self.restartMenuItem)
        self.restartMenuItem = nil
    end
end

function GameScreen:destroy()
    self:pause()
end

function GameScreen:resume()
    -- NOT setting gamePaused to false; requires button press
    self.settingsMenuItem = menu:addMenuItem("Settings", function()
        require "lua/settings/SettingsScreen"
        pushScreen(SettingsScreen())
    end)
    self.backMenuItem = menu:addMenuItem("Quit level", function()
        popScreen()
    end)
    self.restartMenuItem = menu:addMenuItem("Restart level", function()
        ResetGame()
    end)

    gameHUD:resume()
end

function GameScreen:update()
    if not gamePaused or isThrottleJustPressed() then
        gamePaused = false
        processInputs()
        calcTimeStep()
    end
    renderGame()
end

function GameScreen:debugDraw()
    renderGameDebug()
end
