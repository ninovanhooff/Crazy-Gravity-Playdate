---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/04/2022 17:25
---

local gfx <const> = playdate.graphics
local defaultFont <const> = gfx.getFont()
local floor <const> = math.floor
local bgImg <const> = gfx.image.new("images/start_background.png")
local buttonTextHalfHeight <const> = defaultFont:getHeight()*0.5

local function drawButton(button)
    gfx.pushContext()
    local text, x, y,w, h,  progress = button.text, button.x, button.y, button.w, button.h, button.progress
    local fillHeight = progress * h
    local buttonRadius = h * 0.5
    local halfw = w * 0.5

    gfx.setColor(gfx.kColorWhite)
    gfx.setLineWidth(3)
    gfx.drawRoundRect(x, y, w, h, buttonRadius)
    gfx.setClipRect(x, y + h - fillHeight,w,h)
    gfx.fillRoundRect(x,y,w,h,buttonRadius)
    gfx.clearClipRect()

    gfx.pushContext()
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        defaultFont:drawText(
            text,
            x + halfw - defaultFont:getTextWidth(text)*0.5,
            y + h*0.5-buttonTextHalfHeight + 1 -- +1 for baseline tweak
        )
    gfx.popContext()

    gfx.popContext()
end

function RenderStart(viewState)
    gfx.setBackgroundColor(gfx.kColorWhite)
    bgImg:draw(0,0)

    --inspect(viewState)

    -- button
    for _, button in pairs(viewState.buttons) do
        drawButton(button)
    end

    -- plane
    sprite:draw(
        floor(viewState.planeX), floor(viewState.planeY),
        unFlipped,
        viewState.planeRot%16*23, 391+(boolToNum(viewState.planeRot>15)*2-viewState.thrust)*23,
        23, 23
    )

end
