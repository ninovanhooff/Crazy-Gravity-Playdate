import "CoreLibs/object"
import "../screen.lua"
import "EndGameView.lua"
import "EndGameViewModel.lua"

class("EndGameScreen").extends(Screen)

local endGameView, endGameViewModel

function EndGameScreen:init()
    EndGameScreen.super.init(self)
    -- setup start of EndGame scene
    keys = {true,true,true,true} -- have? bool
    camPos[1] = 35
    camPos[2] = 210
    planePos[1] = 59
    planePos[2] = 224
    planeRot = 18
    endGameViewModel = EndGameViewModel()
    endGameView = EndGameView(endGameViewModel)
end

function EndGameScreen:update()
    endGameView:render(endGameViewModel)
    endGameViewModel:update()
end

function EndGameScreen:pause()
    endGameViewModel:pause()
end

function EndGameScreen:resume()
    endGameViewModel:resume()
end
