---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/07/2022 17:48
---


import "Input"
import "ButtonInput"

class('InputManager').extends(Input)

function InputManager:init()
    if inputManager ~= nil then
        error("Not creating inputmanager. inputManager already exists")
    end
    InputManager.super.init(self)
    self.inputs = {}
end

-- global Singleton
if not inputManager then
    inputManager = InputManager()
end

function InputManager:setButtonMapping(mapping)
    self.inputs.button = ButtonInput(mapping)
end

--- call-through to all input-managers for a specific function like isInputJustPressed
--- @param func function eg. isInputJustPressed
--- @param action number eg. Input.actionThrottle
local function delegateActionFunction(self, func, action)
    for _, input in pairs(self.inputs) do
        local result = func(input, action)
        if result then
            return result
        end
    end
    return nil
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

--- Describe the mapping for action. eg "⬆/Ⓑ" when the user can press either d-pad up or B-button to trigger action
function InputManager:mappingString(action)
    return delegateActionFunction(self, function(input)
        return input:mappingString(action)
    end)
end
