local playdate <const> = playdate
local gfx <const> = playdate.graphics
local polygon <const> = playdate.geometry.polygon
local playdateImage <const> = gfx.image.new("images/playdate_front")
local dialogRect <const> = playdate.geometry.rect.new(50, 25, 280, 190)
local dialogCenter <const> = dialogRect:centerPoint()
local dialogPadding <const> = 14
local titleFont = gfx.getFont()
local smallFont = GetResourceLoader():getSmallFont()

class("ButtonMappingDialog").extends(Screen)

function ButtonMappingDialog:init()
    ButtonMappingDialog.super.init(self)
    self.title = "Crank controls"
end

function ButtonMappingDialog:resume()
    sprite:draw(0,-100)
    -- dialog shadow
    gfx.setLineWidth(3)
    gfx.setStrokeLocation(gfx.kStrokeCentered)
    gfx.setColor(gfx.kColorBlack)
    gfx.drawRect(dialogRect:offsetBy(1,1))

    -- clear dialog area
    gfx.setClipRect(dialogRect)
    gfx.clear()

    local y = dialogRect.y+dialogPadding

    -- title. x offset: visual center of image is not in middle
    titleFont:drawTextAligned(self.title, dialogCenter.x-10, y, kTextAlignment.center)
    y = y + 30

    -- Image

    local imgX <const> = dialogCenter.x - playdateImage:getSize()/2 -- +10: visual center is out of balance
    playdateImage:draw(imgX, y)

    gfx.setLineWidth(2)
    smallFont:drawTextAligned("Throttle", imgX - 10, y+35, kTextAlignment.right)
    smallFont:drawTextAligned("Up", imgX - 10, y+52, kTextAlignment.right)
    smallFont:drawTextAligned("Left", imgX - 10, y+69, kTextAlignment.right)
    smallFont:drawTextAligned("Down", imgX - 10, y+85, kTextAlignment.right)
    local poly = polygon.new(
        imgX -5, y + 38,
        imgX + 35, y + 38,
        imgX + 35, y + 75
    )
    gfx.drawPolygon(poly)

    smallFont:drawText("Steering", imgX + 130, y+20)
    smallFont:drawText("Throttle", imgX + 130, y+60)

end

function ButtonMappingDialog:update()

end
