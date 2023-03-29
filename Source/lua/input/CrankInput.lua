local getCrankPosition <const> = playdate.getCrankPosition

class("CrankInput").extends(RotationInput)

function CrankInput:init()
    CrankInput.super.init(self, getCrankPosition, "🎣")
end
