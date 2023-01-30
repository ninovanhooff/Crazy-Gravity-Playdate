import "gameHUD"
import "specialsView"
import "gameView"
import "specialsViewModel"
import "gameViewModel"
import "gameInputs"

local menu <const> = playdate.getSystemMenu()
local calcTimeStep <const> = CalcTimeStep
local processInputs <const> = ProcessInputs
local renderGame <const> = RenderGame
local renderGameDebug <const> = RenderGameDebug
local isThrottleJustPressed <const> = isThrottleJustPressed
local options <const> = GetOptions()

colorT = {"red","green","blue","yellow"}
sumT = {0,8,24}
greySumT = {-1,56,32,0} -- -1:unused


class("GameScreen").extends(Screen)

function GameScreen:init(levelPathOrLevelNumber, challengeIdx)
    GameScreen.super.init(self)
    InitGame(levelPathOrLevelNumber, challengeIdx)
end

function GameScreen:pause()
    playdate.display.setRefreshRate(frameRate)
    if Sounds then thrust_sound:stop() end
    soundManager:stop()
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
    playdate.display.setRefreshRate(options:getGameFps())

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

end

function GameScreen:update()
    if isThrottleJustPressed() then
        gamePaused = false
    end
    if not gamePaused then
        processInputs()
        calcTimeStep()
    end
    renderGame()
end

function GameScreen:debugDraw()
    renderGameDebug()
end
