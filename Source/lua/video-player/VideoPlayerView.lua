local gfx <const> = playdate.graphics
local cardIcon <const> = gfx.image.new("images/card_info_icon")
local subtitleBox <const> = playdate.geometry.rect.new(0, 212, 400, 28)
local subtitleRect <const> = playdate.geometry.rect.new(8, 218, 384, 28)

class("VideoPlayerView").extends()

function VideoPlayerView:init(viewModel)
    VideoPlayerView.super.init(self)
    self.viewModel = viewModel
    self.videoContext = viewModel.video:getContext()
end

function VideoPlayerView:resume()
    playdate.display.setRefreshRate(self.viewModel.framerate)
    playdate.setAutoLockDisabled(true)
    self.viewModel:resume()
end

function VideoPlayerView:pause()
    playdate.display.setRefreshRate(frameRate)
    playdate.setAutoLockDisabled(false)
    self.viewModel:pause()
end

function VideoPlayerView:destroy()
    self:pause()
end

function VideoPlayerView:render()
    local viewModel = self.viewModel
    viewModel.video:renderFrame(viewModel:currentFrame())
    local image = self.videoContext
    if viewModel:shouldApplyVcrFilter() then
        image = image:vcrPauseFilterImage()
    end
    image:draw(viewModel.offsetX,viewModel.offsetY)

    self:renderChyron()

    local card = viewModel:getCurrentCard(self.cards)
    if card then
        local cardText = card.text
        gfx.setColor(gfx.kColorWhite)
        local width = monoFont:getTextWidth(cardText) + 28
        gfx.fillRect(396-width, 4, width, 16)
        monoFont:drawText(cardText, 396 - width + 4, 5)
        gfx.setColor(gfx.kColorBlack)
        cardIcon:draw(378,4)
    end

    local subtitle = viewModel:getCurrentSubtitle()
    if subtitle then
        gfx.setColor(gfx.kColorBlack)
        gfx.fillRect(subtitleBox)
        gfx.setImageDrawMode(gfx.kDrawModeInverted)
        gfx.drawTextInRect(subtitle.text, subtitleRect, nil, "...", kTextAlignment.center)
    end
end

local chyronTop <const> = 175
local chyronLeft <const> = 20
local chyronSlant <const> = 16
local chyronHeight <const> = 18
--- The words on the screen that identify speakers, locations, or story subjects
function VideoPlayerView:renderChyron()
    local chyron = self.viewModel:getCurrentChyron()
    if not chyron then
        return
    end

    local title = chyron.title
    local subtitle = chyron.subtitle

    local titleWidth = gfx.getFont():getTextWidth(title)
    local titlePoly = playdate.geometry.polygon.new(
        chyronLeft, chyronTop,
        chyronLeft + titleWidth + chyronSlant, chyronTop,
        chyronLeft + titleWidth, chyronTop + chyronHeight,
        chyronLeft - chyronSlant, chyronTop + chyronHeight,
        chyronLeft, chyronTop
    )

    local subtitleWidth = monoFont:getTextWidth(subtitle)
    local subtitleTop = chyronTop + chyronHeight - 3
    local subtitleLeft = chyronLeft
    local subtitlePoly = playdate.geometry.polygon.new(
        subtitleLeft, subtitleTop,
        subtitleLeft + subtitleWidth + chyronSlant, subtitleTop,
        subtitleLeft + subtitleWidth, subtitleTop + chyronHeight,
        subtitleLeft - chyronSlant, subtitleTop + chyronHeight,
        subtitleLeft, subtitleTop
    )


    gfx.fillPolygon(subtitlePoly)
    gfx.setColor(gfx.kColorWhite)
    gfx.drawPolygon(subtitlePoly)

    gfx.setColor(gfx.kColorWhite)
    gfx.fillPolygon(titlePoly)
    gfx.setColor(gfx.kColorBlack)

    gfx.setImageDrawMode(gfx.kDrawModeNXOR) --text color
    gfx.drawText(title, chyronLeft, chyronTop)
    monoFont:drawText(subtitle, subtitleLeft, subtitleTop+4)
end
