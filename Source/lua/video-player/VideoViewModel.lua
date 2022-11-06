local round <const> = round
local gfx <const> = playdate.graphics
local snd = playdate.sound


class("VideoViewModel").extends()

function VideoViewModel:init(basePath)
    self.basePath = basePath
    self.finished = false
    print("Loading video", basePath)
    self.video = gfx.video.new(basePath)
    local width, height = self.video:getSize()
    self.offsetX = (screenWidth-width)/2
    self.offsetY = (screenHeight-height)/2
    self.framerate = self.video:getFrameRate()
    self.frameCount = self.video:getFrameCount()
    print("video size", width, height, "frameRate", self.framerate, "frameCount", self.frameCount)

    self.audio, self.loaderr = snd.sampleplayer.new(basePath)
    if self.audio == nil then
        print("loaderr", self.loaderr)
    end
    print("audio", self.audio)

    self.metadata, self.loaderr = json.decodeFile(basePath .. ".json")
    if self.loaderr then
        print(self.loaderr)
    else
        self.cards = self.metadata.cards
        self.subtitles = self.metadata.subtitles
        self.chyrons = self.metadata.chyrons
    end

end

function VideoViewModel:currentFrame()
    return round(self.audio:getOffset() * self.framerate)
end

function VideoViewModel:shouldApplyVcrFilter()
    local currentFrame = self:currentFrame()
    return currentFrame < 3 or currentFrame > self.frameCount - 3
end

function VideoViewModel:getCurrentMetaData(metaData)
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

function VideoViewModel:getCurrentChyron()
    return self:getCurrentMetaData(self.chyrons)
end

function VideoViewModel:getCurrentCard()
    return self:getCurrentMetaData(self.cards)
end

function VideoViewModel:getCurrentSubtitle()
    return self:getCurrentMetaData(self.subtitles)
end

function VideoViewModel:onVideoFinished()
    self.finished = true
    self:pause()
end

function VideoViewModel:update()
    if self:currentFrame() >= self.frameCount then
        self:onVideoFinished()
    end
    return self.finished
end

function VideoViewModel:pause()
    musicManager:fade(1.0)  -- restore original music volume
    self.audio:stop()
end

function VideoViewModel:resume()
    musicManager:fade(0.3) -- lower music volume for clear dialogue
    if self.audio ~= nil then
        self.audio:play()
    end
end

function VideoViewModel:destroy()
    self.audio:stop() --todo move fadeout to videoPlayerViewModel
end
