import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("CreditsView").extends()

function CreditsView:init()
    CreditsView.super.init(self)
end

function CreditsView:render(viewModel)
    gfx.clear(gfx.kColorBlack)
    gfx.setColor(gfx.kColorWhite)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) --text color
end
