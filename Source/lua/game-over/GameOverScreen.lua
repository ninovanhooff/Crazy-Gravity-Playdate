import "GameOverView"
import "GameOverViewModel"

class("GameOverScreen").extends(Screen)

local gameOverView, gameOverViewModel

--- @param config string one of: See GameOverViewModel
function GameOverScreen:init(config)
    GameOverScreen.super.init(self)
    gameOverViewModel = GameOverViewModel(config)
    gameOverView = GameOverView(gameOverViewModel)
end

function GameOverScreen:update()
    gameOverView:render(gameOverViewModel)
    gameOverViewModel:update()
end
