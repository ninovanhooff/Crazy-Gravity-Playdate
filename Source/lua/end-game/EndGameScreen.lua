import "CoreLibs/object"
import "../screen.lua"
import "EndGameView.lua"
import "EndGameViewModel.lua"

class("EndGameScreen").extends(Screen)

local endGameView, endGameViewModel

function EndGameScreen:init()
    EndGameScreen.super.init(self)
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
    endGameView:resume()
end
