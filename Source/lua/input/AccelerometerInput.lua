local playdate <const> = playdate
local readAccelerometer <const> = playdate.readAccelerometer

local clampPlaneRotation <const> = clampPlaneRotation
local abs <const> = math.abs

local supportedActionsMask <const> = Actions.Left | Actions.Right | Actions.SelfRight
local activationThreshold <const> = 0.3

class("AccelerometerInput").extends(Input)

function AccelerometerInput:init()
    AccelerometerInput.super.init(self)
    playdate.startAccelerometer()

    --- counter for the current rotation timeout. positive is clockwise timeout, negative is ccw timeout
    self.rotationTimeout = 0
end

function AccelerometerInput:resetRotationTimeout()
    self.rotationTimeout = 0
end

function AccelerometerInput:rotationInput(currentRotation)
    local accelX = readAccelerometer()
    if not accelX then
        return nil
    end

    local change = accelX < -activationThreshold and -1
        or accelX > activationThreshold and 1
        or nil
    if change then
        if self.rotationTimeout == 0 then
            local rotation = clampPlaneRotation(currentRotation + change)
            self.rotationTimeout = change * rotationDelay
            return rotation
        else
            self.rotationTimeout = self.rotationTimeout - change
            return nil
        end
    else
        self:resetRotationTimeout()
        return nil
    end
end

function AccelerometerInput:actionMappingString(action)
    if action & supportedActionsMask ~= 0 then
        return "Tilt"
    else
        return nil
    end
end

--function AccelerometerInput:isTakeOffLandingBlocked(_)
--    return abs(smallestPlaneRotation(18, getAccelerometerPlaneRotation())) > landingTolerance.rotation
--end

function AccelerometerInput:destroy()
    playdate.stopAccelerometer()
end
