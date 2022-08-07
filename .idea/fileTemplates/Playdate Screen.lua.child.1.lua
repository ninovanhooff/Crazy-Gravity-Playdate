import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB

class("${NAME}ViewModel").extends()

function ${NAME}ViewModel:init()
    ${NAME}ViewModel.super.init(self)
    self.displayText = "Hello, this is ${NAME} screen"
end

function ${NAME}ViewModel:update()
    if justPressed(buttonB) then
        popScreen()
    end
end

function ${NAME}ViewModel:pause() end

function ${NAME}ViewModel:resume() end
