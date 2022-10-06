

local gfx <const> = playdate.graphics
local cardIcon <const> = gfx.image.new("images/card_info_icon")
local subtitleBox <const> = playdate.geometry.rect.new(0, 212, 400, 28)
local subtitleRect <const> = playdate.geometry.rect.new(8, 218, 384, 28)

class("VideoPlayerView").extends()

local snd = playdate.sound

function VideoPlayerView:init(viewModel)
    VideoPlayerView.super.init(self)
    local basePath <const> = viewModel.basePath

    print("Loading video", basePath)
    self.video = gfx.video.new(basePath)
    local width, height = self.video:getSize()
    self.framerate = self.video:getFrameRate()
    self.frameCount = self.video:getFrameCount()
    print("video size", width, height, "frameRate", self.framerate, "frameCount", self.frameCount)

    self.audio, self.loaderr = snd.sampleplayer.new(basePath)
    if self.audio == nil then
        print("loaderr", self.loaderr)
    end
    print("audio", self.audio)
    self.lastframe = 0
    self.offsetX = (400-width)/2

    self.metadata, self.loaderr = json.decodeFile(basePath .. ".json")
    if self.loaderr then
        print(self.loaderr)
    else
        self.cards = self.metadata.cards
        self.subtitles = self.metadata.subtitles
        self.chyrons = self.metadata.chyrons
    end
    printTable(self.chyrons)
end

function VideoPlayerView:resume()
    playdate.setAutoLockDisabled(true)
    if self.audio ~= nil then
        self.audio:play()
    end
end

function VideoPlayerView:pause()
    self.audio:stop()
    playdate.setAutoLockDisabled(false)
end

function VideoPlayerView:destroy()
    self:pause()
end

function VideoPlayerView:render(viewModel)
    local frame = math.floor(self.audio:getOffset() * self.framerate)

    if frame ~= lastframe then
        self.video:renderFrame(frame)
        self.lastframe = frame
        self.video:getContext():draw(self.offsetX,0)

        self:renderChyron()

        local card = self:getCurrentMetaData(self.cards)
        if card then
            local cardText = card.text
            gfx.setColor(gfx.kColorWhite)
            local width = monoFont:getTextWidth(cardText) + 28
            gfx.fillRect(396-width, 4, width, 16)
            monoFont:drawText(cardText, 396 - width + 4, 5)
            gfx.setColor(gfx.kColorBlack)
            cardIcon:draw(378,4)
        end

        local subtitle = self:getCurrentMetaData(self.subtitles)
        if subtitle then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(subtitleBox)
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            gfx.drawTextInRect(subtitle.text, subtitleRect, nil, "...", kTextAlignment.center)
        end
    end

    if frame >= self.frameCount then
        viewModel:onVideoFinished()
    end
end

local chyronTop <const> = 175
local chyronLeft <const> = 20
local chyronSlant <const> = 16
local chyronHeight <const> = 18
--- The words on the screen that identify speakers, locations, or story subjects
function VideoPlayerView:renderChyron()
    local chyron = self:getCurrentMetaData(self.chyrons)
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

function VideoPlayerView:getCurrentMetaData(metaData)
    if not metaData then
        return nil
    end

    local currentTime = self.audio:getOffset()

    for _,item in ipairs(metaData) do
        if item.start <= currentTime and item["end"] >= currentTime then
            return item
        end
    end
end
