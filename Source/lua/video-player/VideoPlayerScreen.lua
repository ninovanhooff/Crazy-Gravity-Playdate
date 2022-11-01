import "VideoViewModel"
import "VideoPlayerView"
import "VideoPlayerViewModel"

class("VideoPlayerScreen").extends(Screen)


function VideoPlayerScreen:init(basePath, nextScreenFun)
    VideoPlayerScreen.super.init(self)
    self.videoPlayerViewModel = VideoPlayerViewModel(basePath, nextScreenFun)
    self.videoPlayerView = VideoPlayerView(self.videoPlayerViewModel)
end

function VideoPlayerScreen:update()
    self.videoPlayerViewModel:update()
    self.videoPlayerView:render()
end

function VideoPlayerScreen:pause()
    self.videoPlayerViewModel:pause()
    self.videoPlayerView:pause()
end

function VideoPlayerScreen:destroy()
    self.videoPlayerViewModel:destroy()
    self.videoPlayerView:destroy()
end

function VideoPlayerScreen:resume()
    self.videoPlayerViewModel:resume()
    self.videoPlayerView:resume()
end
