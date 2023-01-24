local options <const> = GetOptions()
local inputManager <const> = inputManager
local renderSelfRightTooltip <const> = RenderSelfRightTooltip
local floor <const> = math.floor

class("TakeOffLandingScreen").extends(Screen)

function TakeOffLandingScreen:init(x, y)
    TakeOffLandingScreen.super.init(self)
    self.x = x or floor((planePos[1]-camPos[1])*8+planePos[3]-camPos[3]) + 12
    self.y = y or floor((planePos[2]-camPos[2])*8+planePos[4]-camPos[4]) + 40
end

function TakeOffLandingScreen:update()
    if not inputManager:isTakeOffBlocked(Input.actionSelfRight) then
        options:setSelfRightTipShown(true)
        options:saveUserOptions()
        popScreen()
    end
end

function TakeOffLandingScreen:resume()
    renderSelfRightTooltip(self.x,self.y)
end
