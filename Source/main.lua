import "CoreLibs/timer"
import "lua/util.lua"
import "lua/level.lua"
import "lua/init.lua"
import "lua/gameScreen.lua"
import "lua/start/StartScreen.lua"
import "lua/level-select/levelSelectScreen.lua"
import "lua/systemMenu.lua"

local menu <const> = playdate.getSystemMenu()
local gfx <const> = playdate.graphics
local updateBlinkers <const> = gfx.animation.blinker.updateAll
local updateTimers <const> = playdate.timer.updateTimers

local pendingNavigators = {}
local backStack = {}
local activeScreen

local function executePendingNavigators()
    if #pendingNavigators > 0 then
        if activeScreen then
            printf("Pausing screen", activeScreen)
            activeScreen:pause()
        end
        for _, navigator in ipairs(pendingNavigators) do
            navigator()
        end
        pendingNavigators = {}
        activeScreen = backStack[#backStack]
        gfx.clear(gfx.kColorWhite)
        printf("Resuming screen", activeScreen)
        activeScreen:resume()
    end
end

function pushScreen(newScreen)
    table.insert(
        pendingNavigators,
        function()
            printf("Adding to backstack", newScreen)
            table.insert(backStack, newScreen)
        end
    )
end

function popBackStack()
    table.insert(
        pendingNavigators,
        function()
            printf("Popping off backstack:", activeScreen)
            table.remove(backStack)
        end
    )
end

pushScreen(StartScreen())

function playdate.update()
    executePendingNavigators()
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
