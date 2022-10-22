---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/04/2022 12:50
---

import "CamController"
import "game-over/GameOverScreen"
import "game-explosion/GameExplosionScreen"

local pi <const> = pi
local abs <const> = math.abs
local floor <const> = math.floor
local max <const> = math.max
local sin <const> = math.sin
local cos <const> = math.cos

local tileSize <const> = tileSize
local gameWidthTiles <const> = gameWidthTiles
local gameHeightTiles <const> = gameHeightTiles
local halfWidthTiles <const> = math.ceil(gameWidthTiles*0.5)
local halfHeightTiles <const> = math.ceil(gameHeightTiles*0.5)
local gameWidthPixels <const> = screenWidth
local gameHeightPixels <const> = gameHeightTiles * tileSize
local halfGameWidthPixels <const> = gameWidthPixels * 0.5
local halfGameHeightPixels <const> = gameHeightTiles * tileSize * 0.5
local planePos <const> = planePos
local camPos <const> = camPos
local camControllerX, camControllerY
local planeSpeedXCamMultiplier <const> = 0.05
local planeSpeedYCamMultiplier <const> = 0.03
local planeRotationCamMultiplier <const> = 0.05
local gameHUD <const> = gameHUD

CollisionReason = enum({"OverSpeed", "Other"})

--- sine component (y-direction) of plane orientation, ie. positive if plane is pointing up, 0 if pointing left and negative when pointing down
local camRotY <const> = {}
for i = 0,23 do
    camRotY[i] = sin(i/12*pi)
end

--- cosine component (x-direction) of plane orientation, ie. positive if plane is pointing right, 0 if pointing up and negative when pointing left
local camRotX <const> = {}
for i = 0,23 do
    camRotX[i] = cos(i/12*pi)
end

local sinColT= {}
for i = 0,23 do
    sinColT[i] = {
        sin(i/12*pi)*10+11, -- tip x
        sin((i/12+0.75)*pi)*12+11, -- right base x
        sin((i/12-0.75)*pi)*12+11 -- left base x
    }
end

local cosColT= {}
for i = 0,23 do
    cosColT[i] = {
        cos(i/12*pi)*10+11, -- tip y
        cos((i/12+0.75)*pi)*12+11, -- right base y
        cos((i/12-0.75)*pi)*12+11 -- left base y
    }
end

local function CalcPlaneColCoords()
    colT = {}
    local colT = colT
    -- sin collision table for current rotation
    local sinColTR = sinColT[planeRot]
    local cosColTR = cosColT[planeRot]
    colT[1] = cosColTR[1]+planePos[3] -- tip x
    colT[2] = sinColTR[1]+planePos[4] -- tip y
    colT[3] = cosColTR[2]+planePos[3] -- right base x
    colT[4] = sinColTR[2]+planePos[4] -- right base y
    colT[5] = cosColTR[3]+planePos[3] -- left base x
    colT[6] = sinColTR[3]+planePos[4] -- left base y
    colT[7] = (colT[5]+colT[1])*0.5
    colT[8] = (colT[6]+colT[2])*0.5
    colT[9] = (colT[3]+colT[1])*0.5
    colT[10] = (colT[4]+colT[2])*0.5
    colBT = nil
    colBT = {}
    for i=1,5,2 do -- for every pair of coordinates in colT
        colBT[i]=max(planePos[1]+floor(colT[i]*0.125),1.0)
        colBT[i+1]=max(planePos[2]+floor(colT[i+1]*0.125),1.0)
    end
end

