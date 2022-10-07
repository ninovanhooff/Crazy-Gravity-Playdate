
import "CreditsView"
import "CreditsViewModel"

class("CreditsScreen").extends(Screen)

local creditsView, creditsViewModel

function CreditsScreen:init()
    CreditsScreen.super.init(self)
    self.origBgColor = gameBgColor
    gameBgColor = playdate.graphics.kColorClear
    creditsViewModel = CreditsViewModel()
    creditsView = CreditsView(creditsViewModel)
end

function CreditsScreen:update()
    creditsView:render(creditsViewModel)
    creditsViewModel:update()
end

function CreditsScreen:pause()
    creditsViewModel:pause()
end

function CreditsScreen:resume()
    creditsViewModel:resume()
end

function CreditsScreen:destroy()
    creditsViewModel:destroy()
    gameBgColor = self.origBgColor
end

function CreditsScreen:debugDraw()
    RenderGameDebug()
end
