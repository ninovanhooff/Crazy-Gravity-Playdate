
import "BonusContentView"
import "BonusContentViewModel"

class("BonusContentScreen").extends(Screen)

local bonusContentView, bonusContentViewModel

function BonusContentScreen:init()
    BonusContentScreen.super.init(self)
    bonusContentViewModel = BonusContentViewModel()
    bonusContentView = BonusContentView(bonusContentViewModel)
end

function BonusContentScreen:update()
    bonusContentView:render(bonusContentViewModel)
    bonusContentViewModel:update()
end

function BonusContentScreen:pause()
    bonusContentViewModel:pause()
end

function BonusContentScreen:resume()
    bonusContentViewModel:resume()
end
