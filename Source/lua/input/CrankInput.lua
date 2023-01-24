local getCrankPosition <const> = playdate.getCrankPosition
local abs <const> = math.abs
local sign <const> = sign
local round <const> = round
local smallestPlaneRotation <const> = smallestPlaneRotation
local clampPlaneRotation <const> = clampPlaneRotation

local supportedActionsMask <const> = Input.actionLeft | Input.actionRight | Input.actionSelfRight

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

function CrankInput:isInputPressed(action)
    if action == Input.actionSelfRight then
        return getCrankPlaneRotation() == 18 -- straight up
    else
        return false -- CrankInput supports rotationInput for steering
    end
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

function CrankInput:mappingString(action)
    if action & supportedActionsMask ~= 0 then
        return "🎣"
    else
        return nil
    end
end

function CrankInput:isTakeOffBlocked()
    return abs(smallestPlaneRotation(18, getCrankPlaneRotation())) > landingTolerance.rotation
end
