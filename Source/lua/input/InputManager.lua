import "Input"
import "ButtonInput"
import "CrankInput"

local isCrankDocked <const> = playdate.isCrankDocked
local options <const> = GetOptions()

class('InputManager').extends(Input)

function InputManager:init()
    if inputManager ~= nil then
        error("Not creating inputmanager. inputManager already exists")
    end
    InputManager.super.init(self)
    self.inputs = {}
end

function InputManager:update()
    local docked = isCrankDocked()
    if docked and self.inputs.crank then
        self.inputs.crank = nil
        self:setButtonMapping(options:createButtonMapping(docked))
    elseif not docked and not self.inputs.crank then
        self.inputs.crank = CrankInput()
        self:setButtonMapping(options:createButtonMapping(docked))
    end
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

function InputManager:resetRotationTimeout()
    return delegateActionFunction(self, function(input)
        return input:resetRotationTimeout()
    end)
end

function InputManager:rotationInput(currentRotation)
    return delegateActionFunction(self, function(input)
        return input:rotationInput(currentRotation)
    end)
end

function InputManager:isInputJustPressed(action)
    return delegateActionFunction(self, function(input)
        return input:isInputJustPressed(action)
    end)
end

function InputManager:isTakeOffBlocked()
    return delegateActionFunction(self, function(input)
        return input:isTakeOffBlocked()
    end)
end

--- Describe the mapping for action. eg "⬆/Ⓑ" when the user can press either d-pad up or B-button to trigger action
function InputManager:mappingString(action)
    return delegateActionFunction(self, function(input)
        return input:mappingString(action)
    end)
end
