---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/04/2022 12:50
---

import "gameExplosion.lua"
import "gameHUD.lua"
import "game-over/GameOverScreen.lua"

local floor <const> = math.floor
local max <const> = math.max

local planePos <const> = planePos
local camPos <const> = camPos
local gameHUD <const> = gameHUD


local halfWidthTiles = math.ceil(gameWidthTiles*0.5)
local halfHeightTiles = math.ceil(gameHeightTiles*0.5)

local sinColT= {}
for i = 0,23 do
    sinColT[i] = {
        math.sin(i/12*pi)*10+11,
        math.sin((i/12+0.75)*pi)*12+11,
        math.sin((i/12-0.75)*pi)*12+11
    }
end

local cosColT= {}
for i = 0,23 do
    cosColT[i] = {
        math.cos(i/12*pi)*10+11,
        math.cos((i/12+0.75)*pi)*12+11,
        math.cos((i/12-0.75)*pi)*12+11
    }
end

local function CalcPlaneColCoords()
    colT = nil
    colT = {}
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
    --printf("camBefore",camPos[1].." "..camPos[2].." "..camPos[3].." "..camPos[4])

    -- horizontal cam position
    if planePos[1]>camPos[1]+halfWidthTiles then
        camPos[3] = camPos[3] + planePos[1]-(camPos[1]+halfWidthTiles)
    elseif planePos[1]<camPos[1]+halfWidthTiles then
        camPos[3] = camPos[3] - (camPos[1]+halfWidthTiles-planePos[1])
    end
    if camPos[3]>tileSize-1 then
        local addUnits = floor(camPos[3]/tileSize)
        camPos[1] = camPos[1]+addUnits
        camPos[3] = camPos[3]-addUnits*8
    elseif camPos[3]<0 then
        --printf("before",planePos[1],planePos[3])
        local substUnits = -floor(camPos[3]/tileSize)
        camPos[1] = camPos[1]-substUnits
        camPos[3] = tileSize+(camPos[3]+(substUnits-1)*tileSize)
        --printf("after",planePos[1],planePos[3])
    end
    if camPos[1]<1 then
        camPos[1],camPos[3]=1,0
    elseif camPos[1]+gameWidthTiles >=levelProps.sizeX then
        camPos[1],camPos[3] = levelProps.sizeX- gameWidthTiles,0
    end

    -- vertical cam position
    if planePos[2]>camPos[2]+halfHeightTiles then
        camPos[4] = camPos[4] + planePos[2]-(camPos[2]+halfHeightTiles)
    elseif planePos[2]<camPos[2]+halfHeightTiles then
        camPos[4] = camPos[4] - (camPos[2]+halfHeightTiles - planePos[2])
    end
    if camPos[4]>7 then
        local addUnits = floor(camPos[4]/tileSize)
        camPos[2] = camPos[2]+addUnits
        camPos[4] = camPos[4]-addUnits*tileSize
    elseif camPos[4]<0 then
        --printf("before",planePos[1],planePos[3])
        local substUnits = -floor(camPos[4]/tileSize)
        camPos[2] = camPos[2]-substUnits
        camPos[4] = tileSize+(camPos[4]+(substUnits-1)*tileSize)
        --printf("after",planePos[1],planePos[3])
    end
    local offScreenTileY = gameHeightTiles+1
    if camPos[2]<1 then
        camPos[2],camPos[4]=1,0
    elseif camPos[2]+offScreenTileY>levelProps.sizeY or (camPos[2]+offScreenTileY==levelProps.sizeY and camPos[4]>0) then
        camPos[2],camPos[4] = levelProps.sizeY-offScreenTileY,0
    end
    --printf("camAfter",camPos[1].." "..camPos[2].." "..camPos[3].." "..camPos[4])
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

    for i,item in ipairs(specialT) do
        specialCalcT[item.sType](item,i)
    end
    if collision and explosion == nil and not Debug then
        if Sounds then thrust_sound:stop() end
        thrust = 0
        local scrimHeight = hudY
        if extras[2]==1 then
            scrimHeight = screenHeight
        end
        explosion = GameExplosion(scrimHeight) -- disable fade-out on last life lost
        print("KABOOM", extras[2])
        while explosion:update() do
            calcPlane() -- keep updating plane as a ghost target for camera
            CalcGameCam()
            RenderGame()
            playdate.drawFPS(0,0)
            coroutine.yield() -- let system update the screen
        end
        DecreaseLife()
    end
