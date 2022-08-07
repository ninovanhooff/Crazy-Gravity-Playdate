import "CoreLibs/object"

local gfx <const> = playdate.graphics

class("${NAME}View").extends()

function ${NAME}View:init()
    ${NAME}View.super.init(self)
end

function ${NAME}View:render(viewModel)
    gfx.drawText(viewModel.displayText, 100,100)
end
