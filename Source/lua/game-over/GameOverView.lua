


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
    local buttonOffsetsX = viewModel.buttonSourceOffsetsX
    local numButtons = #buttonOffsetsX
    local totalWidth = numButtons*buttonSize + (numButtons-1) * buttonSpacing
    local x = dialogCenter.x - totalWidth/2
    local selected
    for i = 0,numButtons-1 do
        selected = viewModel.selectedButtonIdx == i+1
        buttonDrawFun(selected)(x,buttonY, buttonSize, buttonSize)
        if selected then
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
        else
            gfx.setImageDrawMode(gfx.kDrawModeCopy)
        end
        sprite:draw(x+4,buttonY+4, unFlipped, buttonOffsetsX[i+1], 0, 48, 48)
        x = x + buttonSize + buttonSpacing
    end
    gfx.setImageDrawMode(gfx.kDrawModeCopy) -- reset drawMode. This would persist for some reason
end
