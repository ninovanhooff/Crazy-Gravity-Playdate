local getCrankPosition <const> = playdate.getCrankPosition
local abs <const> = math.abs
local sign <const> = sign
local round <const> = round
local smallestPlaneRotation <const> = smallestPlaneRotation
local clampPlaneRotation <const> = clampPlaneRotation

local supportedActionsMask <const> = Actions.Left | Actions.Right | Actions.SelfRight

class("CrankInput").extends(Input)

function CrankInput:init()
    CrankInput.super.init(self)
end

local function getCrankPlaneRotation()
    local position = round(getCrankPosition() / 15) -- 15: 360 degrees / 24 plane angles
    if position == 24 then
        position = 0
    end
    -- position 0..23 where 0 is straight up
    return (position + 18) % 24 -- transform to planeRotation, where 18 is up
end

function CrankInput:rotationInput(currentRotation)
    local crankRotation = getCrankPlaneRotation()
    if crankRotation == currentRotation then
        return nil
    else
        local newRotation = currentRotation
            + sign(smallestPlaneRotation(crankRotation, currentRotation))
        return clampPlaneRotation(newRotation)
    end
end

function CrankInput:actionMappingString(action)
    if action & supportedActionsMask ~= 0 then
        return "🎣"
    else
        return nil
    end
end

function CrankInput:isTakeOffLandingBlocked(_)
    return abs(smallestPlaneRotation(18, getCrankPlaneRotation())) > landingTolerance.rotation
end
