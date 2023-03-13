import "drawUtil"
import "gameHUD"
import "specialsView"
import "gameView"
import "specialsViewModel"
import "gameViewModel"
import "gameInputs"

local screenWidth <const> = screenWidth
local screenHeight <const> = screenHeight
local ResourceLoader <const> = ResourceLoader
local cropImage <const> = cropImage

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

function GameScreen:gameWillPause()
    -- todo create lib out of navifator and prevent lockScreen from triggering gameWillPause
    local minimapImage = ResourceLoader:getImage(levelPath() .. "_minimap")
    local srcW, srcH = minimapImage:getSize()
    local xPos, yPos = 0,0
    if srcW < screenWidth then
        xPos = (screenWidth - srcW) / 2
    end

    if srcH < screenHeight then
        yPos = (screenHeight - srcH) / 2
    end

    setMenuImage(
        cropImage(
            minimapImage,
            400, 240,
            0, 0,
            xPos, yPos
        ),
        200
    )
end

function GameScreen:debugDraw()
    renderGameDebug()
end
