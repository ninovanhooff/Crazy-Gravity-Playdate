local getCrankPosition <const> = playdate.getCrankPosition

class("CrankInput").extends(Input)

function CrankInput:init()
    CrankInput.super.init(self)
end

local function getCrankPlaneRotation()
    local position = roundToNearest(getCrankPosition() / 15, 1) -- 15: 360 degrees / 24 plane angles
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
        return crankRotation
    end
end
