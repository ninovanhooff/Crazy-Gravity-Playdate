import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local halfScreenHeight <const> = screenHeight/2
local round <const> = lume.round

class("CreditsViewModel").extends(PlanePhysicsViewModel)

function CreditsViewModel:init()
    CreditsViewModel.super.init(self)
    self.planeX, self.planeY = 106, screenHeight - 10
    self.creditsY = 0
end

function CreditsViewModel:update()
    self:processInputs()
    self:calcPlane()

    local creditsSpeed = ((halfScreenHeight - self.planeY) / halfScreenHeight)*4
    self.creditsY = round(self.creditsY + creditsSpeed)
    self.planeY = self.planeY + creditsSpeed*4

    if justPressed(buttonB) then
        popScreen()
    end
end

function CreditsViewModel:pause()
end

function CreditsViewModel:resume()
end
