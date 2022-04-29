import "settings.lua"
import "drawUtil.lua"
import "specialsView.lua"
import "specialsViewModel.lua"
import "gameView.lua"
import "gameInputs.lua"
import "gameViewModel.lua"

local calcTimeStep <const> = CalcTimeStep
local processInputs <const> = ProcessInputs
local renderGame <const> = RenderGame
local renderGameDebug <const> = RenderGameDebug

colorT = {"red","green","blue","yellow"}
sumT = {0,8,24}
greySumT = {-1,56,32,0} -- -1:unused

import "CoreLibs/object"
import "util.lua"
import "screen.lua"

class("GameScreen").extends(Screen)

function GameScreen:init()
    InitGame(levelPath())
end

function GameScreen:update()
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
end

function GameScreen:debugDraw()
    renderGameDebug()
end
