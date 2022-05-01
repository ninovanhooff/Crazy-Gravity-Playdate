import "settings.lua"
import "drawUtil.lua"
import "specialsView.lua"
import "specialsViewModel.lua"
import "gameView.lua"
import "gameInputs.lua"
import "gameViewModel.lua"

local menu <const> = playdate.getSystemMenu()
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
import "level-select/levelSelectScreen.lua"

class("GameScreen").extends(Screen)

function GameScreen:init(levelPath)
    GameScreen.super.init(self)
    InitGame(levelPath)
end

function GameScreen:pause()
    if Sounds then thrust_sound:stop() end

    if self.backMenuItem then
        menu:removeMenuItem(self.backMenuItem)
        self.backMenuItem = nil
    end
end

function GameScreen:resume()
    self.backMenuItem = menu:addMenuItem("Level Select", function() popBackStack() end)
end

function GameScreen:update()
    if not explosion then
        processInputs()
    end
    calcTimeStep()
    renderGame()
end

function GameScreen:debugDraw()
    renderGameDebug()
end
