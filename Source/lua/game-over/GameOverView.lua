import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("GameOverView").extends()

function GameOverView:init()

end

function GameOverView:render(viewModel)
    gfx.drawText(viewModel.displayText, 100, 100)
end
