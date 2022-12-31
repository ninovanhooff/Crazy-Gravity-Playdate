local timer <const> = playdate.timer

class("VideoTimebase").extends()

function VideoTimebase:init()
    VideoTimebase.super.init(self)
end

function VideoTimebase:isFinished()
    return false
end

function VideoTimebase:durationSeconds() end

--- play position in seconds
function VideoTimebase:getOffset()
    return 0
end

function VideoTimebase:start() end
function VideoTimebase:stop() end
function VideoTimebase:destroy() end

---- FilePlayerTimebase
class("FilePlayerTimebase").extends(VideoTimebase)

function FilePlayerTimebase:init(filePlayer, loop)
    FilePlayerTimebase.super.init(self)
    self.player = filePlayer
    self.loop = loop
end

function FilePlayerTimebase:start()
    self.player:play(self.loop and 0  or 1)
end

function FilePlayerTimebase:stop()
    self.player:stop()
end

function FilePlayerTimebase:getOffset()
    return self.player:getOffset()
end

function FilePlayerTimebase:durationSeconds()
    return self.player:getLength()
end

function FilePlayerTimebase:isFinished()
    return self.player:getOffset() >= self.player:getLength()
end

function FilePlayerTimebase:destroy()
    self:stop()
end

---- TimerTimebase
class("TimerTimebase").extends(VideoTimebase)

function TimerTimebase:init(durationSeconds, repeats)
    TimerTimebase.super.init(self)
    self.timer = timer.new(durationSeconds*1000, 0, durationSeconds)
    self.timer.repeats = repeats
    self.timer:pause() -- do not auto-start
end

function TimerTimebase:start()
    self.timer:reset()
    self.timer:start()
end

function TimerTimebase:stop()
    self.timer:reset()
    self.timer:pause()
end

function TimerTimebase:getOffset()
    return self.timer.value
end

function TimerTimebase:durationSeconds()
    return self.timer.endValue
end

function TimerTimebase:isFinished()
    return self.timer.value >= self.timer.endValue and not self.timer.repeats
end

function TimerTimebase:destroy()
    self.timer:remove()
end
