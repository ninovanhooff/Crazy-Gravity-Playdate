
import "FlyToCreditsView.lua"
import "FlyToCreditsViewModel.lua"

class("FlyToCreditsScreen").extends(Screen)

local flyToCreditsView, flyToCreditsViewModel

function FlyToCreditsScreen:init(exhaustLoopSpecs)
    FlyToCreditsScreen.super.init(self)
    flyToCreditsViewModel = FlyToCreditsViewModel(exhaustLoopSpecs)
    flyToCreditsView = FlyToCreditsView(flyToCreditsViewModel)
end

function FlyToCreditsScreen:update()
    flyToCreditsView:render(flyToCreditsViewModel)
    flyToCreditsViewModel:update()
end

function FlyToCreditsScreen:pause()
    flyToCreditsViewModel:pause()
end

function FlyToCreditsScreen:resume()
    flyToCreditsViewModel:resume()
end
