

local justPressed <const> = playdate.buttonJustPressed
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB

class("VideoPlayerViewModel").extends()

function VideoPlayerViewModel:init(basePath, nextScreenFun)
    self.basePath = basePath
    self.nextScreenFun = nextScreenFun
end

function VideoPlayerViewModel:onVideoFinished()
    popScreen() -- remove self
    if self.nextScreenFun then
        pushScreen(self:nextScreenFun())
    else
        print("WARN " .. " video has no nextScreenFun" )
    end
end

function VideoPlayerViewModel:update()
    if justPressed(buttonA) then
        -- skip video
        self:onVideoFinished()
    end
    if justPressed(buttonB) then
        popScreen()
    end
end

function VideoPlayerViewModel:resume()
    musicManager:fade(0.3) -- lower music volume for clear dialogue
end

function VideoPlayerViewModel:destroy()
    musicManager:fade(1.0)  -- restore original music volume
end
