import "CoreLibs/object"
import "../screen.lua"
import "CreditsView.lua"
import "CreditsViewModel.lua"

class("CreditsScreen").extends(Screen)

local creditsView, creditsViewModel

function CreditsScreen:init()
    CreditsScreen.super.init(self)
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
