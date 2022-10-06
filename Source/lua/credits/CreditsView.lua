

local floor <const> = math.floor
local gfx <const> = playdate.graphics
local tileSize <const> = tileSize
local unFlipped <const> = gfx.kImageUnflipped
local logoImg <const> = gfx.image.new("images/logo.png")
local startBGImg <const> = gfx.image.new("images/start_background")
local logoWidth, logoHeight <const> = logoImg:getSize()
local screenCenterX = screenWidth/2
local lineSpacing <const> = 2
local imageSpacing <const> = 8
local sectionSpacing <const> = 16

class("CreditsView").extends()

function CreditsView:init()
    CreditsView.super.init(self)
    self.textHeight = gfx.getFont():getHeight()
    self:createCreditsImage()
    --playdate.simulator.writeToFile(self.creditsImage, "~/PlaydateProjects/GravityExpressEditor/Source/images/credits_bg.png")
end

function CreditsView:render(viewModel)
    gfx.clear(gfx.kColorBlack)
    local creditsY = -((camPos[2]-1)*tileSize) - camPos[4]


    --- the active game area, excluding the HUD
    gfx.setScreenClipRect(0,0, screenWidth, hudY)
    self.creditsImage:draw(0,creditsY)
    -- disable HUD, for a more serene experience
    RenderGame(true)
end

function CreditsView:drawTextCentered(text, y, x, underline)
    x = x or screenCenterX
    local textCenter, textLeft, textRight
    --- extra height to add
    local addHeight = 0
    if type(text) == "table" then
        if #text == 1 then
            textCenter = text[1]
        elseif #text == 2 then
            textLeft = text[1]
            textRight = text[2]
        else
            textLeft = text[1]
            textCenter = text[2]
            textRight = text[3]
        end
    else
        textCenter = text
    end

    local origDrawMode = gfx.getImageDrawMode()
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) --text color
    if textLeft then
        gfx.drawTextAligned(textLeft, x - 10, y, kTextAlignment.right)
    end
    if textCenter then
        gfx.drawTextAligned(textCenter, x, y, kTextAlignment.center)
    end
    if textRight then
        gfx.drawTextAligned(textRight, x + 10, y, kTextAlignment.left)
    end
    gfx.setImageDrawMode(origDrawMode)
    if underline and textCenter then
        addHeight = addHeight + 8
        local textWidth, textHeight = gfx.getTextSize(textCenter)
        local halfUnderLineWidth = textWidth / 2 + 4
        local origColor = gfx.getColor()
        gfx.setColor(gfx.kColorWhite)
        gfx.drawLine(x - halfUnderLineWidth, y + textHeight, x + halfUnderLineWidth, y+textHeight)
        gfx.setColor(origColor)
    end
    return self.textHeight + addHeight
end

function CreditsView:createCreditsImage()
    local screenWidth <const> = screenWidth
    local height <const> = levelProps.sizeY * tileSize
    self.creditsImage = gfx.image.new(screenWidth,height)
    gfx.pushContext(self.creditsImage)

    gfx.setColor(gfx.kColorWhite)
    gfx.drawLine(1,height-1, screenWidth, height-1) -- debug line indicating end of image

    -- draw stars
    local random <const>  = math.random
    for _ = 1, 500 do
        gfx.drawPixel(random(1, screenWidth), random(1, height))
    end

    -- position bottom of startScreen above hudY,
    -- subtract 1x tileSize to compensate for 1-based cam pos
    startBGImg:draw(0, height - screenHeight - tileSize)


    local x,y = screenCenterX, 300

    y = y + self:drawTextCentered("Thanks for playing", y) + imageSpacing
    logoImg:draw(screenCenterX - logoWidth/2, y)
    y = y + logoHeight + imageSpacing
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite) --text color
    y = y + self:drawTextCentered("A game by Nino van Hooff", y) + sectionSpacing

    y = y + self:drawTextCentered("Based on", y) + imageSpacing
    sprite:draw(
        x - 30,y,
        unFlipped,
        432, 0,
        60,60
    )
    y = y + 60 + imageSpacing
    y = y + self:drawTextCentered("by Axel Meierhofer", y) + sectionSpacing

    y = y + self:drawTextCentered("Programming", y, screenCenterX, true) + lineSpacing
    y = y + self:drawTextCentered({"Game", "Nino van Hooff"}, y) + lineSpacing
    y = y + self:drawTextCentered({"Settings", "Matt Septhon"}, y) + sectionSpacing

    y = y + self:drawTextCentered("Art", y, screenCenterX, true) + lineSpacing
    y = y + self:drawTextCentered("Count Moriarty", y) + lineSpacing
    y = y + self:drawTextCentered("Casey Gatti", y) + lineSpacing
    y = y + self:drawTextCentered("Mike Brown", y) + lineSpacing
    y = y + self:drawTextCentered("PixelWitch", y) + sectionSpacing

    y = y + self:drawTextCentered("Audio", y, screenCenterX, true) + lineSpacing
    y = y + self:drawTextCentered("Arjan Terpstra", y) + lineSpacing
    y = y + self:drawTextCentered("Freesound.org", y) + sectionSpacing

    y = y + self:drawTextCentered("Script", y, screenCenterX, true) + lineSpacing
    y = y + self:drawTextCentered("Magnum Kramer", y) + sectionSpacing

    y = y + self:drawTextCentered("Starring", y, screenCenterX, true) + lineSpacing
    y = y + self:drawTextCentered({"Stephanie Shipwell", "Jodi Hutton"}, y) + lineSpacing
    y = y + self:drawTextCentered("Operator", y) + sectionSpacing

    y = y + self:drawTextCentered("Thanks", y, screenCenterX, true) + lineSpacing
    y = y + self:drawTextCentered("Matt Septhon", y) + lineSpacing
    y = y + self:drawTextCentered("Choosh", y) + lineSpacing
    y = y + self:drawTextCentered("James Daniels", y) + lineSpacing
    y = y + self:drawTextCentered("Richard Lems", y) + lineSpacing
    y = y + self:drawTextCentered("Labeardi", y) + sectionSpacing


    gfx.popContext()
end
