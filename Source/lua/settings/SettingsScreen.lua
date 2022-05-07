import "CoreLibs/object"
import "../screen.lua"
import "SettingsView.lua"
import "SettingsViewModel.lua"

class("SettingsScreen").extends(Screen)

local settingsView, settingsViewModel

function SettingsScreen:init()
    SettingsScreen.super.init(self)
    settingsViewModel = SettingsViewModel()
    settingsView = SettingsView(settingsViewModel)
end

function SettingsScreen:update()
    settingsView:render(settingsViewModel)
    settingsViewModel:update()
end

function SettingsScreen:pause()
    settingsViewModel:pause()
end

function SettingsScreen:resume()
    settingsViewModel:resume()
    settingsView:resume()
end
