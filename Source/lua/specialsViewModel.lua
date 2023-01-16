---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 03/04/2022 16:59
---
import "game-over/GameOverScreen"
require "lua/tutorial/TakeOffLandingScreen"

local animator <const> = playdate.graphics.animator
local checkpointEasing <const> = playdate.easingFunctions.outBack
local checkpointAnimatorDuration <const> = 800

local abs <const> = math.abs
local ceil <const> = math.ceil
local floor <const> = math.floor
local min <const> = math.min
local max <const> = math.max
local random <const> = math.random
local pickRandom <const> = pickRandom
local options <const> = GetOptions()
local soundManager <const> = soundManager
local gameHUD <const> = gameHUD
local tileSize <const> = tileSize
local planePos <const> = planePos
local clamp <const> = clamp
local inputManager <const> = inputManager
local keyGlyphT <const> = {"●", "▲", "◆", "■"}

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
local function approxRectCollision(x, y, w, h)
    -- plane size is 3
    return planePos[1]+3 > x and planePos[1] < x+w  and planePos[2]+3 > y and planePos[2] <y+h
end

local function pixelCollision(x, y, w, h) -- needs work?
    local leftX = planePos[1]*8
    local topY = planePos[2]*8
    local colT <const> = colT
    for i=1,9,2 do
        if leftX+colT[i]>x and leftX+colT[i]<=x+w and topY+colT[i+1]>=y and topY+colT[i+1]<=y+h then -- -1
            collision = true
            return true
        end
    end
    return false
end

local function getPlatformTooltipTexts(platform)
    if platform.pType == 2 then
        local doneText =
            levelProps.numBases == 1 and "Got it, back to base!"
        or
            "Got it, onwards!"
        return {pickup= "Loading Cargo", planeFull="Cargo hold full!", done=doneText}
    elseif platform.pType == 3 then
        return {pickup= "Refueling", planeFull="All filled up!", done="See ya!"}
    elseif platform.pType == 4 then
        if platform.type == 1 then
            return {pickup= "+1 Turbo", done="Go fast!"}
        elseif platform.type == 2 then
            return {pickup= "+1 Life", done="Take care!"}
        elseif platform.type == 3 then
            return {pickup= "+1 Cargo hold", done="Spacious!"}
        else
            error("unexpected extras type " .. platform.type)
        end
    elseif platform.pType == 5 then
        return {pickup= "Analyzing key", done="Open sesame!"}
    else
        error("unexpected platform type " .. platform.pType)
    end
end

local function updateCheckpoint(platform, suppressCheckpointSound)
    if platform ~= checkpoint then
        checkpoint = platform
        checkpoint.animator = animator.new(checkpointAnimatorDuration, 32, -56, checkpointEasing)

        if Sounds and not suppressCheckpointSound then
            pickup_sound:play()
        end
    end
end

function ApproxSpecialCollision(item)
    return approxRectCollision(item.x, item.y, item.w, item.h)
end

local checkpointWaitingLabels <const> = {
    "Back so soon?", "Back again?", "Papers, please", "You look familiar", "Synthesizing Gravity",
    "Sit...", "Gimme five!", "Take five!", "Planet Express?", "Lunch order?", "I wanted to say...",
    "Delivery for ME?", "Pizza? I didn't order...", "What are you doing here?",
    "Reticulating splines...", "Max confusion!", "Pit stop?", "Brake engaged",
    "Hold yer horses!", "3,2,1...", "Tired?", "Freeze!", "What now?", "Thrusters deactivated",
    "Tag!", "Out of ammo?", "Chill pill?", "Thirsty?", "Bedtime?", "Timeout!", "Lowest prices!",
    "Don't stop believin'", "Fixing your cape?", "No smile?", "Put me in, coach!",
    "Stop! In the Name of Love", "Gimme now!"
}
local checkpointDoneLabels  <const> = {
    "Let's go!", "Safe and sound!", "Keep going!", "Nice!", "See ya!", "You can do it!",
    "Good boy!", "And away you go!", "I'm having Turkey", "No hug?", "How nice!",
    "With chilli, yummy!", "Is that you, Fry?", "Where is Bender?", "Time to go!", "All good!",
    "Seatbelts on!", "Giddy up!", "Let's jam!", "You've got this!", "Unfreeze!", "Back to work!",
    "Scram!", "Gotta jet!", "You're it!", "Locked and loaded!", "Stay calm!", "Refreshed!",
    "One more run!", "Start the clock!", "...are just the beginning", "Hold on to that Feelin'",
    "Up, up and away!", "Why so serious?", "Ready to play!", "Think it over!", "Lookin' good!"
}

