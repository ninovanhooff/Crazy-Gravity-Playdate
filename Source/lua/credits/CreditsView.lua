import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("CreditsView").extends()

function CreditsView:init()
    CreditsView.super.init(self)
end

function CreditsView:render(viewModel)
    gfx.drawText(viewModel.displayText, 100, 100)
end
