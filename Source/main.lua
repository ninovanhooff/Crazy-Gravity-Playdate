import "CoreLibs/utilities/where"
import "util.lua"
import "level.lua"
import "game.lua"
import "gameViewModel.lua"
import "init.lua"
import "systemMenu.lua"

local gfx = playdate.graphics


function startGame()
    InitGame("levels/LEVEL03.pdz")
end

startGame()

gfx.setColor(gfx.kColorBlack)

function playdate.update()
    ProcessInputs()
    CalcTimeStep()
    RenderGame()
    playdate.drawFPS(0,0)
end

function playdate.debugDraw()
    if Debug then
        if collision then
            pgeDraw(470,hudY,8,8,64,338,8,8)
        end
        --- plane collision
        local colOffX = (planePos[1]-camPos[1])*8-camPos[3]
        local colOffY = (planePos[2]-camPos[2])*8-camPos[4]
        gfx.drawLine(colOffX+colT[1],colOffY+colT[2],colOffX+colT[3],colOffY+colT[4])
        gfx.drawLine(colOffX+colT[3],colOffY+colT[4],colOffX+colT[5],colOffY+colT[6])
        gfx.drawLine(colOffX+colT[5],colOffY+colT[6],colOffX+colT[1],colOffY+colT[2])
    end
end
