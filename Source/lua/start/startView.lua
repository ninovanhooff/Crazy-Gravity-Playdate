---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/04/2022 17:25
---

local gfx <const> = playdate.graphics

function RenderStart()
    gfx.setLineWidth(3)
    gfx.drawRoundRect(200,100,100,24,12)
end
