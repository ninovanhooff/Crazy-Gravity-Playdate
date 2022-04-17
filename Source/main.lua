import "CoreLibs/timer"
import "lua/util.lua"
import "lua/level.lua"
import "lua/init.lua"
import "lua/gameScreen.lua"
import "lua/start/startScreen.lua"
import "lua/systemMenu.lua"

local gfx <const> = playdate.graphics
local updateBlinkers <const> = gfx.animation.blinker.updateAll
local updateTimers <const> = playdate.timer.updateTimers

local activeScreen = StartScreen()

function playdate.update()
    gfx.pushContext()
        activeScreen:update()
    gfx.popContext() -- reset any drawing state modifications
    playdate.drawFPS(0,0)
    updateBlinkers()
    updateTimers()
end

function playdate.debugDraw()
    if Debug then
        activeScreen:debugDraw()
    end
end
