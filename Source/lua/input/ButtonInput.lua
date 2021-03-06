---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/07/2022 17:19
---

class('ButtonInput').extends(Input)

local pressed <const> = playdate.buttonIsPressed
local justPressed <const> = playdate.buttonJustPressed


function ButtonInput:init(mapping)
    self.mapping = mapping
end

function ButtonInput:isInputPressed(action)
    return pressed(self.mapping[action])
end

function ButtonInput:isInputJustPressed(action)
    return justPressed(self.mapping[action])
end
