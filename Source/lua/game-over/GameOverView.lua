import "CoreLibs/object"
import "CoreLibs/graphics"


local gfx <const> = playdate.graphics
local dialogRect <const> = playdate.geometry.rect.new(80, 50, 240, 140)
local dialogPadding <const> = 15
local buttonRadius <const> = 24
local buttonInsetX, buttonCenterY <const> = 80, dialogRect.bottom - dialogPadding - buttonRadius - 7
local levelSelectCenterPoint <const> = playdate.geometry.point.new(dialogRect.x + buttonInsetX, buttonCenterY)
local retryCenterPoint <const> = playdate.geometry.point.new(dialogRect.right - buttonInsetX, buttonCenterY)
local levelSelectIcon = gfx.image.new("images/menu_icon.png")
local retryIcon = gfx.image.new("images/retry_arrow.png")
local titleFont = gfx.font.new("fonts/abduction2002bold-20")


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
    titleFont:drawTextAligned(viewModel.title, dialogRect:centerPoint().x, dialogRect.y+dialogPadding, kTextAlignment.center)

    gfx.drawCircleAtPoint(levelSelectCenterPoint, buttonRadius)
    gfx.drawCircleAtPoint(retryCenterPoint, buttonRadius)
    levelSelectIcon:draw(levelSelectCenterPoint.x-16,levelSelectCenterPoint.y-16)
    retryIcon:draw(retryCenterPoint.x-18,retryCenterPoint.y-16)
end
