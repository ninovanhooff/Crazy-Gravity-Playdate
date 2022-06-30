import "CoreLibs/object"
import "../screen.lua"
import "SettingsView.lua"
import "SettingsViewModel.lua"
import "Options.lua"

class("SettingsScreen").extends(Screen)

local settingsView, settingsViewModel

function SettingsScreen:init()
    SettingsScreen.super.init(self)
    settingsViewModel = SettingsViewModel()
    settingsView = SettingsView(settingsViewModel)
    self.options = Options()
    self.options:show()
end

function SettingsScreen:update()
    --settingsView:render(settingsViewModel)
    self.options:drawMenu()
    settingsViewModel:update()
end

function SettingsScreen:pause()
    settingsViewModel:pause()
end

function SettingsScreen:resume()
    settingsViewModel:resume()
end
