import "CoreLibs/object"
import "../screen.lua"
import "CreditsView.lua"
import "CreditsViewModel.lua"

local menu <const> = playdate.getSystemMenu()


class("CreditsScreen").extends(Screen)

local creditsView, creditsViewModel

function CreditsScreen:init()
    CreditsScreen.super.init(self)
    self.origBgColor = gameBgColor
    gameBgColor = playdate.graphics.kColorClear -- todo revert on destroy
    creditsViewModel = CreditsViewModel()
    creditsView = CreditsView(creditsViewModel)
end

function CreditsScreen:update()
    creditsView:render(creditsViewModel)
    creditsViewModel:update()
end

function CreditsScreen:pause()
    creditsViewModel:pause()
    if self.settingsMenuItem then
        menu:removeMenuItem(self.settingsMenuItem)
        self.settingsMenuItem = nil
    end
end

function CreditsScreen:resume()
    self.settingsMenuItem = menu:addMenuItem("Settings", function()
        pushScreen(SettingsScreen())
    end)
    creditsViewModel:resume()
end

function CreditsScreen:destroy()
    creditsViewModel:destroy()
    gameBgColor = self.origBgColor
end

function GameScreen:debugDraw()
    RenderGameDebug()
end
