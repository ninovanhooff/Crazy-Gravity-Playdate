---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 12/03/2022 22:55
---

import "bricksView"

local gfx <const> = playdate.graphics
local geometry <const> = playdate.geometry
local polygon <const> = geometry.polygon
local floor <const> = math.floor
local unFlipped <const> = playdate.graphics.kImageUnflipped
local planePos <const> = planePos
local camPos <const> = camPos
local specialRenders <const> = specialRenders
local screenWidth <const> = screenWidth
local gameWidthTiles <const> = gameWidthTiles
local gameHeightTiles <const> = gameHeightTiles
local gameHeightPixels <const> = gameHeightTiles * tileSize
local tileSize <const> = tileSize
local checkpointImage <const> = gfx.image.new("images/checkpoint_banner.png")
local checkpointImageW <const>, checkpointImageH <const> = checkpointImage:getSize()

local gameHUD <const> = gameHUD

--- the active game area, excluding the HUD
local gameClipRect = playdate.geometry.rect.new(0,0, screenWidth, hudY)

local function renderCheckpointBanner()
    -- font or image? check perf.
    -- if level cleared, use different textO
    local checkpoint <const> = checkpoint
    if checkpoint and checkpoint.animator then
        local scrX <const> = (checkpoint.x-camPos[1])*8-camPos[3] + checkpoint.w/2*tileSize - checkpointImageW*0.5
        local scrY <const> = (checkpoint.y-camPos[2])*8-camPos[4] + checkpoint.animator:currentValue()
        if scrX < -checkpointImageW or scrX > screenWidth or scrY < -checkpointImageH or scrY > gameHeightPixels then
            return
        end
        gfx.setScreenClipRect(0,0, gameClipRect.width, scrY + 32)
        if gameBgColor == gfx.kColorBlack then
            gfx.setImageDrawMode(gfx.kDrawModeInverted)
        end
        checkpointImage:draw(scrX, scrY)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.setScreenClipRect(gameClipRect)
    end
end

local targetingArrowTipRadius <const> = 32 -- pixels
local targetingArrowBaseRadius <const> = 28 -- pixels
--- tip will point exactly at target. Base legs of triangle will be at an offset angle
local targetingArrowAngleDiffRad <const> = math.rad(5)

local function drawHomeBaseIndicator(centerX, centerY)
    local homeBase <const> = homeBase
    --- angle between plane and homeBase in radians
    local homeBaseAngleRad = math.atan(
    -- compare homeBase and planePos centers
        (homeBase.y + homeBase.h*0.5) - (planePos[2] +1.5),
        (homeBase.x + homeBase.w*0.5) - (planePos[1] +1.5)
    )


    --print("targeting homeBaseAngleRad", homeBaseAngleRad, "homeBase angle deg", math.deg(homeBaseAngleRad))

    local targetingPolygon = polygon.new(
    -- left leg
        centerX + math.cos(homeBaseAngleRad - targetingArrowAngleDiffRad)*targetingArrowBaseRadius,
        centerY + math.sin(homeBaseAngleRad - targetingArrowAngleDiffRad)*targetingArrowBaseRadius,
    -- tip
        centerX + math.cos(homeBaseAngleRad)*targetingArrowTipRadius,
        centerY + math.sin(homeBaseAngleRad)*targetingArrowTipRadius,
    -- right leg
        centerX + math.cos(homeBaseAngleRad + targetingArrowAngleDiffRad)*targetingArrowBaseRadius,
        centerY + math.sin(homeBaseAngleRad + targetingArrowAngleDiffRad)*targetingArrowBaseRadius
    )
    gfx.setColor(gameFgColor)
    gfx.drawPolygon(targetingPolygon)
end

function RenderGame(disableHUD)
    gfx.setScreenClipRect(gameClipRect)

    local tilesRendered = bricksView:render()
    for _,item in ipairs(specialT) do -- special blocks
        if item.x+item.w>=camPos[1] and item.x<=camPos[1]+gameWidthTiles+1 and item.y+item.h>=camPos[2] and item.y<camPos[2]+gameHeightTiles+1 then
            local scrX,scrY = (item.x-camPos[1])*8-camPos[3],(item.y-camPos[2])*8-camPos[4]
            specialRenders[item.sType-7](item, scrX, scrY)
        end
    end

    renderCheckpointBanner()

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
        local planeX <const> = floor((planePos[1]-camPos[1])*8+planePos[3]-camPos[3])
        local planeY <const> = floor((planePos[2]-camPos[2])*8+planePos[4]-camPos[4])
        -- plane
        sprite:draw(
            planeX, planeY,
            unFlipped,
            planeRot%16*23, 391+(boolToNum(planeRot>15)*2-thrust)*23,
            23, 23
        )

        if #planeFreight > 0 and not ApproxSpecialCollision(homeBase) then
            drawHomeBaseIndicator(planeX + 12, planeY + 12) -- center of plane is at origin + 12
        end
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
