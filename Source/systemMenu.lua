---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 01/04/2022 18:12
---

local menu <const> = playdate.getSystemMenu()
local gfx <const> = playdate.graphics

local function onFrameRateChange(newFramerate)
    printf("Changing framerate to ", newFramerate)
    frameRate = tonumber(newFramerate)
    playdate.display.setRefreshRate(frameRate)
end

local function onLevelChange(newLevelNumber)
    currentLevel = tonumber(newLevelNumber)
    InitGame("levels/LEVEL".. newLevelNumber .. ".pdz")
end

local function onDebugChange(newDebugValue)
    Debug = newDebugValue
end

menu:addOptionsMenuItem("fps", {"0","20","30"}, "30", onFrameRateChange)
menu:addOptionsMenuItem("level", {"01","02","03","04","05","06","07","08", "09", "10"}, "03", onLevelChange)
menu:addCheckmarkMenuItem("debug", Debug, onDebugChange)
