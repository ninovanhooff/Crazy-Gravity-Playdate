---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 14/03/2022 18:51
---

import "CoreLibs/graphics"

local gfx <const> = playdate.graphics
local font = gfx.font.new("fonts/Asheville Sans 14 Bold/Asheville-Sans-14-Bold")

local hudIcons = gfx.image.new("images/hud_icons.png")
local hudBgClr = gfx.kColorWhite
local hudFgClr = gfx.kColorBlack
local hudPadding = 10 -- distance between items
local hudGutter = 4 -- distance between item icon and item value

local function drawIcon(x, index)
    hudIcons:draw(x,hudY,gfx.kImageUnflipped,index*16,0,16,16)
end

function RenderHUD()
    gfx.setColor(hudBgClr)
    gfx.fillRect(0,hudY,400,16)
    gfx.setColor(hudFgClr)
    local x = hudPadding

    -- lives
    drawIcon(x, 7)
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

    drawIcon(x, 4)
    x=x+16+hudGutter
    local eSec = math.floor(frameCounter*0.05) -- todo
    font:drawText(eSec,x,hudY)
    x=x+32+hudPadding


    --local freightPosCount = 0
    --for i,item in ipairs(remainingFreight) do
    --    for j=0,math.min(item-1,7) do
    --        pgeDraw(32+freightPosCount*13,hudY+3,12,12,64+i*16,346,16,16)
    --        freightPosCount = freightPosCount + 1
    --    end
    --end
    --
    --local planeFreightX = 147
    --pgeDraw(planeFreightX,hudY+1,28,14,260,314,28,14) -- planeFreight stat
    --drawInterfaceBox(planeFreightX+29,14*extras[3])
    --for i,item in ipairs(planeFreight) do
    --    pgeDraw(planeFreightX+31+(i-1)*13,hudY+3,12,12,80+item[1]*16,346,16,16)
    --end
    --
    --local keysX = 220
    --pgeDraw(keysX,hudY+1,28,14,344,314,28,14) -- keys
    --drawInterfaceBox(keysX+30,50)
    --for i=1,4 do
    --    if keys[i] then
    --        pgeDraw(keysX+32+(i-1)*12,hudY+3,12,12,185+(frameCounter % 7)*16,414+(i-1)*16,16,16)
    --    end
    --end
    --

    --for i=0,extras[2]-1 do -- lives
    --    pgeDraw(5+i*25,5,23,23,46,414,23,23,0,180)
    --end
    --
    --drawInterfaceBox(382,75) -- Time
    ----gfx.setImageDrawMode()
    --pgeDrawText(384,hudY+4,green,TimeString(frameCounter*0.05).."/"..lMin..":"..lSec)
    --
end