local function CalcGameCam()
    local cam <const> = camPos
    local plane <const> = planePos
    local planeX <const> = plane[1] * tileSize + plane[3] + 12 -- offset for plane center position
    local planeY <const> = plane[2] * tileSize + plane[4] + 12 -- offset for plane center position
    local camBeforeX <const> = cam[1] * tileSize + cam[3]
    local camBeforeY <const> = cam[2] * tileSize + cam[4]
    local camAfterX, camAfterY

    -- horizontal cam position
    -- target value for camera is to center the plane on screen, so top-left of camera is plane pos - half screen width in pixels
    -- we offset the target in the direction the plane tip is pointing at
    local targetX = planeX-halfGameWidthPixels
        + (camRotX[planeRot] * gameWidthPixels * planeRotationCamMultiplier)
        + (vx * gameWidthPixels * planeSpeedXCamMultiplier)
    camAfterX = camControllerX:update(camBeforeX, targetX)

    -- horizontal clamping
    camAfterX = clamp(camAfterX, tileSize, (levelProps.sizeX- gameWidthTiles + 1) * tileSize)
    cam[1] = floor(camAfterX / tileSize)
    cam[3] = camAfterX % tileSize

    -- vertical cam position
    -- target value for camera is to center the plane on screen, so top-left of camera is plane pos - half screen width in pixels
    -- we offset the target in the direction the plane tip is pointing at

    local targetY = planeY-halfGameHeightPixels
        + (camRotY[planeRot] * gameHeightPixels * planeRotationCamMultiplier)
        + (vy * gameHeightPixels * planeSpeedYCamMultiplier)
    camAfterY = camControllerY:update(camBeforeY, targetY)

    -- vertical clamping
    camAfterY = clamp(camAfterY, tileSize, (levelProps.sizeY- gameHeightTiles + 1) * tileSize)
    cam[2] = floor(camAfterY / tileSize)
    cam[4] = camAfterY % tileSize

    if Debug then
        dX = camAfterX - camBeforeX
        dY = camAfterY - camBeforeY
        TargetX, TargetY = targetX - camAfterX, targetY - camAfterY
        --print("camBefore",camBeforeX, camBeforeY, "dxdy", dX, camAfterY - camBeforeY, "TargetX", TargetX, "TargetY", TargetY)
    end
end

local function calcPlane()
    vx = vx*drag -- thrust?
    vy = (vy+gravity)*drag
    planePos[3] = planePos[3] + vx
    planePos[4] = planePos[4] + vy
    if planePos[3]>7 then
        local addUnits = floor(planePos[3]*0.125)
        planePos[1] = planePos[1]+addUnits
        planePos[3] = planePos[3]-addUnits*8
    elseif planePos[3]<0 then
        --printf("before",planePos[1],planePos[3])
        local substUnits = -floor(planePos[3]*0.125)
        planePos[1] = planePos[1]-substUnits
        planePos[3] = 8+(planePos[3]+(substUnits-1)*8)
        --printf("after",planePos[1],planePos[3])
    end
    if planePos[4]>7 then
        local addUnits = floor(planePos[4]*0.125)
        planePos[2] = planePos[2]+addUnits
        planePos[4] = planePos[4]-addUnits*8
    elseif planePos[4]<0 then
        local substUnits = -floor(planePos[4]*0.125)
        planePos[2] = planePos[2]-substUnits
        planePos[4] = 8+(planePos[4]+(substUnits-1)*8)
    end

    if planePos[1]<1 then -- level edges
        planePos[1],planePos[3]=1,1
        vx = 0
    end
    if planePos[1]>levelProps.sizeX-3 then -- level edges
        planePos[1],planePos[3]=levelProps.sizeX-2,0 -- fine-tune
        vx = 0
    end
    if planePos[2]<1 then -- level edges
        planePos[2],planePos[4]=1,1
        vy = 0
    end
    if planePos[2]>levelProps.sizeY-3 then -- level edges
        planePos[2],planePos[4]=levelProps.sizeY-3,7
        vy = 0
    end
end

function CalcTimeStep()
    frameCounter = frameCounter + 1
    if flying then --physics
        landedAt = -1
        calcPlane()
    end

    CalcGameCam()
    --printf("plane".." "..planePos[1].." "..planePos[2].." "..planePos[3].." "..planePos[4].." "..vx.." "..vy)

    -- brick collision
    collision = false
    CalcPlaneColCoords()
    for i=1,5,2 do
        if brickT[colBT[i]][colBT[i+1]][1]>1 then
            --print("collision",i,colBT[i],colBT[i+1])
            collision = true
        end
    end

    local screenCenterX = camPos[1] + halfWidthTiles
    local screenCenterY = camPos[2] + halfHeightTiles
    for i,item in ipairs(specialT) do
        -- only calculate when item max half a screen out of view
        if abs(item.x - screenCenterX) <= gameWidthTiles + item.w  and abs(item.y - screenCenterY) <= gameHeightTiles + item.h then
            specialCalcT[item.sType](item,i)
        end
    end
    if collision and explosion == nil and not Debug then
        print("KABOOM", extras[2])
        pushScreen(GameExplosionScreen(calcPlane, CalcGameCam))
    end
