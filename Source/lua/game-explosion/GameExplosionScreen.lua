import "CoreLibs/object"
import "../screen.lua"
import "GameExplosion.lua"

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
    if not inputManager:isInputJustPressed(InputManager.actionThrottle) and explosion and explosion:update() then
        self.calcPlane() -- keep updating plane as a ghost target for camera
        self.calcGameCam()
        for i,item in ipairs(specialT) do
            specialCalcT[item.sType](item,i)
        end
        RenderGame()
    else
        popScreen()
        if explosion then
            DecreaseLife()
        end
    end
end
