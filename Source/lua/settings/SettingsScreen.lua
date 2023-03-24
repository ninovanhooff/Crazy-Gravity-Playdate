import "SettingsViewModel"

local gfx <const> = playdate.graphics

class("SettingsScreen").extends(Screen)

local settingsViewModel

function SettingsScreen:init()
    SettingsScreen.super.init(self)
    settingsViewModel = SettingsViewModel()
    self.options = GetOptions()
    self.scrimDrawn = false
end

function SettingsScreen:update()
    if not self.scrimDrawn then
        gfx.setDitherPattern(0.5, gfx.image.kDitherTypeBayer2x2) -- invert alpha due to bug in SDK
        gfx.fillRect(0,0, screenWidth, screenHeight)
        self.scrimDrawn = true
    end
    self.options:drawMenu()
    settingsViewModel:update()
end

function SettingsScreen:pause()
    self.options:pause()
    settingsViewModel:pause()
end

function SettingsScreen:resume()
    self.options:resume()
    settingsViewModel:resume()
end

function SettingsScreen:gameWillPause()
    self.options:gameWillPause()
end

function SettingsScreen:deviceWillLock()
    self.options:deviceWillLock()
end
