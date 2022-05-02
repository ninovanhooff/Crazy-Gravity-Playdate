#set($NAME_LOW = $NAME.substring(0,1).toLowerCase() + $NAME.substring(1))

import "CoreLibs/object"
import "../screen.lua"
import "${NAME}View.lua"
import "${NAME}ViewModel.lua"

class("${NAME}Screen").extends(Screen)

local ${NAME_LOW}View, ${NAME_LOW}ViewModel

function ${NAME}Screen:init()
    ${NAME}Screen.super.init(self)
    ${NAME_LOW}ViewModel = ${NAME}ViewModel()
    ${NAME_LOW}View = ${NAME}View(${NAME_LOW}ViewModel)
end

function ${NAME}Screen:update()
    ${NAME_LOW}View:render(${NAME_LOW}ViewModel)
    ${NAME_LOW}ViewModel:update()
end

function ${NAME}Screen:pause()
    ${NAME_LOW}ViewModel:pause()
end

function ${NAME}Screen:resume()
    ${NAME_LOW}ViewModel:resume()
end