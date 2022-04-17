import "lua/util.lua"
import "lua/level.lua"
import "lua/init.lua"
import "lua/gameScreen.lua"
import "lua/startScreen.lua"
import "lua/systemMenu.lua"

local gfx <const> = playdate.graphics
local planePos <const> = planePos
local camPos <const> = camPos
local updateBlinkers <const> = gfx.animation.blinker.updateAll

local activeScreen = StartScreen()

function playdate.update()
    activeScreen:update()
    playdate.drawFPS(0,0)
    updateBlinkers()
end

function playdate.debugDraw()
    if Debug then
        activeScreen:debugDraw()
    end
end
