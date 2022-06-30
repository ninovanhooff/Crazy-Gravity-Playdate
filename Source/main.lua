import "CoreLibs/timer"
import "lua/util.lua"
import "lua/level.lua"
import "lua/init.lua"
import "lua/start/startScreen.lua"
import "lua/level-select/levelSelectScreen.lua"
import "lua/settings/SettingsScreen.lua"
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
            print("Pausing screen", activeScreen.className, activeScreen)
            activeScreen:pause()
        end
        if #backStack < 1 then
            print("ERROR: No active screen, adding Start Screen")
            table.insert(backStack, StartScreen())
        end
        activeScreen = backStack[#backStack]
        print("Resuming screen", activeScreen.className, activeScreen)
        activeScreen:resume()
    end
end

function pushScreen(newScreen)
    table.insert(
        pendingNavigators,
        function()
            print("Adding to backstack", newScreen.className, newScreen)
            table.insert(backStack, newScreen)
        end
    )
end

function popScreen()
    table.insert(
        pendingNavigators,
        function()
            print("Popping off backstack:", activeScreen.className, activeScreen)
            table.remove(backStack)
        end
    )
end

pushScreen(SettingsScreen())

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
