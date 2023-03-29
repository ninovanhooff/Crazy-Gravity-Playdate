local playdate <const> = playdate
local readAccelerometer <const> = playdate.readAccelerometer

local smallestPlaneRotation <const> = smallestPlaneRotation
local clampPlaneRotation <const> = clampPlaneRotation
local abs <const> = math.abs
local sign <const> = sign
local round <const> = round

local supportedActionsMask <const> = Actions.Left | Actions.Right | Actions.SelfRight
local proportionalInfluence <const> = 0.3
local averagingFactor <const> = 1 + proportionalInfluence

class("AccelerometerInput").extends(RotationInput)

function AccelerometerInput:init(sensitivity)
    AccelerometerInput.super.init(
        self,
        "↺↻"
    )
    print("start accelerometer")
    playdate.startAccelerometer()
    --- weighted average over multiple frames, smooths sensor noise
    self.smoothAccelX = 0
    self.accelXLimit = 1.0 - (sensitivity/10)
end

function AccelerometerInput:update()
    local accelX = readAccelerometer()
    if not accelX then
        return nil
    end
    self.smoothAccelX = (accelX*proportionalInfluence + self.smoothAccelX) / averagingFactor
end

function AccelerometerInput:getInputRotationDeg()
    return (self.smoothAccelX / self.accelXLimit)*180 -- [-180, 180] where 0 is straight up
end

function AccelerometerInput:destroy()
    AccelerometerInput.super.destroy(self)
    print("stop accelerometer")
    playdate.stopAccelerometer()
end
