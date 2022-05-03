import "CoreLibs/object"

local gfx <const> = playdate.graphics
local dialogRect <const> = playdate.geometry.rect.new(80, 40, 240, 160)

class("GameOverView").extends()

function GameOverView:init()

end

function GameOverView:render(viewModel)
    gfx.setClipRect(dialogRect)
    gfx.clear()
    gfx.setColor(gfx.kColorBlack)
    --gfx.setStrokeLocation(gfx.kStrokeInside)
    gfx.drawRect(dialogRect)
    gfx.setLineWidth(4)
    gfx.drawText(viewModel.displayText, 100, 100)
end
