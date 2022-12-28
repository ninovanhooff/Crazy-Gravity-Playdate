---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/07/2022 17:19
---
local clampPlaneRotation <const> = clampPlaneRotation

local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB
local buttonUp <const> = playdate.kButtonUp
local buttonDown <const> = playdate.kButtonDown
local buttonLeft <const> = playdate.kButtonLeft
local buttonRight <const> = playdate.kButtonRight

local actionLeft <const> = Input.actionLeft
local actionRight <const> = Input.actionRight

local buttonGlyphs <const> = {
    [buttonLeft] = "⬅",
    [buttonRight] = "➡",
    [buttonUp] = "⬆",
    [buttonDown] = "️⬇",
    [buttonB] = "Ⓑ",
    [buttonA] = "Ⓐ",
}

class('ButtonInput').extends(Input)

local pressed <const> = playdate.buttonIsPressed
local justPressed <const> = playdate.buttonJustPressed


function ButtonInput:init(mapping)
    ButtonInput.super.init(self)
    self.mapping = mapping

    --- counter for the current rotation timeout. positive is clockwise timeout, negative is ccw timeout
    self.rotationTimeout = 0
end

function ButtonInput:isInputPressed(action)
    return pressed(self.mapping[action])
end

function ButtonInput:isInputJustPressed(action)
    return justPressed(self.mapping[action])
end

function ButtonInput:resetRotationTimeout()
    self.rotationTimeout = 0
end

function ButtonInput:rotationInput(currentRotation)
    print(self.rotationTimeout)
    local change =  self:isInputPressed(actionLeft) and -1
        or self:isInputPressed(actionRight) and 1
        or nil
    if change then
        if self.rotationTimeout == 0 then
            local rotation = clampPlaneRotation(currentRotation + change)
            self.rotationTimeout = change * rotationDelay
            return rotation
        else
            self.rotationTimeout = self.rotationTimeout - change
            return nil
        end
    else
        self:resetRotationTimeout()
        return nil
    end
end

function ButtonInput:mappingString(action)
    local buttonMask = self.mapping[action]
    local buttonSymbols = {}
    for button, glyph in pairs(buttonGlyphs) do
        if buttonMask & button ~= 0 then
            table.insert(buttonSymbols, glyph)
        end
    end

    return table.concat(buttonSymbols, "/")
end
