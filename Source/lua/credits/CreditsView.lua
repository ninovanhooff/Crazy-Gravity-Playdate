import "CoreLibs/object"

local floor <const> = math.floor
local gfx <const> = playdate.graphics
local unFlipped <const> = gfx.kImageUnflipped
local logoImg <const> = gfx.image.new("images/logo.png")
local logoWidth, logoHeight <const> = logoImg:getSize()
local screenCenterX = screenWidth/2
local lineSpacing <const> = 8
local sectionSpacing <const> = lineSpacing*2

class("CreditsView").extends()

function CreditsView:init()
    CreditsView.super.init(self)
    self:createCreditsImage()
end

function CreditsView:render(viewModel)
    gfx.clear(gfx.kColorBlack)
    self.creditsImage:draw(0,viewModel.creditsY)

    -- plane
    sprite:draw(
        floor(viewModel.planeX), floor(viewModel.planeY),
        unFlipped,
        viewModel.planeRot%16*23, 391+(boolToNum(viewModel.planeRot>15)*2-viewModel.thrust)*23,
        23, 23
    )
end

function CreditsView:drawTextCentered(text, y, underline)
    local origDrawMode = gfx.getImageDrawMode()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) --text color
    gfx.drawTextAligned(text, screenCenterX, y, kTextAlignment.center)
    gfx.setImageDrawMode(origDrawMode)
    local textWidth, textHeight = gfx.getTextSize(text)
    if underline then
        local halfUnderLineWidth = textWidth / 2 + 4
        local origColor = gfx.getColor()
        gfx.setColor(gfx.kColorWhite)
        gfx.drawLine(screenCenterX - halfUnderLineWidth, y + textHeight, screenCenterX + halfUnderLineWidth, y+textHeight)
        textHeight = textHeight + 4
        gfx.setColor(origColor)
    end
    return textHeight
end

function CreditsView:createCreditsImage()
    self.creditsImage = gfx.image.new(400,1000)
    gfx.pushContext(self.creditsImage)

    gfx.setColor(gfx.kColorWhite)


    local y = 0

    y = y + self:drawTextCentered("Thanks for playing", y) + lineSpacing
    logoImg:draw(screenCenterX - logoWidth/2, y)
    y = y + logoHeight + lineSpacing
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) --text color
    y = y + self:drawTextCentered("A game by Nino van Hooff", y) + sectionSpacing

    y = y + self:drawTextCentered("Based on", y) + lineSpacing
    sprite:draw(
        screenCenterX - 30,y,
        unFlipped,
        432, 0,
        60,60
    )
    y = y + 60 + lineSpacing
    y = y + self:drawTextCentered("by Axel Meierhofer", y) + sectionSpacing

    y = y + self:drawTextCentered("Programming", y, true)





    gfx.popContext()
end
