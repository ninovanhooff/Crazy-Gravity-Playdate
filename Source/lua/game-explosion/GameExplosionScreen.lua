import "GameExplosion"

local menu <const> = playdate.getSystemMenu()
local gameHUD <const> = gameHUD
local renderSelfRightTooltip <const> = RenderSelfRightTooltip

class("GameExplosionScreen").extends(Screen)

function GameExplosionScreen:init(calcPlane, calcGameCam)
    GameExplosionScreen.super.init(self)
    self.calcPlane = calcPlane
    self.calcGameCam = calcGameCam
    if Sounds then thrust_sound:stop() end
    thrust = 0
    local scrimHeight = hudY
    if extras[2]==1 then
        scrimHeight = screenHeight
    end
    explosion = GameExplosion(scrimHeight)
end

function GameExplosionScreen:update()
    if inputManager:isInputJustPressed(Actions.Throttle) and explosion then
        explosion:fastForward()
    end
    if explosion and explosion:update() then
        self.calcPlane() -- keep updating plane as a ghost target for camera
        self.calcGameCam()
        for _,item in ipairs(specialT) do
            specialCalcT[item.sType](item)
        end
        RenderGame()
        if collision == CollisionReason.OverSpeed then
            gameHUD:renderOverSpeedTooltip()
        elseif collision == CollisionReason.Rotation then
            renderSelfRightTooltip()
        end
    else
        popScreen()
        if explosion then
            DecreaseLife()
        end
    end
end

function GameExplosionScreen:pause()
    if Sounds then thrust_sound:stop() end
end

function GameExplosionScreen:resume()
    menu:addMenuItem("Settings", function()
        require "lua/settings/SettingsScreen"
        pushScreen(SettingsScreen())
    end)
    menu:addMenuItem("Quit level", function()
        popScreen() -- remove self
        popScreen() -- remove gameScreen
    end)
    menu:addMenuItem("Restart level", function()
        popScreen() -- remove self
        ResetGame()
    end)
end

function GameExplosionScreen:gameWillPause()
    SetGameMenuImage()
end

function GameExplosionScreen:destroy()
    self:pause()
end
