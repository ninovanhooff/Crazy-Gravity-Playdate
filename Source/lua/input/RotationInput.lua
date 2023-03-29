local abs <const> = math.abs
local sign <const> = sign
local round <const> = round
local smallestPlaneRotation <const> = smallestPlaneRotation
local clampPlaneRotation <const> = clampPlaneRotation

local supportedActionsMask <const> = Actions.Left | Actions.Right | Actions.SelfRight

class("RotationInput").extends(Input)

function RotationInput:init(getInputRotationDegFun, inputGlyph)
    RotationInput.super.init(self)
    self.getInputRotationDeg = getInputRotationDegFun
    self.inputGlyph = inputGlyph
end

function RotationInput:getPlaneRotation()
    local position = round(self:getInputRotationDeg() / 15) -- 15: 360 degrees / 24 plane angles
    if position == 24 then
        position = 0
    end
    -- position 0..23 where 0 is straight up
    return (position + 18) % 24 -- transform to planeRotation, where 18 is up
end

--function RotationInput:getInputRotationDeg()
--    -- implemented in sub-classes
--end
--
function RotationInput:actionMappingString(action)
    if action & supportedActionsMask ~= 0 then
        return self.inputGlyph
    else
        return nil
    end
end

function RotationInput:rotationInput(currentRotation)
    local RotationRotation = self:getPlaneRotation()
    if RotationRotation == currentRotation then
        return nil
    else
        local newRotation = currentRotation
            + sign(smallestPlaneRotation(RotationRotation, currentRotation))
        return clampPlaneRotation(newRotation)
    end
end

function RotationInput:isTakeOffLandingBlocked(_)
    return abs(smallestPlaneRotation(18, self:getPlaneRotation())) > landingTolerance.rotation
end
