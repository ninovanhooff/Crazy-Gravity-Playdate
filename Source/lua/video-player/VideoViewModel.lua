class("VideoViewModel").extends()

function VideoViewModel:init(basePath)
    self.basePath = basePath
    self.finished = false
end

function VideoViewModel:onVideoFinished()
    self.finished = true
    self:pause()
end

function VideoViewModel:update()
    return self.finished
end

function VideoViewModel:pause()
    musicManager:fade(1.0)  -- restore original music volume
end

function VideoViewModel:resume()
    musicManager:fade(0.3) -- lower music volume for clear dialogue
end

function VideoViewModel:destroy()
    self:pause()
end
