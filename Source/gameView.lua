---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 12/03/2022 22:55
---

import "init.lua"
import "gameHUD.lua"
import "bricksView.lua"

local gfx <const> = playdate.graphics
local unFlipped <const> = playdate.graphics.kImageUnflipped

--- the active game area, excluding the HUD
local gameClipRect = playdate.geometry.rect.new(0,0, screenWidth, hudY)

function RenderGame()
    gfx.setColor(gfx.kColorBlack)
    gfx.setScreenClipRect(gameClipRect)

    local tilesRendered = bricksView:render()

    for i,item in ipairs(specialT) do -- special blocks
        scrX,scrY = (item.x-camPos[1])*8-camPos[3],(item.y-camPos[2])*8-camPos[4]
        if item.x+item.w>=camPos[1] and item.x<=camPos[1]+gameWidthTiles+1 and item.y+item.h>=camPos[2] and item.y<camPos[2]+gameHeightTiles+1 then
            specialRenders[item.sType-7](item)
        end
    end

    if explosion then
        --explosion
        explosion:render()
    else
        -- plane
        sprite:draw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3], (planePos[2]-camPos[2])*8+planePos[4]-camPos[4], unFlipped, planeRot%16*23, 391+(boolToNum(planeRot>15)*2-thrust)*23, 23, 23)
    end

    -- HUD
    gfx.clearClipRect()
    if tilesRendered <= 80 then -- only render HUD if we have render budget for it
        RenderHUD()
    end
end