function CalcPlatform(item)
    if not approxRectCollision(item.x,item.y-3, item.w, item.h) then
        item.tooltip = nil
        return -- out of range
    end

    --platform collision
    local landingTolerance <const> = landingTolerance
    local rotationWithinLandingTolerance <const> = abs(planeRot - 18) <= landingTolerance.rotation
    local overSpeed = vy > landingTolerance.vY or abs(vx) > landingTolerance.vX
    if not collision and pixelCollision(item.x*8,item.y*8+32,item.w*8,16) then
        if overSpeed then
            collision = CollisionReason.OverSpeed
        elseif not rotationWithinLandingTolerance then
            collision = CollisionReason.Rotation
        else
            collision = false
        end
    end
    -- don't collide on take-off
    if not collision and abs(planeRot - 18) <= 3 and vy<0  then
        collision = false
    end

    if landedAt ~= item then
        if planeRot ~= 18 and vy > 0 and item ~= prevLandedAt and not options:getSelfRightTipShown() and approxRectCollision(item.x,item.y, item.w, item.h) then
            pushScreen(TakeOffLandingScreen())
        end
        item.tooltip = nil
    else
        landedTimer = landedTimer + 1
    end

    if flying and rotationWithinLandingTolerance then -- upright
        --landing
        if planePos[2]==item.y+1 and planePos[1]>=item.x-2 and planePos[1]<item.x+item.w-1 and planePos[4]>=3 and vy > 0 and not overSpeed then
            local warnX = 1/(landingTolerance.vX / abs(vx))
            local warnY = 1/(landingTolerance.vY / vy)
            local landingVolume = soundManager.volume * max(warnX, warnY)
            if Sounds then landing_sound:playAt(0, landingVolume) end
            planeRot = 18
            flying = false
            collision = false
            vx,vy=0,0
            planePos[4]=4
            landedTimer = 0
            landedAt = item
        end
    elseif landedAt == item then
        -- landed
        --printf(item.pType,#planeFreight,"HJ")
        local suppressCheckpointSound = false
        local handled = false
        if item.pType==1 then -- homeBase
            if #planeFreight > 0 then
                handled = true
                if landedTimer < frameRate then
                    item.tooltip = {text="Unloading", progress=landedTimer/frameRate}
                else
                    if Sounds then
                        suppressCheckpointSound = true
                        dump_sound:play()
                    end
                    table.remove(planeFreight,1)
                    local remainingCount = table.sum(remainingFreight)
                    if remainingCount==0 and #planeFreight == 0 then
                        printf("VICTORY")
                        updateRecords(currentLevel, {
                            frameCounter / frameRate,
                            fuelSpent,
                            livesLost
                        })
                        item.tooltip = nil
                        RenderGame()
                        playdate.wait(500) -- Show player that there is no more remaining freight
                        pushScreen(GameOverScreen(GAME_OVER_CONFIGS.LEVEL_CLEARED))
                        return
                    else
                        if #planeFreight == 0 then
                            if remainingCount > 0 then
                                item.tooltip = {text=string.format("Goods received, %d remaining!", remainingCount)}
                            end
                        end
                    end
                end
            end
        elseif item.amnt>0 then -- pickup
            local planeIsFull =
            (item.pType==2 and #planeFreight>=extras[3]) or -- freight
            (item.pType==3 and fuel>=6000) -- fuel

            if planeIsFull then
                item.tooltip = {text= getPlatformTooltipTexts(item).planeFull}
            elseif landedTimer < frameRate then
                item.tooltip = { text= getPlatformTooltipTexts(item).pickup, progress=landedTimer/frameRate}
            else
                suppressCheckpointSound = true
                if item.pType==2 then -- freight
                    remainingFreight[item.type+1] = remainingFreight[item.type+1] -1
                    table.insert(planeFreight,{item.type,item})
                    item.amnt = item.amnt -1
                    if Sounds then pickup_sound:play() end
                elseif item.pType==3 then -- fuel
                    fuel = min(6000,fuel+3000)
                    item.amnt = item.amnt -1
                    if Sounds then fuel_sound:play() end
                elseif item.pType==4 then -- extras
                    extras[item.type]=extras[item.type]+1
                    gameHUD:onChanged(item.type)
                    item.amnt = item.amnt -1
                    if Sounds then extra_sounds[item.type]:play() end
                elseif item.pType==5 then -- key
                    keys[item.color]=true
                    item.amnt = item.amnt -1
                    gameHUD:onChanged(4)
                    if Sounds then key_sound:play() end
                end
            end

            if item.amnt == 0 then
                item.tooltip = { text = getPlatformTooltipTexts(item).done }
            end
            handled = true
        end

        if fuel < 1 and
            not collision and
            -- don't offer self destruct when action in progress, such as refuel
            not (item.tooltip and item.tooltip.progress)
        then
            local buttonMappingString = inputManager:mappingString(Input.actionSelfDestruct)
            item.tooltip = { text= "Out of fuel! " .. buttonMappingString .. ": Self-destruct" }
            if inputManager:isInputPressed(Input.actionSelfDestruct) then
                collision = CollisionReason.SelfDestruct
                gamePaused = false
                return true
            end
            handled = true
        end

        if checkpoint ~= item then
            if landedTimer >= frameRate then
                updateCheckpoint(item, suppressCheckpointSound)
                if not handled then
                    item.tooltip = { text= item.checkpointDoneLabel}
                end
            elseif not handled then
                item.tooltip = { text= item.checkpointWaitingLabel, progress=landedTimer/frameRate}
            end
        end

        if landedTimer >= frameRate then
            landedTimer = 0
        end
    end
end

function CalcBlower(item)
    soundManager:addSoundForItem(item)

    if (not flying) or explosion then return end

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
    soundManager:addSoundForItem(item)

    if (not flying) or explosion then return end

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

    soundManager:addSoundForItem(item)

    if (item.direction==1 and UnitCollision(item.x,item.y,5,item.distance,true))
            or (item.direction==2 and UnitCollision(item.x,item.y+8,5,item.distance,true))
            or (item.direction==3 and UnitCollision(item.x,item.y,item.distance,5,true))
            or (item.direction==4 and UnitCollision(item.x+8,item.y,item.distance,5,true)) then
        steeringDisabled = true
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
        end
    end
end

local function planeIntersectsCannon(item)
    if item.direction==1 then -- up
        return approxRectCollision(item.x,item.y,3,item.distance)
    elseif item.direction==2 then -- down
        return approxRectCollision(item.x,item.y+5,3,item.distance)
    elseif item.direction==3 then -- left
        return approxRectCollision(item.x,item.y,item.distance,3)
    else -- right
        return approxRectCollision(item.x+5,item.y,item.distance,3)
    end
end

function CalcCannon(item)

    if not planeIntersectsCannon(item) then return end

    local pos = (frameCounter %  item.rate) * item.speed
    while pos < item.maxPos do
        -- ball collision
        if item.direction==1 then
            pixelCollision(item.ballX,(item.y+item.distance)*8-pos,8,8)--+2
        elseif item.direction==2 then
            pixelCollision(item.ballX,item.y*8+pos+24,8,8)
        elseif item.direction==3 then
            pixelCollision((item.x+item.distance)*8-pos,item.ballY,8,8)
        else
            pixelCollision(item.x*8+24+pos, item.ballY,8,8)
        end
        pos = pos + item.speed*item.rate
    end
end

function CalcRod(item)
    local currentGapTooSmall = item.pos1+item.pos2>item.distance*8-24-item.gapSize
    if currentGapTooSmall then
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
    elseif currentGapTooSmall then
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
        pixelCollision(item.x*8+24,item.y*8+6,item.pos1,12) -- left rod
        pixelCollision(item.x*8+item.distance*8-item.pos2,item.y*8+6,item.pos2,12) -- right rod
    else -- vert
        pixelCollision(item.x*8+6,item.y*8+24,12,item.pos1) -- top
        pixelCollision(item.x*8+6,item.y*8+item.distance*8-item.pos2,12,item.pos2) -- bottom
    end
end

local wrongWayTriggerSize <const> = 12
function Calc1Way(item)
    local oldPos <const> = item.pos
    local activated = false
    local unitCollision = false
    item.showWrongWay = false
    if item.direction==1 then --up
        if UnitCollision(item.unitCollisionX, item.unitCollisionY, item.actW + wrongWayTriggerSize,item.actH,true) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[1] < item.x + 8) or (item.XtoY == 2 and planePos[1] > item.x + 1)
            pixelCollision(item.x*8+32,(item.y+item.distance)*8-4-item.pos,32,item.pos)
        end
    elseif item.direction==2 then --down
        if UnitCollision(item.unitCollisionX, item.unitCollisionY,item.actW + wrongWayTriggerSize,item.actH,true) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[1] < item.x + 8) or (item.XtoY == 2 and planePos[1] > item.x + 1)
            pixelCollision(item.x*8+32,item.y*8+36,32,item.pos)
        end
    elseif item.direction==3 then --left
        if UnitCollision(item.unitCollisionX, item.unitCollisionY,item.actW,item.actH+wrongWayTriggerSize,true) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[2] < item.y + 8) or (item.XtoY == 2 and planePos[2] > item.y + 1)
            pixelCollision((item.x+item.distance)*8-4-item.pos,item.y*8+32,item.pos,32)
        end
    elseif item.direction==4 then --right
        if UnitCollision(
            item.unitCollisionX,
            item.unitCollisionY,
            item.actW,item.actH+wrongWayTriggerSize,true
        ) then
            unitCollision = true
            activated = (item.XtoY == 1 and planePos[2] < item.y + 8) or (item.XtoY == 2 and planePos[2] > item.y + 1)
            pixelCollision(item.x*8+36,item.y*8+32,item.pos,32)
        end
    end
    if collision then
        activated = false
    end
    if activated then
        item.pos = item.pos - barrierSpeed
    else
        item.pos = item.pos+barrierSpeed
    end

    item.pos = clamp(item.pos, 0, item.closedPos)

    if item.pos ~= oldPos then
        soundManager:addSoundForItem(item)
    end

    if unitCollision and not activated and item.pos == item.closedPos then
        item.showWrongWay = true
    end
