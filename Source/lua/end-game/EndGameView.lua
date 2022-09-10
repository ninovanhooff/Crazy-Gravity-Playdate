import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("EndGameView").extends()

function EndGameView:init()
    EndGameView.super.init(self)
end

function EndGameView:render(viewModel)
    gfx.drawText(viewModel.displayText, 100, 100)
end
