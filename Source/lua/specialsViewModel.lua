---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 03/04/2022 16:59
---

import "game-over/GameOverScreen"

local abs <const> = math.abs
local ceil <const> = math.ceil
local floor <const> = math.floor
local min <const> = math.min
local max <const> = math.max
local random <const> = math.random
local gameHUD <const> = gameHUD
local tileSize <const> = tileSize
local planePos <const> = planePos

local barrierSpeed <const> = 2
-- #frames between rods speed or direction change when chngOften is enabled
local rodsChangeTimeoutMin <const> = 30
local rodsChangeTimeoutMax <const> = 90

local function UnitCollision(x,y,w,h,testMode)
    --printf(x,y,w,h)
    for i=1,5,2 do
        if colBT[i]>=x and colBT[i]<x+w and colBT[i+1]>=y and colBT[i+1]<y+h then
            if not testMode then collision = true end
            return true
        end
    end
    return false
end

-- returns true if this rect may collide with planePos, does not take plane sub-pos ([3] and 4]) into
-- account. When false, it is guaranteed that this rect does not intersect with the plane
local function ApproxRectCollision(x, y, w, h)
    -- plane size is 3
    return planePos[1]+3 > x and planePos[1] < x+w  and planePos[2]+3 > y and planePos[2] <y+h
end

local function PixelCollision(x,y,w,h) -- needs work?
    local leftX = planePos[1]*8
    local topY = planePos[2]*8
    local colT <const> = colT
    for i=1,9,2 do
        --printf("pixelCol",planePos[1]*8+colT[i],x,planePos[2]*8+colT[i+1],y)
        --printf(planePos[1]*8+colT[i],x,planePos[2]*8+colT[i+1],y)
        if leftX+colT[i]>x and leftX+colT[i]<=x+w and topY+colT[i+1]>=y and topY+colT[i+1]<=y+h then -- -1
            collision = true
            return true
        end
    end
    return false
end

