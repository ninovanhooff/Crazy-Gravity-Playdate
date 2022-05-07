import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("SettingsViewModel").extends()

function SettingsViewModel:init()
    self.displayText = "Hello, this is Settings screen"
end

function SettingsViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function SettingsViewModel:pause()
end

function SettingsViewModel:resume()
end
