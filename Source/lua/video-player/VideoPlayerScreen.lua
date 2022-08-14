import "CoreLibs/object"
import "../screen.lua"
import "VideoPlayerView.lua"
import "VideoPlayerViewModel.lua"

class("VideoPlayerScreen").extends(Screen)


function VideoPlayerScreen:init(basePath, nextScreenFun)
    VideoPlayerScreen.super.init(self)
    self.videoPlayerViewModel = VideoPlayerViewModel(basePath, nextScreenFun)
    self.videoPlayerView = VideoPlayerView(self.videoPlayerViewModel)
end

function VideoPlayerScreen:update()
    self.videoPlayerViewModel:update()
    self.videoPlayerView:render(self.videoPlayerViewModel)
end

function VideoPlayerScreen:pause()
    self.videoPlayerViewModel:pause()
    self.videoPlayerView:pause()
end

function VideoPlayerScreen:destroy()
    self.videoPlayerView:destroy()
end

function VideoPlayerScreen:resume()
    self.videoPlayerViewModel:resume()
    self.videoPlayerView:resume()
end
