import "lua/util"

local playdate <const> = playdate
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
local navigator <const> = import "lua/navigator"
local currentTime <const> = playdate.sound.getCurrentTime
local targetFrameTime <const> = 1/frameRate



local gfx <const> = playdate.graphics
local updateBlinkers <const> = gfx.animation.blinker.updateAll
local updateTimers <const> = playdate.timer.updateTimers

-- note: GC might still be turned off temporarily in gameView
playdate.setMinimumGCTime(2)


require "lua/start/startScreen"
pushScreen(StartScreen())

if playdate.file.exists("levels/temp.pdz") then
    GetOptions():apply() -- load all sounds required for game
    require "lua/gameScreen"
    pushScreen(GameScreen("levels/temp", 1))
end

function playdate.update()
    local frameStart = currentTime()
    gfx.pushContext() --make sure we start the frame with a clean gfx state.
    navigator:executePendingNavigators()
    navigator:updateActiveScreen()
    gfx.popContext()
    if Debug then
        playdate.drawFPS(0,0)
    end
    updateBlinkers()
    updateTimers()
    if Debug then
        local frameTime = (currentTime() - frameStart)
        if frameTime > targetFrameTime then
            print("FRAMETIME", frameTime*1000)
        end
    end
end

function playdate.gameWillPause()  navigator:pause() end
function playdate.deviceWillLock() navigator:pause() end
function playdate.gameWillResume() navigator:resume() end
function playdate.deviceDidUnlock() navigator:resume() end

function playdate.debugDraw()
    if Debug then
        navigator:debugDraw()
    end
end

function playdate.keyPressed(key)
    if key == "h" then
        Debug = true
    end
    if key == "j" then
        Debug = false
    end
end
