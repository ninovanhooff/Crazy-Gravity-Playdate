import "gameHUD"
import "specialsView"
import "gameMenuImage"
import "gameView"
import "specialsViewModel"
import "gameViewModel"
import "gameInputs"


local menu <const> = playdate.getSystemMenu()
local setMenuImage <const> = playdate.setMenuImage
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
end

function GameScreen:destroy()
    self:pause()
    setMenuImage(nil)
end

function GameScreen:resume()
    playdate.display.setRefreshRate(options:getGameFps())

    menu:addMenuItem("Settings", function()
        require "lua/settings/SettingsScreen"
        pushScreen(SettingsScreen())
    end)
    menu:addMenuItem("Quit level", function()
        popScreen()
    end)
    menu:addMenuItem("Restart level", function()
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

function GameScreen:gameWillPause()
    SetGameMenuImage()
end

function GameScreen:debugDraw()
    renderGameDebug()
end
