local playdate <const> = playdate
local readAccelerometer <const> = playdate.readAccelerometer

local smallestPlaneRotation <const> = smallestPlaneRotation
local clampPlaneRotation <const> = clampPlaneRotation
local abs <const> = math.abs
local sign <const> = sign
local round <const> = round

local supportedActionsMask <const> = Actions.Left | Actions.Right | Actions.SelfRight
local activationThreshold <const> = 0.6
local proportionalInfluence <const> = 0.3
local averagingFactor <const> = 1 + proportionalInfluence

class("AccelerometerInput").extends(Input)

function AccelerometerInput:init()
    AccelerometerInput.super.init(self)
    playdate.startAccelerometer()
    self.prevAccelX = 0
end

local function getAccelerometerPlaneRotation(accelX)
    local position = (accelX / activationThreshold)+1 -- [0, 2] where 1 is straight up
    position = position * 12 -- [0 .. 24] where 12 is straight up
    return round((position + 6) % 24) -- transform to planeRotation, where 18 is up
end

function AccelerometerInput:rotationInput(currentRotation)
    local accelX = readAccelerometer()
    if not accelX then
        return nil
    end
    local smoothAccelX = (accelX*proportionalInfluence + self.prevAccelX) / averagingFactor
    local accelerometerRotation = getAccelerometerPlaneRotation(smoothAccelX)
    self.prevAccelX = smoothAccelX
    print(accelX, accelerometerRotation)
    if accelerometerRotation == currentRotation then
        return nil
    else
        local newRotation = currentRotation
            + sign(smallestPlaneRotation(accelerometerRotation, currentRotation))
        return clampPlaneRotation(newRotation)
    end
end


function AccelerometerInput:actionMappingString(action)
    if action & supportedActionsMask ~= 0 then
        return "Tilt"
    else
        return nil
    end
end

function AccelerometerInput:isTakeOffLandingBlocked(_)
    local accelX = readAccelerometer()
    if not accelX then
        return false
    end
    return abs(smallestPlaneRotation(18, getAccelerometerPlaneRotation(accelX)))
        > landingTolerance.rotation
end

function AccelerometerInput:destroy()
    playdate.stopAccelerometer()
end
