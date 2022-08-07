import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("VideoPlayerView").extends()

local disp = playdate.display
local snd = playdate.sound

local baseName <const> = 'video/posterize_bayer2_bright'
local video = gfx.video.new(baseName)
local width, height = video:getSize()
local framerate = video:getFrameRate()
print("video size", width, height, "frameRate", framerate, "frameCount", video:getFrameCount())
video:getContext()
video:renderFrame(0)

local lastframe = 0

local audio, loaderr = snd.sampleplayer.new(baseName)
print("audio", audio)

if audio ~= nil then
    audio:play(0)
else
    print("loaderr", loaderr)
end

function VideoPlayerView:init()
    VideoPlayerView.super.init(self)
    self.offsetX = (400-width)/2
end

function VideoPlayerView:resume()
    disp.setRefreshRate(25)
    playdate.setAutoLockDisabled(true)
end

function VideoPlayerView:pause()
    print("pausing")
    audio:stop()
    disp.setRefreshRate(30)
    playdate.setAutoLockDisabled(false)
end

function VideoPlayerView:destroy()
    self:pause()
end

function VideoPlayerView:render(viewModel)
    local frame = math.floor(audio:getOffset() * video:getFrameRate())

    if frame ~= lastframe then
        video:renderFrame(frame)
        lastframe = frame
        video:getContext():draw(self.offsetX,0)
    end
end
