import "CoreLibs/timer"
import "lua/util.lua"
import "lua/level.lua"
import "lua/init.lua"
import "lua/gameScreen.lua"
import "lua/start/StartScreen.lua"
import "lua/level-select/levelSelectScreen.lua"
import "lua/systemMenu.lua"

local gfx <const> = playdate.graphics
local updateBlinkers <const> = gfx.animation.blinker.updateAll
local updateTimers <const> = playdate.timer.updateTimers

local pendingNavigators = {}
local backStack = {}
local activeScreen

local function executePendingNavigators()
    if #pendingNavigators > 0 then
        for _, navigator in ipairs(pendingNavigators) do
            navigator()
        end
        pendingNavigators = {}
        local newPos = find(backStack, activeScreen)
        if activeScreen and newPos and newPos ~= #backStack then
            -- the activeScreen was moved from the top of the stack to another position
            printf("Pausing screen", activeScreen)
            activeScreen:pause()
        end
        activeScreen = backStack[#backStack]
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

function popScreen()
    table.insert(
        pendingNavigators,
        function()
            printf("Popping off backstack:", activeScreen)
            table.remove(backStack)
        end
    )
end

pushScreen(LevelSelectScreen())

function playdate.update()
    gfx.pushContext() --make sure we start the frame with a clean gfx state.
    executePendingNavigators()
    activeScreen:update()
    -- not popping Context because bug https://devforum.play.date/t/crash-when-using-pushcontext-together-with-coroutine-yield-simulator/5327
    playdate.drawFPS(0,0)
    updateBlinkers()
    updateTimers()
end

function playdate.debugDraw()
    if Debug then
        activeScreen:debugDraw()
    end
end
