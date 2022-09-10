import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("FlyToCreditsView").extends()

function FlyToCreditsView:init()
    FlyToCreditsView.super.init(self)
end

function FlyToCreditsView:render(viewModel)
    gfx.drawText(viewModel.displayText, 100, 100)
end
