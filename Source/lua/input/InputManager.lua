import "Input"
import "ButtonInput"
import "AccelerometerInput"
import "CrankInput"

local isCrankDocked <const> = playdate.isCrankDocked
local options <const> = GetOptions()
local currentTime <const> = playdate.sound.getCurrentTime

class('InputManager').extends(Input)

function InputManager:setButtonMapping(mapping)
    print("setButtonMap", mapping)
    self.inputs.button = ButtonInput(mapping)
end

function InputManager:destroyAccelerometer()
    if self.inputs.accelerometer then
        self.inputs.accelerometer:destroy()
        self.inputs.accelerometer = nil
    end
end

function InputManager:configureInputs()
    print("config inputs")
    local docked <const> = isCrankDocked()
    if docked then
        self.inputs.accelerometer = AccelerometerInput()
        self.inputs.crank = nil
    else
        self:destroyAccelerometer()
        self.inputs.crank = CrankInput()
    end
    self:setButtonMapping(
        options:createButtonMapping(docked)
    )
end

function InputManager:init()
    if inputManager ~= nil then
        error("Not creating inputmanager. inputManager already exists")
    end
    InputManager.super.init(self)
    --- amount of seconds since last dock/undock of the crank. Initial state not considered a change.
    self.lastDockedChangeTime = -1337.0 -- before epoch time == infinitely long ago
    self.inputs = {}
    self:configureInputs()
end

-- global Singleton
if not inputManager then
    inputManager = InputManager()
end

function InputManager:update()
    if isCrankDocked() ~= (self.inputs.crank == nil) then
        self:configureInputs()
        self.lastDockedChangeTime = currentTime()
    end
end

--- call-through to all input-managers for a specific function like isInputJustPressed
--- @param func function eg. isInputJustPressed
--- @param action number eg. Actions.Throttle
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

function InputManager:isTakeOffLandingBlocked(currentRotation)
    return delegateActionFunction(self, function(input)
        return input:isTakeOffLandingBlocked(currentRotation)
    end)
end

function InputManager:inputType()
    if self.inputs.crank then
        return "Crank Controls"
    else
        return "Button Controls"
    end
end

local allDisplayActions <const> = {
    Actions.SelfRight,
    Actions.Throttle,
    Actions.Left,
    Actions.Right,
}
function InputManager:fullMappingString()
    local singleActionMap = map(allDisplayActions, function(item)
        return {
            buttonGlyph= self:actionMappingString(item),
            action=item
        }
    end)

    local reducedActionMap = {}

    for _, item in ipairs(singleActionMap) do
        reducedActionMap[item.buttonGlyph] = reducedActionMap[item.buttonGlyph] or {}
        table.insert(reducedActionMap[item.buttonGlyph], Actions.Labels[item.action])
    end

    local finalArray = {}

    for k,v in pairs(reducedActionMap) do
        table.insert(finalArray, k ..":"..table.concat(v, ","))
    end

    return table.concat(
        finalArray,
        "   "
    )
end

--- Describe the mapping for action. eg "⬆/Ⓑ" when the user can press either d-pad up or B-button to trigger action
function InputManager:actionMappingString(action)
    return delegateActionFunction(self, function(input)
        return input:actionMappingString(action)
    end)
end
