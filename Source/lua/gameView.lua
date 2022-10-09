---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 12/03/2022 22:55
---

import "bricksView"

local gfx <const> = playdate.graphics
local floor <const> = math.floor
local unFlipped <const> = playdate.graphics.kImageUnflipped
local planePos <const> = planePos
local camPos <const> = camPos
local specialRenders <const> = specialRenders
local gameWidthTiles <const> = gameWidthTiles
local gameHeightTiles <const> = gameHeightTiles

local gameHUD <const> = gameHUD

--- the active game area, excluding the HUD
local gameClipRect = playdate.geometry.rect.new(0,0, screenWidth, hudY)

function RenderGame(disableHUD)
    gfx.setColor(gfx.kColorBlack)
    gfx.setScreenClipRect(gameClipRect)

    local tilesRendered = bricksView:render()

    for _,item in ipairs(specialT) do -- special blocks
        local scrX,scrY = (item.x-camPos[1])*8-camPos[3],(item.y-camPos[2])*8-camPos[4]
        if item.x+item.w>=camPos[1] and item.x<=camPos[1]+gameWidthTiles+1 and item.y+item.h>=camPos[2] and item.y<camPos[2]+gameHeightTiles+1 then
            specialRenders[item.sType-7](item, scrX, scrY)
        end
    end

    -- HUD
    gfx.clearClipRect()
    if tilesRendered <= 80 and not disableHUD then
        -- only render HUD if we have render budget for it
        -- todo only update changed HUD parts (or only challenge target based on tilesRendered)
        gameHUD:render(tilesRendered >= 50)
    end

    if tilesRendered <= 50 and not disableHUD then
        -- Garbage Collect in frames which are not CPU-intensive
        playdate.setCollectsGarbage(true)
    else
        -- save time on GC
        playdate.setCollectsGarbage(false)
    end

    -- Draw explosion over HUD for extra dramatic effect
    if explosion then
        --explosion
        explosion:render()
    else
        -- plane
        sprite:draw(
            floor((planePos[1]-camPos[1])*8+planePos[3]-camPos[3]),
            floor((planePos[2]-camPos[2])*8+planePos[4]-camPos[4]),
            unFlipped,
            planeRot%16*23, 391+(boolToNum(planeRot>15)*2-thrust)*23,
            23, 23
        )
    end
end

local dXHistory, dYHistory = {}, {}
local dxHistoryMaxLength, dyHistoryMaxLength = 60, 60
local dxHeight, dyHeight = 12, 12
local dxOrigin <const>, dyOrigin <const> = 70, 100

function RenderGameDebug()
    if collision then
        sprite:draw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3], (planePos[2]-camPos[2])*8+planePos[4]-camPos[4], unFlipped, 8*23, 489, 23, 23)
    end
    --- plane collision
    local colOffX = (planePos[1]-camPos[1])*8-camPos[3]
    local colOffY = (planePos[2]-camPos[2])*8-camPos[4]
    gfx.drawLine(colOffX+colT[1],colOffY+colT[2],colOffX+colT[3],colOffY+colT[4])
    gfx.drawLine(colOffX+colT[3],colOffY+colT[4],colOffX+colT[5],colOffY+colT[6])
    gfx.drawLine(colOffX+colT[5],colOffY+colT[6],colOffX+colT[1],colOffY+colT[2])
    
    
    -- Camera debug
    local gameWidthPixels <const> = screenWidth
    local halfGameWidthPixels <const> = gameWidthPixels * 0.5
    local halfGameHeightPixels <const> = gameHeightTiles * tileSize * 0.5
    local crossHairSize = 10
    -- game center crosshair
    --gfx.setDitherPattern(0.5, gfx.image.kDitherTypeDiagonalLine) -- invert alpha due to bug in SDK
    gfx.drawLine(halfGameWidthPixels - crossHairSize, halfGameHeightPixels, halfGameWidthPixels + crossHairSize, halfGameHeightPixels)
    gfx.drawLine(halfGameWidthPixels, halfGameHeightPixels - crossHairSize, halfGameWidthPixels, halfGameHeightPixels + crossHairSize)
    --gfx.setColor(gfx.kColorWhite)

    -- target crosshair
    local targetX, targetY = (TargetX or 0) + halfGameWidthPixels, (TargetY or 0) + halfGameHeightPixels
    gfx.drawLine(targetX - crossHairSize, targetY - crossHairSize, targetX + crossHairSize, targetY + crossHairSize)
    gfx.drawLine(targetX - crossHairSize, targetY + crossHairSize, targetX + crossHairSize, targetY - crossHairSize)
    
    
    if dX then
        table.insert(dXHistory, dX)
    end

    if #dXHistory > dxHistoryMaxLength then
        table.remove(dXHistory, 1)
    end

    if dY then
        table.insert(dYHistory, dY)
    end

    if #dYHistory > dyHistoryMaxLength then
        table.remove(dYHistory, 1)
    end

    -- render dx graph
    for i, item in ipairs(dXHistory) do
        gfx.drawPixel(dxOrigin + i, dxOrigin - item)
    end

    local oldDrawMode = gfx.getImageDrawMode()

    gfx.drawText("dX", dxOrigin - 25, dxOrigin)
    gfx.drawText("dY", dyOrigin - 25, dyOrigin)
    gfx.setImageDrawMode(oldDrawMode) --text color
    gfx.drawLine(dxOrigin, dxOrigin, dxOrigin + dxHistoryMaxLength, dxOrigin)
    gfx.drawLine(dxOrigin, dxOrigin - dxHeight, dxOrigin, dxOrigin + dxHeight)

    -- render dy graph
    for i, item in ipairs(dYHistory) do
        gfx.drawPixel(dyOrigin + i, dyOrigin + item)
    end

    gfx.drawLine(dyOrigin, dyOrigin, dyOrigin + dyHistoryMaxLength, dyOrigin)
    gfx.drawLine(dyOrigin, dyOrigin - dyHeight, dyOrigin, dyOrigin + dyHeight)
end
