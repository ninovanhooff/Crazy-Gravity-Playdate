local renderTooltip <const> = Tooltips.renderTooltip
local pressed <const> = playdate.buttonIsPressed
local durationSeconds <const> = 1
local anchorX <const> = screenWidth/2
local anchorY <const> = screenHeight/2

--- Shows a warning to put controls in correct position before the player can leave a playform
class("ConfirmScreen").extends(Screen)

function ConfirmScreen:init(confirmButton, tooltip, confirmHandler)
    ConfirmScreen.super.init(self)
    self.confirmButton = confirmButton
    self.confirmHandler = confirmHandler
    self.tooltip = tooltip
    self.progressPerFrame = (1/durationSeconds)/playdate.display.getRefreshRate()
end

function ConfirmScreen:update()
    local tooltip <const> = self.tooltip
    if not pressed(self.confirmButton) then
        popScreen() -- pop self
    elseif tooltip.progress < 1 then
        tooltip.progress = tooltip.progress + self.progressPerFrame
        renderTooltip(tooltip, anchorX, anchorY)
    else
        popScreen()
        self.confirmHandler()
    end
end

function ConfirmScreen:pause()

end

function ConfirmScreen:resume()

end

function ConfirmScreen:destroy()
    self:pause()
end
