import "CoreLibs/object"

local gfx <const> = playdate.graphics
local renderGame <const> = RenderGame

local controlRoomBG = gfx.image.new("images/launch_control_room")

class("EndGameView").extends()

function EndGameView:init()
    EndGameView.super.init(self)
end

function EndGameView:render(viewModel)
    renderGame()
    controlRoomBG:draw(viewModel.controlRoomAnimator:currentValue(),0)
end