function CalcPlatform(item,idx)
    if not ApproxRectCollision(item.x,item.y-3, item.w, item.h) then
        return -- out of range
    end
    --platform collision
    if PixelCollision(item.x*8,item.y*8+32,item.w*8,16) and (planeRot~=18 or(vy > landingTolerance[2] or abs(vx)> landingTolerance[1]))   then
        collision = true
        print("platform collide!!")
    end

    -- don't collide on take-off
    if abs(planeRot - 18) <= 3 and vy<0  then
        collision = false
    end

    --landing
    if flying and planeRot == 18 then -- upright
        if planePos[2]==item.y+1 and planePos[1]>=item.x-2 and planePos[1]<item.x+item.w-1 and planePos[4]>=3 and vy>0 and vy <= landingTolerance[2] and abs(vx)<= landingTolerance[1] then
            flying = false
            collision = false
            vx,vy=0,0
            planePos[4]=4
            printf("LANDED AT",idx)
            landedTimer = 0
            landedAt = idx
            if Sounds then landing_sound:play() end
        end
    elseif not flying then
        if landedTimer>frameRate/2 and landedAt==idx then -- 1 secs and landed at cur pltfrm
            --printf(item.pType,#planeFreight,"HJ")
            if item.pType==1 and #planeFreight>0 then -- dump
                if Sounds then
                    dump_sound:play()
                end
                table.remove(planeFreight,1)
                if table.sum(remainingFreight)==0 and #planeFreight == 0 then
                    printf("VICTORY")
                    updateRecords(currentLevel, {
                        frameCounter / frameRate,
                        fuelSpent,
                        livesLost
                    })
                    RenderGame()
                    playdate.wait(500) -- Show player that there is no more remaining freight
                    pushScreen(GameOverScreen("LEVEL_CLEARED"))
                else
                    printf("HUH",table.sum(remainingFreight))
                end
            elseif item.amnt>0 then --pickup
                printf(#planeFreight,extras[3],pType)
                if item.pType==2 and #planeFreight<extras[3] then -- freight
                    remainingFreight[item.type+1] = remainingFreight[item.type+1] -1
                    table.insert(planeFreight,{item.type,landedAt})
                    item.amnt = item.amnt -1
                    if Sounds then pickup_sound:play() end
                elseif item.pType==3 and fuel<6000 then -- fuel
                    fuel = min(6000,fuel+3000)
                    item.amnt = item.amnt -1
                    if Sounds then fuel_sound:play() end
                elseif item.pType==4 and item.amnt>0 then -- extras
                    extras[item.type]=extras[item.type]+1
                    gameHUD:onChanged(item.type)
                    item.amnt = item.amnt -1
                    if Sounds then extra_sounds[item.type]:play() end
                elseif item.pType==5 then -- key
                    printf("KEY",item.color)
                    keys[item.color]=true
                    item.amnt = item.amnt -1
                    gameHUD:onChanged(4)
                    if Sounds then key_sound:play() end
                end
            end
            landedTimer = 0
        else
            landedTimer = landedTimer + 1
        end
    end

end

function CalcBlower(item)
    if not flying then return end

    if item.direction==1 then --up
        if UnitCollision(item.x,item.y,6,item.distance,true) then
            local mult = item.distance-(item.y+item.distance - planePos[2])
            vy = vy - (mult/item.distance)*blowerStrength*(1+item.grating)
        end
    elseif item.direction==2 then --down
        if UnitCollision(item.x,item.y+8,6,item.distance,true) then
            local mult = item.distance-(planePos[2] - (item.y+8))
            vy = vy + (mult/item.distance)*blowerStrength*(item.grating*0.5)
        end
    elseif item.direction==3 then --left
        if UnitCollision(item.x,item.y,item.distance,6,true) then
            local mult = item.distance-(item.x+item.distance - planePos[1])
            vx = vx - (mult/item.distance)*blowerStrength*(0.5+item.grating)
        end
    elseif item.direction==4 then --right
        if UnitCollision(item.x+8,item.y,item.distance,6,true) then
            local mult = item.distance-(planePos[1] - (item.x+8))
            vx = vx + (mult/item.distance)*blowerStrength*(0.5+item.grating)
        end
    end
end

function CalcMagnet(item)
    if not flying then return end

    if item.direction==1 then --up
        if UnitCollision(item.x,item.y,4,item.distance,true) then
            local mult = item.distance-(item.y+item.distance - planePos[2])
            vy = vy + (mult/item.distance)*magnetStrength
        end
    elseif item.direction==2 then --down
        if UnitCollision(item.x,item.y+6,4,item.distance,true) then
            local mult = item.distance-(planePos[2] - (item.y+6))
            vy = vy - (mult/item.distance)*magnetStrength
        end
    elseif item.direction==3 then --left
        if UnitCollision(item.x,item.y,item.distance,4,true) then
            local mult = item.distance-(item.x+item.distance - planePos[1])
            vx = vx + (mult/item.distance)*magnetStrength
        end
    elseif item.direction==4 then --right
        if UnitCollision(item.x+6,item.y,item.distance,4,true) then
            local mult = item.distance-(planePos[1] - (item.x+6))
            vx = vx - (mult/item.distance)*magnetStrength
        end
    end
end

function CalcRotator(item)
    if not flying then return end

    if (item.direction==1 and UnitCollision(item.x,item.y,5,item.distance,true))
            or (item.direction==2 and UnitCollision(item.x,item.y+8,5,item.distance,true))
            or (item.direction==3 and UnitCollision(item.x,item.y,item.distance,5,true))
            or (item.direction==4 and UnitCollision(item.x+8,item.y,item.distance,5,true)) then
        if frameCounter%3==1 then
            if item.rotates==1 then -- left
                planeRot = planeRot - 1
                if planeRot<0 then
                    planeRot = 23
                end
            else
                planeRot = planeRot + 1
                planeRot = planeRot % 24
            end
            printf(planeRot)
            --planeRot = random(planeRot,0) -- refactor: no clue why this line was here, but it crashes due to invalid range
        end
    end
end

local function planeIntersectsCannon(item)
    if item.direction==1 then -- up
        return ApproxRectCollision(item.x,item.y,3,item.distance)
    elseif item.direction==2 then -- down
        return ApproxRectCollision(item.x,item.y+5,3,item.distance)
    elseif item.direction==3 then -- left
        return ApproxRectCollision(item.x,item.y,item.distance,3)
    else -- right
        return ApproxRectCollision(item.x+5,item.y,item.distance,3)
    end
end

function CalcCannon(item,idx)

    if not planeIntersectsCannon(item) then return end

    local pos = (frameCounter %  item.rate) * item.speed
    while pos < item.maxPos do
        -- ball collision
        if item.direction==1 then
            PixelCollision(item.ballX,(item.y+item.distance)*8-pos,8,8)--+2
        elseif item.direction==2 then
            PixelCollision(item.ballX,item.y*8+pos+24,8,8)
        elseif item.direction==3 then
            PixelCollision((item.x+item.distance)*8-pos,item.ballY,8,8)
        else
            PixelCollision(item.x*8+24+pos, item.ballY,8,8)
        end
        pos = pos + item.speed*item.rate
    end
end

function CalcRod(item)
    if item.pos1+item.pos2>=item.distance*8-24 then
        item.d1=-1
        item.speed1 = random(item.speedMin,item.speedMax)
        item.nextChangeFrame = frameCounter + random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
    elseif item.pos1<2 then
        item.d1=1
        item.speed1 = random(item.speedMin,item.speedMax)
        item.nextChangeFrame = frameCounter + random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
    elseif (item.chngOften==1 and frameCounter > item.nextChangeFrame) then
        item.d1=-1+random(0,1)*2
        item.speed1 = random(item.speedMin,item.speedMax)
        item.nextChangeFrame = frameCounter + random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
    end
    if item.fixdGap == 1 then
        if item.pos2<2 then
            item.d1 = -1
            item.nextChangeFrame = frameCounter + random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
        end
        item.speed2=item.speed1
        item.d2=-item.d1
    elseif item.pos1+item.pos2>=item.distance*8-24 then
        item.d2=-1
        item.speed2 = random(item.speedMin,item.speedMax)
        item.nextChangeFrame = frameCounter + random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
    elseif item.pos2<2 then
        item.d2=1
        item.speed2 = random(item.speedMin,item.speedMax)
        item.nextChangeFrame = frameCounter + random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
    elseif (item.chngOften==1 and frameCounter > item.nextChangeFrame) then
        item.d2=-1+random(0,1)*2
        item.speed2 = random(item.speedMin,item.speedMax)
        item.nextChangeFrame = frameCounter + random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
    end
    item.pos1 = item.pos1+item.speed1*item.d1
    item.pos2 = item.pos2+item.speed2*item.d2
    if item.direction==1 then -- horiz
        PixelCollision(item.x*8+24,item.y*8+6,item.pos1,12) -- left rod
        PixelCollision(item.x*8+item.distance*8-item.pos2,item.y*8+6,item.pos2,12) -- right rod
    else -- vert
        PixelCollision(item.x*8+6,item.y*8+24,12,item.pos1) -- top
        PixelCollision(item.x*8+6,item.y*8+item.distance*8-item.pos2,12,item.pos2) -- bottom
    end
end

local wrongWayTriggerSize <const> = 12
function Calc1Way(item)
    local activated = false
    local unitCollision = false
    item.showWrongWay = false
    if item.direction==1 then --up
        if UnitCollision(item.unitCollisionX, item.unitCollisionY, item.actW + wrongWayTriggerSize,item.actH,true) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[1] < item.x + 5) or (item.XtoY == 2 and planePos[1] > item.x + 5)
            PixelCollision(item.x*8+32,(item.y+item.distance)*8-4-item.pos,32,item.pos)
        end
    elseif item.direction==2 then --down
        if UnitCollision(item.unitCollisionX, item.unitCollisionY,item.actW + wrongWayTriggerSize,item.actH,true) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[1] < item.x + 5) or (item.XtoY == 2 and planePos[1] > item.x + 5)
            PixelCollision(item.x*8+32,item.y*8+36,32,item.pos)
        end
    elseif item.direction==3 then --left
        if UnitCollision(item.unitCollisionX, item.unitCollisionY,item.actW,item.actH+wrongWayTriggerSize,true) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[2] < item.y + 5) or (item.XtoY == 2 and planePos[2] > item.y + 5)
            PixelCollision((item.x+item.distance)*8-4-item.pos,item.y*8+32,item.pos,32)
        end
    elseif item.direction==4 then --right
        if UnitCollision(
            item.unitCollisionX,
            item.unitCollisionY,
            item.actW,item.actH+wrongWayTriggerSize,true
        ) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[2] < item.y + 5) or (item.XtoY == 2 and planePos[2] > item.y + 5)
            PixelCollision(item.x*8+36,item.y*8+32,item.pos,32)
        end
    end
    if explosion then
        activated = false
    end
    if activated then
        item.pos = item.pos - barrierSpeed
    else
        item.pos = item.pos+barrierSpeed
    end
    item.pos = clamp(item.pos, 0, item.closedPos)
    if unitCollision and not activated and item.pos == item.closedPos then
        item.showWrongWay = true
    end
