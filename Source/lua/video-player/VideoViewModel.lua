import "VideoTimebase"
local round <const> = round
local gfx <const> = playdate.graphics
local snd = playdate.sound


class("VideoViewModel").extends()

function VideoViewModel:init(basePath, loop)
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

    local audio = snd.fileplayer.new(basePath)
    print("audio", audio)
    self.timebase = audio
        and FilePlayerTimebase(audio, loop)
        or TimerTimebase(self.frameCount / self.framerate, loop)


    self.metadata, self.loaderr = json.decodeFile(basePath .. ".json")
    if self.loaderr then
        print(self.loaderr)
    else
        self.cards = self.metadata.cards
        self.subtitles = self.metadata.subtitles
        self.chyrons = self.metadata.chyrons
    end

    self.vcrFilterEnabled = true

end

function VideoViewModel:currentFrame()
    return round(self.timebase:getOffset() * self.framerate)
end

function VideoViewModel:shouldApplyVcrFilter()
    if not self.vcrFilterEnabled then
        return false
    end
    local currentOffset = self.timebase:getOffset()
    return currentOffset < 0.1 or currentOffset > self.timebase:durationSeconds() - 0.1
end

function VideoViewModel:getCurrentMetaData(metaData)
    if not metaData then
        return nil
    end

    local currentTime = self.timebase:getOffset()

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

function VideoViewModel:getOffset()
    return self.timebase:getOffset()
end

function VideoViewModel:onVideoFinished()
    self.finished = true
    self:pause()
end

function VideoViewModel:update()
    if self.timebase:isFinished() then
        self:onVideoFinished()
    end
    return self.finished
end

function VideoViewModel:pause()
    if self.timebase:isa(FilePlayerTimebase) then
        musicManager:fade(1.0)  -- restore original music volume
    end
    self.timebase:stop()
end

function VideoViewModel:resume()
    if self.timebase:isa(FilePlayerTimebase)  then
        musicManager:fade(0.3) -- lower music volume for clear dialogue
    end
    self.timebase:start()
end

function VideoViewModel:destroy()
    self.timebase:stop()
end