end

function CalcBarrier(item)
    local oldPos <const> = item.pos
    item.activated = false
    item.tooltip = nil
    -- gate collision
    if item.direction==1 then --up
        if UnitCollision(item.x+3-item.actW*0.5,item.y+item.distance*0.5-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            pixelCollision(item.x*8+8,(item.y+item.distance)*8-4-item.pos,32,item.pos)
        end
    elseif item.direction==2 then --down
        if UnitCollision(item.x+3-item.actW*0.5,item.y+3+item.distance*0.5-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            pixelCollision(item.x*8+8,item.y*8+36,32,item.pos)
        end
    elseif item.direction==3 then --left
        if UnitCollision(item.x+item.distance*0.5-item.actW*0.5,item.y+3-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            pixelCollision((item.x+item.distance)*8-4-item.pos,item.y*8+8,item.pos,32)
        end
    elseif item.direction==4 then --right
        if UnitCollision(item.x+4+item.distance*0.5-item.actW*0.5-1,item.y+3-item.actH*0.5,item.actW,item.actH,true) then
            item.activated = true
            pixelCollision(item.x*8+36,item.y*8+8,item.pos,32)
        end
    end

    -- update gate position
    local missingKeyGlyphs = ""
    if item.activated then
        for j,jtem in ipairs(colorT) do
            if item[jtem]==1 and not keys[j] then -- key required but player doesn't have it
                missingKeyGlyphs = missingKeyGlyphs .. keyGlyphT[j]
            end
        end
    end
    if item.activated and #missingKeyGlyphs == 0 then
        item.pos = item.pos - barrierSpeed
    else
        item.pos = item.pos+barrierSpeed
    end

    item.pos = clamp(item.pos, 0, item.distance*8-boolToNum(item.endStone==1)*16-4)

    if item.pos ~= oldPos then
        soundManager:addSoundForItem(item)
    end

    -- tooltip
    if item.activated and #missingKeyGlyphs > 0 then
        item.tooltip = {
            leftIconIndex = 1,
            text="Missing: " .. missingKeyGlyphs
        }
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
    item.checkpointWaitingLabel = pickRandom(checkpointWaitingLabels)
    item.checkpointDoneLabel = pickRandom(checkpointDoneLabels)
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
    item.closedPos = item.distance*8-boolToNum(item.endStone==1)*16-4
end

--- No Operation, do nothing
local function noOp() end

initSpecial = {}
initSpecial[8]=InitPlatform
initSpecial[9]=noOp -- blower a.k.a. fan
initSpecial[10]=noOp -- magnet
initSpecial[11]=noOp --rotator
initSpecial[12]=InitCannon
initSpecial[13]=InitRod
initSpecial[14]=Init1Way -- 1Way
initSpecial[15]=InitBarrier
