---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 18/10/2022 18:14
---
local gfx <const> = playdate.graphics

local toolTipsCache <const> = enum({"WrongWay"})
local tooltipFont <const> = smallFont
local tooltipHeight <const> = 14
local halfTooltipHeight <const> = tooltipHeight/2
local tooltipContentSpacing = 3

local tooltipIcons <const> = gfx.imagetable.new("images/tooltips/tooltips")

local function getToolTipBgColor()
    if gameBgColor == gfx.kColorBlack then
        return gfx.kColorWhite
    else
        return gfx.kColorBlack
    end
end

function PreRenderToolTips()
    local text = "Wrong way!"
    local tooltipBgColor = getToolTipBgColor()


    local wrongWayImage = gfx.image.new(
        tooltipFont:getTextWidth(text) + 16,
        tooltipHeight
    )
    gfx.pushContext(wrongWayImage)
    gfx.setColor(tooltipBgColor)
    local w,h = wrongWayImage:getSize()
    gfx.fillRoundRect(0,0, w,h, 7)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    tooltipIcons:getImage(1):draw(0,0) -- access denied sign
    tooltipFont:drawText(text, 16, 0)
    gfx.popContext()
    toolTipsCache.WrongWay.image = wrongWayImage
end

PreRenderToolTips()

function RenderTooltip(tooltip, centerX, centerY)
    local text = tooltip.text
    local progress = tooltip.progress
    local leftIcon = tooltipIcons[tooltip.leftIconIndex]

    gfx.pushContext()

    local textWidth = tooltipFont:getTextWidth(text)
    local leftIconWidth = (leftIcon and leftIcon:getSize() or 0)
    local w = textWidth + tooltipContentSpacing*2
    if leftIcon then
        w = w + leftIconWidth
    end
    if progress then
        w = w + 12 + tooltipContentSpacing
    end

    local x, y = centerX - w/2, centerY - halfTooltipHeight
    gfx.setColor(getToolTipBgColor())
    gfx.fillRoundRect(x,y, w,tooltipHeight, 3)
    gfx.setColor(gameBgColor)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    local contentX = x

    if leftIcon then
        leftIcon:draw(contentX, y)
        contentX = contentX + leftIconWidth + tooltipContentSpacing
    else
        contentX = contentX + tooltipContentSpacing
    end

    tooltipFont:drawText(text, contentX, y)
    contentX = contentX + textWidth + 10

    if progress then
        gfx.setLineWidth(5)
        gfx.drawArc(contentX, centerY, 3, 0, progress * 360)
    end

    gfx.popContext()
end