---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 12/03/2022 22:55
---

import "init.lua"
import "gameHUD.lua"

local gfx = playdate.graphics

function RenderLineVert(maxJ) -- render column bricks, brute force, fail safe
    local i=camPos[1]
    local j = camPos[2]
    while j<= maxJ do
        local curBrick = brickT[i][j]
        if curBrick[1]>2 then
            if curBrick[1]>=7 then --concrete
                pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],8*(curBrick[3]-curBrick[4]),8*(curBrick[3]-curBrick[5]),240+(curBrick[2]*curBrick[3]+curBrick[4])*8,greySumT[curBrick[3]]+curBrick[5]*8,8*(curBrick[3]-curBrick[4]),8*(curBrick[3]-curBrick[5]),0,255)
            elseif curBrick[1]>=3 then --color
                pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],(curBrick[2]-curBrick[4])*8,(curBrick[3]-curBrick[5])*8,(curBrick[1]-3)*48+sumT[curBrick[2]]+curBrick[4]*8,sumT[curBrick[3]]+curBrick[5]*8,(curBrick[2]-curBrick[4])*8,(curBrick[3]-curBrick[5])*8,0,255)
            end
        end
        j = j + curBrick[3]-curBrick[5]
        curBrick = nil
    end
end

--- render a row of bricks, brute force, fail safe
function RenderLineHoriz(maxI)
    i=camPos[1]
    j = camPos[2]
    while i<=maxI do
        curBrick = brickT[i][j]
        if curBrick[1]>2 then
            if curBrick[1]>=7 then --concrete
                pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],8*(curBrick[3]-curBrick[4]),8*(curBrick[3]-curBrick[5]),240+curBrick[2]*curBrick[3]*8,greySumT[curBrick[3]]+curBrick[5]*8,8*(curBrick[3]-curBrick[4]),8*(curBrick[3]-curBrick[5]),0,255)
                i = i + curBrick[3]-curBrick[4]
            elseif curBrick[1]>=3 then --color
                pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],(curBrick[2]-curBrick[4])*8,(curBrick[3]-curBrick[5])*8,(curBrick[1]-3)*48+sumT[curBrick[2]]+curBrick[4]*8,sumT[curBrick[3]]+curBrick[5]*8,(curBrick[2]-curBrick[4])*8,(curBrick[3]-curBrick[5])*8,0,255)
                i = i + curBrick[2]-curBrick[4]
            end
        else
            i = i + curBrick[2]-curBrick[4]
        end

    end
end

function RenderBackground()
    local bgTileSize = 32
    local bgOffX = math.floor(((camPos[1]*8+camPos[3]) % 128)*0.25)
    local bgOffY = math.floor(((camPos[2]*8+camPos[4]) % 128)*0.25)
    for i=0,math.ceil(screenWidth/bgTileSize) do
        for j = 0,math.ceil(hudY/bgTileSize) do
            pgeDraw(i*bgTileSize-bgOffX,j*bgTileSize-bgOffY,bgTileSize,bgTileSize,levelProps.bg*bgTileSize,60,bgTileSize,bgTileSize,0,255)
        end
    end
end

function RenderGame()
    sprite:setInverted(false)
    gfx.setColor(gfx.kColorBlack)

    RenderBackground()

    for i,item in ipairs(specialT) do -- special blocks
        scrX,scrY = (item.x-camPos[1])*8-camPos[3],(item.y-camPos[2])*8-camPos[4]
        if item.x+item.w>=camPos[1] and item.x<=camPos[1]+61 and item.y+item.h>=camPos[2] and item.y<camPos[2]+33 then
            specialRenders[item.sType-7](item)
        end
    end

    maxI=camPos[1]+ gameWidthTiles
    maxJ=camPos[2]+ gameHeightTiles

    RenderLineHoriz(maxI)
    RenderLineVert(maxJ)

    local i = camPos[1]+1
    while i<=maxI do -- bricks
        local j = camPos[2]+1
        while j<=maxJ do
            local curBrick = brickT[i][j]
            if not curBrick then printf("curBrick",i,j,camPos[1],camPos[2]) end
            --if curBrick[1]~=0 then printf(curBrick[2],curBrick[3],curBrick[4],curBrick[5]) end
            if curBrick[1]>2 and curBrick[4]==0 and curBrick[5]==0 then
                if curBrick[1]<7 then --colors
                    pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],curBrick[2]*8,curBrick[3]*8,(curBrick[1]-3)*48+sumT[curBrick[2]],sumT[curBrick[3]],curBrick[2]*8,curBrick[3]*8,0,255)
                    --printf("color:",(i-camPos[1])*8,(j-camPos[2])*8,curBrick[2]*8,curBrick[3]*8,(curBrick[1]-3)*48+sumT[curBrick[2]],sumT[curBrick[3]],curBrick[2]*8,curBrick[3]*8)
                else -- concrete
                    pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],8*curBrick[3],8*curBrick[3],240+curBrick[2]*curBrick[3]*8,greySumT[curBrick[3]],curBrick[3]*8,curBrick[3]*8,0,255)
                end
            end
            j = j + curBrick[3]-curBrick[5]
            curBrick = nil
        end
        i = i + 1
    end

    -- plane
    pgeDraw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3],(planePos[2]-camPos[2])*8+planePos[4]-camPos[4],23,23,planeRot%16*23,391+(boolToNum(planeRot>15)*2-thrust)*23,23,23)

    --explosion
    if collision and not Debug then
        pgeDraw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3]+explodeX,(planePos[2]-camPos[2])*8+planePos[4]-camPos[4]+explodeY,23,23,explodeJ*23,489,23,23)
    end

    RenderHUD()

end
