local gfx <const> = playdate.graphics
local noFlip <const> = gfx.kImageUnflipped
local flipX <const> = gfx.kImageFlippedX

local miniMapEmptyColor = gfx.kColorWhite
local miniMapBricksColor = gfx.kColorBlack
local writeToFile <const> = playdate.simulator.writeToFile
local sourcePath = "/Users/ninovanhooff/PlaydateProjects/CrazyGravityPlaydate/Source/"

local function drawMiniSpecials()
    for _,item in ipairs(specialT) do
        if item.sType == 8 and item.arrows == 1 then -- platform with arrows
            -- draw arrows
            sprite:draw(item.x-2,item.y-3,noFlip, 16, 48, 6, 8)
            sprite:draw(item.x+item.w-6,item.y-3,flipX, 16, 48, 6, 8)
        end
    end
end

local function writeMiniMap(levelNum)
    LoadFile(levelPath(levelNum))
    -- save miniMap
    local miniMapImage = gfx.image.new(levelProps.sizeX,levelProps.sizeY, miniMapEmptyColor)
    print(brickT)
    print(brickT[1][1])

    gfx.pushContext(miniMapImage)
        gfx.setColor(miniMapBricksColor)
        for i = 1, levelProps.sizeX do
            local curCol = brickT[i]
            for j = 1, levelProps.sizeY do
                if curCol[j][1] > 2 then
                    gfx.drawPixel(i-1,j-1)
                end
            end
        end
        drawMiniSpecials()
    gfx.popContext()

    local miniMapPath = sourcePath .. levelPath(levelNum) .. "_miniMap.png"
    printT("writing " .. miniMapPath)
    writeToFile(miniMapImage, miniMapPath)
end

function writeAllMiniMaps()
    require "lua/gameScreen"

    for i = 17,numLevels do
        writeMiniMap(i)
    end
end
