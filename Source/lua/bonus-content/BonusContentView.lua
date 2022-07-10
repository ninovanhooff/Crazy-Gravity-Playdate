import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("BonusContentView").extends()

function BonusContentView:init()

end

function BonusContentView:render(viewModel)
    gfx.clear()
    gfx.drawTextInRect(viewModel.displayText, 100, 50, 200, 200, nil, "...", kTextAlignment.left)
end