end



function ResetPlane()
    explosion = nil
    planePos[1], planePos[2], planePos[3], planePos[4] = checkpoint.x+floor(checkpoint.w*0.5-1)-1,checkpoint.y+1,4,4 --x,y,subx,suby
    -- when using y = checkpoint.y-halfHeightTiles+1, no initial camera movement would occur
    camPos[1], camPos[2], camPos[3], camPos[4] = checkpoint.x+floor(checkpoint.w*0.5)-halfWidthTiles,checkpoint.y-halfHeightTiles, 0,0 --x,y,subx,suby
    vx,vy,planeRot,thrust = 0,0,18,0 -- thrust only 0 or 1; use thrustPower to adjust.
    camControllerX = CamController(12, 12 * 25)
    camControllerY = CamController(12, 12 * 17)
    CalcGameCam()
    flying = false
    CalcPlaneColCoords()
    collision = false
    fuel = levelProps.fuel
    landedTimer,landedAt = 0,-1
end

local function initSpecials()
    fuelEnabled = false
    for i,item in ipairs(specialT) do
        if item.sType == 8 then --platform
            if item.pType == 1 then -- home
                homeBase = item
            elseif item.pType == 3 then -- fuel
                fuelEnabled = true
            end
        end
        initSpecial[item.sType](item)
    end
end

function InitGame(_pathOrLevelNumber, selectedChallenge)
    if type(_pathOrLevelNumber) == "string" then
        path = _pathOrLevelNumber
    elseif type(_pathOrLevelNumber) == "number" then
        currentLevel = _pathOrLevelNumber
        path = levelPath()
    end
    print("InitGame", path)
    LoadFile(path)
    curGamePath = path
    gameHUD.selectedChallenge = selectedChallenge
    gameHUD.challengeTarget = getChallengesForPath(path)[selectedChallenge]
    sample("init specials", function()  initSpecials()end, 1)
    if not homeBase then
        error("lvl has no base")
    end
    frameCounter = 0
    numGameOvers = 0
    ResetGame()
    musicManager:play(levelSongPath())
end

function ResetGame()
    checkpoint = homeBase
    ResetPlane()
    fuelSpent, livesLost = 0,0
    planeFreight = {} -- type, idx of special where picked up
    deliveredFreight = {0,0,0,0} -- amount for each type
    remainingFreight = {0,0,0,0} -- amnt for each type
    keys = {false,false,false,false} -- have? bool
    for i,item in ipairs(specialT) do
        if item.sType == 8 then --platform
            item.amnt = item.origAmnt
            item.tooltip = nil
            if item.pType == 2 then -- freight
                remainingFreight[item.type+1] = remainingFreight[item.type+1]+item.amnt
            end
        end
    end
    extras = {0,levelProps.lives,1} -- turbo, lives, cargo
    frameCounter = 0
    gamePaused = true
    editorMode = false
    sample("init BricksView", function()
        bricksView = BricksView()
    end, 1)
end

function DecreaseLife()
    livesLost = livesLost + 1
    if extras[2]==1 then
        numGameOvers = numGameOvers + 1
        local config = (numGameOvers < 2 and
            GAME_OVER_CONFIGS.GAME_OVER_NO_SKIP or
            GAME_OVER_CONFIGS.GAME_OVER_MAY_SKIP
        )
        pushScreen(GameOverScreen(config))
    else
        extras[2] = extras[2]-1 -- decrease life
        gameHUD:onChanged(2) -- update life counter in HUD
        if checkpoint == homeBase then -- lose cargo when respawning at homeBase
            for i,item in ipairs(planeFreight) do
                specialT[item[2]].amnt = specialT[item[2]].amnt+1 -- replace freight on pltfrms
                remainingFreight[item[1]+1] = remainingFreight[item[1]+1] + 1
            end
            planeFreight = {}
        end
        ResetPlane()
    end
end
