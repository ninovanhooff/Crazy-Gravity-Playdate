import "CoreLibs/object"

local gfx <const> = playdate.graphics
local renderGame <const> = RenderGame

class("EndGameView").extends()

function EndGameView:init()
    EndGameView.super.init(self)
end

function EndGameView:render(viewModel)
    renderGame()
end