end

function CalcBarrier(item)
    item.activated = false
    -- gate collision
    if item.direction==1 then --up
        if UnitCollision(item.x+3-item.actW*0.5,item.y+item.distance*0.5-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            PixelCollision(item.x*8+8,(item.y+item.distance)*8-4-item.pos,32,item.pos)
        end
    elseif item.direction==2 then --down
        if UnitCollision(item.x+3-item.actW*0.5,item.y+3+item.distance*0.5-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            PixelCollision(item.x*8+8,item.y*8+36,32,item.pos)
        end
    elseif item.direction==3 then --left
        if UnitCollision(item.x+item.distance*0.5-item.actW*0.5,item.y+3-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            PixelCollision((item.x+item.distance)*8-4-item.pos,item.y*8+8,item.pos,32)
        end
    elseif item.direction==4 then --right
        if UnitCollision(item.x+4+item.distance*0.5-item.actW*0.5-1,item.y+3-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            PixelCollision(item.x*8+36,item.y*8+8,item.pos,32)
        end
    end

    -- update gate position
    local mayPass = true
    if item.activated then
        for j,jtem in ipairs(colorT) do
            if item[jtem]==1 and not keys[j] then -- key required but player doesn't have it
                mayPass = false
            end
        end
    end
    if item.activated and mayPass then
        item.pos = item.pos - barrierSpeed
        if item.pos<0 then
            item.pos = 0
        end
    else
        item.pos = item.pos+barrierSpeed
        if item.pos>item.distance*8-boolToNum(item.endStone==1)*16-4 then
            item.pos=item.distance*8-boolToNum(item.endStone==1)*16-4
        end
    end
end

specialCalcT = {}
specialCalcT[8] = CalcPlatform
specialCalcT[9] = CalcBlower
specialCalcT[10] = CalcMagnet
specialCalcT[11] = CalcRotator
specialCalcT[12] = CalcCannon
specialCalcT[13] = CalcRod
specialCalcT[14] = Calc1Way
specialCalcT[15] = CalcBarrier

function InitPlatform(item)
    item.origAmnt = item.amnt
end

function InitCannon(item)
    item.rate = max(1, ceil(convertInterval(item.rate)))
    item.speed = max(1, item.speed - 1)
    item.maxPos = (item.distance-1)*tileSize
    item.ballSpacing = item.speed*item.rate
    if item.direction==1 or item.direction == 2 then
        item.ballX = item.x*8+8
    else
        item.ballY = item.y*8+8
    end
end

function InitRod(item)
    item.speedMin = max(1, floor(convertSpeed(item.speedMin)))
    item.speedMax= max(1, floor(convertSpeed(item.speedMax)))
    item.nextChangeFrame = random(rodsChangeTimeoutMin, rodsChangeTimeoutMax)
    item.d1,item.d2=1,1 -- direction of rods, positive is extending
    item.speed1 = random(item.speedMin,item.speedMax)
    if item.fixdGap==1 then
        item.d2,item.speed2=-item.d1,item.speed1
        item.pos2=item.distance*8-item.pos1-item.gapSize-24
    else
        item.speed2 = random(item.speedMin,item.speedMax)
    end
end

function Init1Way(item)
    if item.direction < 3 then -- up or down
        item.unitCollisionX = item.x+8 - item.actW + boolToNum(item.XtoY == 2)*(item.actW - 4 - wrongWayTriggerSize)
        item.unitCollisionY = item.y+item.distance*0.5+3-item.actH*0.5
    else -- left or right
        item.unitCollisionX = item.x+item.distance*0.5+3-item.actW*0.5
        item.unitCollisionY = item.y+8-(item.XtoY-1)*(4 + wrongWayTriggerSize) - boolToNum(item.XtoY==1)*(item.actH)
    end

    item.closedPos = item.distance*8-boolToNum(item.endStone==1)*16-4
end

function InitBarrier(item)
    item.activated = false
end

--- No Operation, do nothing
local function noOp() end

initSpecial = {}
initSpecial[8]=InitPlatform
initSpecial[9]=noOp
initSpecial[10]=noOp -- magnet
initSpecial[11]=noOp --rotator
initSpecial[12]=InitCannon
initSpecial[13]=InitRod
initSpecial[14]=Init1Way -- 1Way
initSpecial[15]=InitBarrier
