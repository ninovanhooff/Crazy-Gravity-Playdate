

local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB

class("VideoPlayerViewModel").extends(VideoViewModel)

function VideoPlayerViewModel:init(basePath, nextScreenFun)
    VideoPlayerViewModel.super.init(self, basePath)
    self.nextScreenFun = nextScreenFun
end

function VideoPlayerViewModel:shouldApplyVcrFilter()
    return false
end

function VideoPlayerViewModel:onVideoFinished()
    VideoPlayerViewModel.super.onVideoFinished(self)
    popScreen() -- remove self
    if self.nextScreenFun then
        pushScreen(self:nextScreenFun())
    else
        print("WARN " .. " video has no nextScreenFun" )
    end
end

function VideoPlayerViewModel:update()
    VideoPlayerViewModel.super.update(self)
    if justPressed(buttonA) then
        -- skip video
        self:onVideoFinished()
    end
    if justPressed(buttonB) then
        popScreen()
    end
end
