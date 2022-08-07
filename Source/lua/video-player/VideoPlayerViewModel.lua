import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("VideoPlayerViewModel").extends()

function VideoPlayerViewModel:init()
    self.displayText = "Hello, this is VideoPlayer screen"
end

function VideoPlayerViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function VideoPlayerViewModel:pause()
end

function VideoPlayerViewModel:resume()
end