end

local function checkCam()
    if camPos[1]>levelProps.sizeX- gameWidthTiles then
        camPos[1] = levelProps.sizeX- gameWidthTiles
    end
    if camPos[2]>levelProps.sizeY-31 then
        camPos[2] = levelProps.sizeY-31
    end

    if camPos[1]<1 then camPos[1]=1 end
    if camPos[2]<1 then camPos[2]=1 end
end

function ResetPlane()
    explosion = nil
    planePos[1], planePos[2], planePos[3], planePos[4] = homeBase.x+floor(homeBase.w*0.5-1),homeBase.y+1,0,4 --x,y,subx,suby
    -- when using y = homeBase.y-halfHeightTiles+1, no initial camera movement would occur
    camPos[1], camPos[2], camPos[3], camPos[4] = homeBase.x+floor(homeBase.w*0.5)-halfWidthTiles,homeBase.y-halfHeightTiles, 0,0 --x,y,subx,suby
    checkCam()
    flying = false
    vx,vy,planeRot,thrust = 0,0,18,0 -- thrust only 0 or 1; use thrustPower to adjust.
    CalcPlaneColCoords()
    collision = false
    fuel = levelProps.fuel
    landedTimer,landedAt = 0,-1
end

function InitGame(path)
    LoadFile(path)
    curGamePath = path
    for i,item in ipairs(specialT) do
        if item.sType == 8 then --platform
            if item.pType == 1 then -- home
                homeBase = item
            end
        end
        initSpecial[item.sType](item)
    end
    if not homeBase then
        error("lvl has no base")
    end
    ResetGame()
end

function ResetGame()
    ResetPlane()
    fuelSpent, livesLost = 0,0
    planeFreight = {} -- type, idx of special where picked up
    deliveredFreight = {0,0,0,0} -- amount for each type
    remainingFreight = {0,0,0,0} -- amnt for each type
    keys = {false,false,false,false} -- have? bool
    for i,item in ipairs(specialT) do
        if item.sType == 8 then --platform
            item.amnt = item.origAmnt
            if item.pType == 2 then -- freight
                remainingFreight[item.type+1] = remainingFreight[item.type+1]+item.amnt
            end
        elseif item.sType == 12 then -- cannon
            item.balls = {}
        end
    end
    ApplyGameSets()
    extras = {0,levelProps.lives,1} -- turbo, lives, cargo
    -- time to beat
    if records[curGamePath] then
        lSec = records[curGamePath][1]
    else
        lSec = 5940 -- 99'00
    end
    lMin = floor(lSec/60)
    lSec = floor(lSec%60)
    if lMin<10 then lMin = "0"..lMin end
    if lSec<10 then lSec = "0"..lSec end
    frameCounter = -60
    for i=1,60 do
        CalcTimeStep() -- let cannons fire a few shots, bringing counter to 0
    end
    editorMode = false
    bricksView = BricksView()
end

function DecreaseLife()
    livesLost = livesLost + 1
    if extras[2]==1 then
        pushScreen(GameOverScreen())
    else
        extras[2] = extras[2]-1
        gameHUD:onChanged(2)
        for i,item in ipairs(planeFreight) do
            specialT[item[2]].amnt = specialT[item[2]].amnt+1 -- replace freight on pltfrms
            remainingFreight[item[1]+1] = remainingFreight[item[1]+1] + 1
        end
        planeFreight = {}
        ResetPlane()
    end
end
