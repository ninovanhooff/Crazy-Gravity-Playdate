import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("SettingsView").extends()

function SettingsView:render(viewModel)
    gfx.drawText(viewModel.displayText, 100, 100)
end
