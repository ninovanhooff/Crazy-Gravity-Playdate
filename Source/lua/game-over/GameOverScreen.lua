import "CoreLibs/object"
import "../screen.lua"
import "GameOverView.lua"
import "GameOverViewModel.lua"

class("GameOverScreen").extends(Screen)

local gameOverView, gameOverViewModel

function GameOverScreen:init()
    GameOverScreen.super.init(self)
    gameOverViewModel = GameOverViewModel()
    gameOverView = GameOverView(gameOverViewModel)
end

function GameOverScreen:update()
    gameOverView:render(gameOverViewModel)
    gameOverViewModel:update()
end
