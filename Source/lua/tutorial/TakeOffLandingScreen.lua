local menu <const> = playdate.getSystemMenu()
local options <const> = GetOptions()
local inputManager <const> = inputManager
local renderSelfRightTooltip <const> = RenderSelfRightTooltip
local floor <const> = math.floor

--- Shows a warning to put controls in correct position before the player can leave a playform
class("TakeOffLandingScreen").extends(Screen)

function TakeOffLandingScreen:init(x, y)
    TakeOffLandingScreen.super.init(self)
    self.x = x or floor((planePos[1]-camPos[1])*8+planePos[3]-camPos[3]) + 12
    self.y = y or floor((planePos[2]-camPos[2])*8+planePos[4]-camPos[4]) + 40
end

function TakeOffLandingScreen:update()
    if not inputManager:isTakeOffLandingBlocked(planeRot) then
        options:setSelfRightTipShown(true)
        options:saveUserOptions()
        popScreen()
    end
end

function TakeOffLandingScreen:pause()
    if Sounds then thrust_sound:stop() end
end

function TakeOffLandingScreen:resume()
    renderSelfRightTooltip(self.x,self.y)

    menu:addMenuItem("Settings", function()
        require "lua/settings/SettingsScreen"
        popScreen() -- remove self because we cannot restore our drawing state
        pushScreen(SettingsScreen())
    end)
    menu:addMenuItem("Quit level", function()
        popScreen() -- remove self
        popScreen() -- remove gameScreen
    end)
    menu:addMenuItem("Restart level", function()
        popScreen() -- remove self
        ResetGame()
    end)
end

function TakeOffLandingScreen:destroy()
    self:pause()
end
