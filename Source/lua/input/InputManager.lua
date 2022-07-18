---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/07/2022 17:48
---

import "CoreLibs/object"
import "Input"
import "ButtonInput"

class('InputManager').extends(Input)

InputManager.actionLeft = 1
InputManager.actionRight = 2
InputManager.actionThrottle = 3
InputManager.actionSelfRight = 4

function InputManager:init()
    if inputManager ~= nil then
        error("Not creating inputmanager. inputManager already exists")
    end
    InputManager.super.init()
    self.inputs = {}
end

-- global Singleton
if not inputManager then
    inputManager = InputManager()
end

function InputManager:setButtonMapping(mapping)
    self.inputs.button = ButtonInput(mapping)
end

local function delegateActionFunction(self, func, action)
    for _, input in pairs(self.inputs) do
        if func(input, action) then
            return true
        end
    end
    return false
end

function InputManager:isInputPressed(action)
    return delegateActionFunction(self, function(input)
        return input:isInputPressed(action)
    end)
end

function InputManager:isInputJustPressed(action)
    return delegateActionFunction(self, function(input)
        return input:isInputJustPressed(action)
    end)
end