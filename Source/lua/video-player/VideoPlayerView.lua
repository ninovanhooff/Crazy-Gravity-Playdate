import "CoreLibs/object"

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
    end
    printTable(self.subtitles)
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

        local cardText = self:getCurrentCardText()
        if cardText then
            gfx.setColor(gfx.kColorWhite)
            local width = monoFont:getTextWidth(cardText) + 28
            gfx.fillRect(396-width, 4, width, 16)
            monoFont:drawText(cardText, 396 - width + 4, 8)
            gfx.setColor(gfx.kColorBlack)
            cardIcon:draw(378,4)
        end

        local subtitle = self:getCurrentSubtitle()
        if subtitle then
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(subtitleBox)
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
            gfx.drawTextInRect(subtitle, subtitleRect, nil, "...", kTextAlignment.center)
        end
    end

    if frame >= self.frameCount then
        viewModel:onVideoFinished()
    end
end

--- returns the subtitle at the current audio offset, or nil
function VideoPlayerView:getCurrentCardText()
    if not self.cards then
        return nil
    end

    local currentTime = self.audio:getOffset()

    for _,item in ipairs(self.cards) do
        if item.start < currentTime and item["end"] > currentTime then
            return item.text
        end
    end
end

--- returns the subtitle at the current audio offset, or nil
function VideoPlayerView:getCurrentSubtitle()
    if not self.subtitles then
        return nil
    end

    local currentTime = self.audio:getOffset()

    for _,item in ipairs(self.subtitles) do
        if item.start < currentTime and item["end"] > currentTime then
            return item.text
        end
    end
end
