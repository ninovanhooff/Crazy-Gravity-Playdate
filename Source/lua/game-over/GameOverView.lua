import "CoreLibs/object"
import "CoreLibs/graphics"


local gfx <const> = playdate.graphics
local deSelectedDrawFun <const> = gfx.drawCircleAtPoint
local selectedDrawFun <const> = gfx.fillCircleAtPoint
local dialogRect <const> = playdate.geometry.rect.new(80, 50, 240, 140)
local dialogPadding <const> = 15
local buttonRadius <const> = 28
local buttonInsetX, buttonCenterY <const> = 80, dialogRect.bottom - dialogPadding - buttonRadius - 7
local levelSelectCenterPoint <const> = playdate.geometry.point.new(dialogRect.x + buttonInsetX, buttonCenterY)
local retryCenterPoint <const> = playdate.geometry.point.new(dialogRect.right - buttonInsetX, buttonCenterY)
local levelSelectIcon = gfx.image.new("images/menu_icon.png")
local retryIcon = gfx.image.new("images/retry_arrow.png")
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
    gfx.setClipRect(dialogRect)
    gfx.clear()
    gfx.setColor(gfx.kColorBlack)
    gfx.setStrokeLocation(gfx.kStrokeInside)
    gfx.drawRect(dialogRect)
    gfx.setLineWidth(4)
    titleFont:drawTextAligned(viewModel.title, dialogRect:centerPoint().x, dialogRect.y+dialogPadding, kTextAlignment.center)

    buttonDrawFun(viewModel:isLevelSelectSelected())(levelSelectCenterPoint, buttonRadius)
    buttonDrawFun(viewModel:isRetrySelected())(retryCenterPoint, buttonRadius)

    gfx.setImageDrawMode(gfx.kDrawModeNXOR) --text color
    levelSelectIcon:draw(levelSelectCenterPoint.x-16,levelSelectCenterPoint.y-16)
    retryIcon:draw(retryCenterPoint.x-18,retryCenterPoint.y-16)
end
