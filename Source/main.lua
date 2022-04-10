import "util.lua"
import "level.lua"
import "game.lua"
import "gameViewModel.lua"
import "gameInputs.lua"
import "init.lua"
import "systemMenu.lua"

local gfx <const> = playdate.graphics
local calcTimeStep <const> = CalcTimeStep
local processInputs <const> = ProcessInputs
local renderGame <const> = RenderGame


local function startGame()
    local levelNumString = string.format("%02d", currentLevel)
    InitGame("levels/LEVEL" .. levelNumString .. ".pdz")
end

startGame()

function playdate.update()
    if kill == 1 then
        printf("Starting next level")
        kill = 0
        currentLevel = currentLevel + 1
        if currentLevel > numLevels then
            currentLevel = 1
        end
        startGame()
    end
    if not explosion then
        processInputs()
    end
    calcTimeStep()
    renderGame()
    playdate.drawFPS(0,0)
end

function playdate.debugDraw()
    if Debug then
        if collision then
            sprite:draw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3], (planePos[2]-camPos[2])*8+planePos[4]-camPos[4], unFlipped, 8*23, 489, 23, 23)
        end
        --- plane collision
        local colOffX = (planePos[1]-camPos[1])*8-camPos[3]
        local colOffY = (planePos[2]-camPos[2])*8-camPos[4]
        gfx.drawLine(colOffX+colT[1],colOffY+colT[2],colOffX+colT[3],colOffY+colT[4])
        gfx.drawLine(colOffX+colT[3],colOffY+colT[4],colOffX+colT[5],colOffY+colT[6])
        gfx.drawLine(colOffX+colT[5],colOffY+colT[6],colOffX+colT[1],colOffY+colT[2])
    end
end
