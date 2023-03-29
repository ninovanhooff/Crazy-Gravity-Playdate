local getCrankPosition <const> = playdate.getCrankPosition

class("CrankInput").extends(RotationInput)

function CrankInput:init()
    CrankInput.super.init(self, "🎣")
end

function CrankInput:getInputRotationDeg()
    return getCrankPosition()
end
