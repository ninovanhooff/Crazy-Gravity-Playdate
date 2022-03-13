---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:29
---

import "util.lua"

local file = playdate.file

function LoadFile(path)
    printf("loading ".. path)

    local levelT = file.run(path)
    brickT = levelT["brickT"]
    specialT = levelT["specialT"]
    levelProps = levelT["levelProps"]
    levelProps.lives = levelProps.lives or 5

    printf("loaded dim",#brickT,#brickT[1])

    levelT = {specialT=specialT, levelProps=levelProps, brickT=brickT}
    return true
end
