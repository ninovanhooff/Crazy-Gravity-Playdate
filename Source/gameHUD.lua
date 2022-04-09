---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 14/03/2022 18:51
---

import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local unFlipped <const> = gfx.kImageUnflipped
local font = gfx.font.new("fonts/Asheville Sans 14 Bold/Asheville-Sans-14-Bold")
local monoFont = gfx.font.new("fonts/Rains/font-rains-1x")

local hudIcons = gfx.image.new("images/hud_icons.png")
local hudBgClr = gfx.kColorWhite
local hudFgClr = gfx.kColorBlack
local hudPadding = 8 -- distance between items
local hudGutter = 4 -- distance between item icon and item value

local function drawIcon(x, index)
    hudIcons:draw(x,hudY,unFlipped,index*16,0,16,16)
end

function RenderHUD()
    gfx.setColor(hudBgClr)
    gfx.fillRect(0,hudY,400,16)
    gfx.setColor(hudFgClr)
    local x = hudPadding

    -- lives
    if extras[2] > 0 or frameCounter % 20 > 10 then
        drawIcon(x, 6)
    end
    x = x+16+hudGutter
    font:drawText(extras[2], x, hudY)
    x = x+10+hudPadding

    -- fuel
    if fuel > 1500 or frameCounter % 20 > 10 then
        drawIcon(x, 5)
    end
    x = x+16+hudGutter
    gfx.drawRect(x, hudY+1, 32, 14)
    local fuelW = (fuel/6000)*28
    hudIcons:draw(x+2, hudY+2, gfx.kImageUnflipped,0,16,fuelW,10)
    x = x+32+hudPadding

    -- cargo
    drawIcon(x,7)
    x = x+16+hudGutter
    local containerWidth = extras[3] * 10 + 4
    gfx.drawRect(x, hudY+1, containerWidth, 14)
    for i=0,#planeFreight-1 do
        hudIcons:draw(x+i*10+2, hudY+3, unFlipped, 115, 18,10,10)
    end
    x = x+containerWidth+hudPadding-1

    -- keys
    drawIcon(x, 1)
    x=x+12+hudGutter
    for i=1,4 do
        local subX = (i+1)%2*8
        local subY = boolToNum(i>2)*9
        hudIcons:draw(x+subX, hudY+subY, unFlipped, 32 +subX, boolToNum(keys[i])*16,8,8)
    end
    x = x+15+hudPadding

    -- speed warning
    drawIcon(x, 3)
    x = x+16+hudGutter
    gfx.drawCircleInRect(x+1,hudY+1, 14,14)
    local speedPattern = gfx.image.kDitherTypeBayer4x4
    local warnX = 1/(landingTolerance[1] / math.abs(vx))
    local warnY = 1/(landingTolerance[2] / vy) -- only downwards movement is dangerous
    local warnAlpha = math.max(warnX, warnY)
    gfx.setDitherPattern(1-warnAlpha, speedPattern) -- invert alpha due to bug in SDK
    gfx.fillCircleInRect(x+4,hudY+4, 8,8)
    gfx.setDitherPattern(1, gfx.image.kDitherTypeNone)
    x = x+16+hudPadding

    -- elapsed time
    local eSec = math.floor(frameCounter/frameRate)
    local textW = monoFont:getTextWidth(eSec)
    x = screenWidth - textW - hudPadding
    monoFont:drawText(eSec,x,hudY+8)
    x = x - hudGutter - 16
    drawIcon(x, 4)

    -- remaining time refactor: seems not implemented
    --drawIcon(x, 0)
    --x=x+16+hudGutter
    --font:drawText(lMin*60+lSec,x,hudY)
    --x=x+32+hudPadding
end
