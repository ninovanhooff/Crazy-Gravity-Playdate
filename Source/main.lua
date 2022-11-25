import "lua/util"

local run <const> = playdate.file.run

local requiredPaths <const> = {}
local printT <const> = printT

--- @param sourcePath path relative to source directory
function require(sourcePath)
    if requiredPaths[sourcePath] then
        printT("SKIP: Already required", sourcePath)
        return
    end
    printT("RUN " .. sourcePath)
    requiredPaths[sourcePath] = true
    return run(sourcePath)
end

printT("hoi")
import "CoreLibs/object"
import "CoreLibs/timer"
import "CoreLibs/animation"
import "CoreLibs/animator"
import "CoreLibs/easing"
import "CoreLibs/utilities/sampler"
import "CoreLibs/ui"
import "CoreLibs/graphics"
import "lua/screen"
import "lua/enum"
import "lua/level"
import "lua/init"

local gfx <const> = playdate.graphics
local updateBlinkers <const> = gfx.animation.blinker.updateAll
local updateTimers <const> = playdate.timer.updateTimers

local pendingNavigators = {}
local backStack = {}
local activeScreen

-- note: GC might still be turned off temporarily in gameView
playdate.setMinimumGCTime(2)

local function executePendingNavigators()
    if #pendingNavigators > 0 then
        for _, navigator in ipairs(pendingNavigators) do
            navigator()
        end
        pendingNavigators = {}
        local newPos = find(backStack, activeScreen)
        if activeScreen and newPos and newPos ~= #backStack then
            -- the activeScreen was moved from the top of the stack to another position
            printT("Pausing screen", activeScreen.className, activeScreen)
            activeScreen:pause()
        end
        if #backStack < 1 then
            printT("ERROR: No active screen, adding Start Screen")
            require "lua/start/startScreen"
            table.insert(backStack, StartScreen())
        end
        activeScreen = backStack[#backStack]
        printT("Resuming screen", activeScreen.className, activeScreen)
        playdate.setCollectsGarbage(true) -- prevent permanently disabled GC by previous Screen
        activeScreen:resume()
    end
end

function pushScreen(newScreen)
    table.insert(
        pendingNavigators,
        function()
            printT("Adding to backstack", newScreen.className, newScreen)
            table.insert(backStack, newScreen)
        end
    )
end

local function popScreenImmediately()
    printT("Popping off backstack:", activeScreen.className, activeScreen)
    table.remove(backStack)
    activeScreen:destroy()
end

function popScreen()
    table.insert(pendingNavigators, popScreenImmediately)
end

function clearNavigationStack()
    table.insert(
        pendingNavigators,
        function()
            printT("Clearing navigationStack", activeScreen.className, activeScreen)
            while #backStack > 0 do
                activeScreen = backStack[#backStack]
                popScreenImmediately()
            end
        end
    )
end

require "lua/start/startScreen"
pushScreen(StartScreen())


if playdate.file.exists("levels/temp.pdz") then
    GetOptions():apply() -- load all sounds required for game
    require "lua/gameScreen"
    pushScreen(GameScreen("levels/temp", 1))
end

--require("lua/end-game/EndGameScreen") -- imports and FlyTo ScreditsScreen CreditsScreen
--pushScreen(FlyToCreditsScreen())

--require("lua/video-player/VideoPlayerScreen")
--pushScreen(VideoPlayerScreen(
--    "video/congratulations",
--    function()
--        return EndGameScreen()
--    end
--))
--pushScreen(LevelSelectScreen())
--pushScreen(GameScreen(levelPath(1), 1))

function playdate.update()
    gfx.pushContext() --make sure we start the frame with a clean gfx state.
    executePendingNavigators()
    activeScreen:update()
    gfx.popContext()
    if Debug then
        playdate.drawFPS(0,0)
    end
    updateBlinkers()
    updateTimers()
end

function playdate.debugDraw()
    if Debug then
        activeScreen:debugDraw()
    end
end

function playdate.keyPressed(key)
    printT("Pressed " .. key .. " key")
    if key == "r" then
        Debug = false
    end
    if key == "e" then
        Debug = true
    end
end
