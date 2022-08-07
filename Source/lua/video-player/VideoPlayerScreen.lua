import "CoreLibs/object"
import "../screen.lua"
import "VideoPlayerView.lua"
import "VideoPlayerViewModel.lua"

class("VideoPlayerScreen").extends(Screen)

local videoPlayerView, videoPlayerViewModel

function VideoPlayerScreen:init()
    VideoPlayerScreen.super.init(self)
    videoPlayerViewModel = VideoPlayerViewModel()
    videoPlayerView = VideoPlayerView(videoPlayerViewModel)
end

function VideoPlayerScreen:update()
    videoPlayerView:render(videoPlayerViewModel)
    videoPlayerViewModel:update()
end

function VideoPlayerScreen:pause()
    videoPlayerViewModel:pause()
    videoPlayerView:pause()
end

function VideoPlayerScreen:destroy()
    videoPlayerView:destroy()
end

function VideoPlayerScreen:resume()
    videoPlayerViewModel:resume()
    videoPlayerView:resume()
end
