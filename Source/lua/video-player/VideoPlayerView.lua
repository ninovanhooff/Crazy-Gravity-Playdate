import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("VideoPlayerView").extends()

local snd = playdate.sound

function VideoPlayerView:init(viewModel)
    VideoPlayerView.super.init(self)

    print("Loading video", viewModel.basePath)
    self.video = gfx.video.new(viewModel.basePath)
    local width, height = self.video:getSize()
    self.framerate = self.video:getFrameRate()
    self.frameCount = self.video:getFrameCount()
    print("video size", width, height, "frameRate", self.framerate, "frameCount", self.frameCount)

    self.audio, self.loaderr = snd.sampleplayer.new(viewModel.basePath)
    if self.audio == nil then
        print("loaderr", self.loaderr)
    end
    print("audio", audio)
    self.lastframe = 0
    self.offsetX = (400-width)/2
end

function VideoPlayerView:resume()
    playdate.setAutoLockDisabled(true)
    if self.audio ~= nil then
        self.audio:play()
    end
end

function VideoPlayerView:pause()
    print("pausing")
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
    end

    if frame >= self.frameCount then
        viewModel:onVideoFinished()
    end
end
