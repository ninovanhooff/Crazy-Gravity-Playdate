---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:29
---

import "util.lua"

local file <const> = playdate.file
local unpack <const> = string.unpack


function LoadFile(path)
    printf("loading ".. path)

    levelT, brickT, specialT, levelProps = nil, nil, nil
    sample("GC", function() collectgarbage("collect")end, 1)

    local levelT
    sample("pdz load", function() levelT = file.run(path) end, 1)
    levelProps = levelT["levelProps"]
    levelProps.lives = levelProps.lives or 5
    specialT = levelT["specialT"]
    brickT = {}
    local format = levelProps.packFormat
    local packSize = string.packsize(format)
    local packSizeOffset = packSize-1

    local unpackMeta = {
        __index = function(tbl, idx)
            -- tbl["compressed"] contains the packed string.
            -- idx*5-4: each tile entry is 5 bytes long,
            -- for idx 1 we should start reading at pos 1. So, 1*packSize-packSizeOffset = 1
            return {unpack(format, tbl["compressed"], idx*packSize-packSizeOffset)}
        end
    }

    local brickFile = file.open(path..".bin")
    for x = 1, levelProps.sizeX do
        brickT[x]= setmetatable({compressed = brickFile:read(5*levelProps.sizeY)}, unpackMeta)
    end


    printf("loaded dim",#brickT,#brickT[1])
    printf("loaded #specials:", #specialT)

    return true
end

function levelNumString(levelNumber)
    return string.format("%02d", levelNumber)
end

function levelPath(_levelNumber)
    local levelNumber = _levelNumber or currentLevel
    return "levels/LEVEL" .. levelNumString(levelNumber)
end

levelNames = {
    [1] = "Test Flight",
    [2] = "Getaway-Gates",
    [3] = "Rod-a-bout",
    [4] = "Luxury Raceway",
    [5] = "Hide+See-key",
    [6] = "Turbo boost!",
    [7] = "Grab grab+go!",
    [8] = "Meditative Test",
    [9] = "Criss Crossing",
    [10] = "Mind the curve",
    [11] = "Before the storm",
    [12] = "Push+Pull",
    [13] = "Fuel Shortage",
    [14] = "Lone Station",
    [15] = "Tight Squeeze",
    [16] = "Caution Cannon",
    [17] = "Cannonballers",
    [18] = "Team Push+Pull",
    [19] = "A-maze-ing",
    [20] = "Broadsides",
    [21] = "Final Countdown"
}

local levelBgmPaths = {
    "music/E1M8.mp3",
    "music/E3M6.mp3",
    "music/E1M9.mp3",
    "music/scifiNights.mp3",
}

function levelSongPath(_levelNumber)
    local levelNumber = _levelNumber or currentLevel
    if levelNumber == 21 then
        return "music/the-countdown.mp3"
    end
    print("music for level ", levelNumber, #levelBgmPaths, luaMod(levelNumber,#levelBgmPaths+1))
    return levelBgmPaths[luaMod(levelNumber,#levelBgmPaths+1)]
end
