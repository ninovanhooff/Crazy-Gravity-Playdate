import "CoreLibs/object"
import "CoreLibs/graphics"


local gfx <const> = playdate.graphics
local unFlipped <const> = gfx.kImageUnflipped
local sprite <const> = sprite
local deSelectedDrawFun <const> = gfx.drawCircleInRect
local selectedDrawFun <const> = gfx.fillCircleInRect
local dialogRect <const> = playdate.geometry.rect.new(80, 50, 240, 140)
local dialogCenter <const> = dialogRect:centerPoint()
local dialogPadding <const> = 14
local buttonSize <const>, buttonSpacing <const> = 56, 14
local buttonY = dialogRect.bottom - dialogPadding - buttonSize
local titleFont = gfx.font.new("fonts/abduction2002bold-20")


class("GameOverView").extends()

function GameOverView:init()

end

local function buttonDrawFun(selected)
    if selected then
        return selectedDrawFun
    else
        return deSelectedDrawFun
    end
end

function GameOverView:render(viewModel)
    -- dialog shadow
    gfx.setLineWidth(3)
    gfx.setStrokeLocation(gfx.kStrokeCentered)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(dialogRect:offsetBy(1,1))

    -- clear dialog area
    gfx.setClipRect(dialogRect)
    gfx.clear()

    -- title
    titleFont:drawTextAligned(viewModel.title, dialogCenter.x, dialogRect.y+dialogPadding, kTextAlignment.center)

    -- buttons
    gfx.setImageDrawMode(gfx.kDrawModeNXOR) --text color
    local totalWidth = viewModel.numButtons*buttonSize + (viewModel.numButtons-1) * buttonSpacing
    local x = dialogCenter.x - totalWidth/2
    for i = 0,viewModel.numButtons-1 do
        buttonDrawFun(viewModel.selectedButtonIdx == i+1)(x,buttonY, buttonSize, buttonSize)
        sprite:draw(x+12,buttonY + 12, unFlipped, i*32, 32, 32, 32)
        x = x + buttonSize + buttonSpacing
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy) -- reset drawMode. This would persist for some reason
end
