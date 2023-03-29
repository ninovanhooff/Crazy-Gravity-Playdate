local gfx <const> = playdate.graphics
local sprite <const> = sprite
local noFlip <const> = gfx.kImageUnflipped
local flipX <const> = gfx.kImageFlippedX
local flipY <const> = gfx.kImageFlippedY
local floor <const> = math.floor

local miniMapEmptyColor = gfx.kColorWhite
local miniMapBricksColor = gfx.kColorBlack
local writeToFile <const> = playdate.simulator.writeToFile
local sourcePath = "/Users/ninovanhooff/PlaydateProjects/CrazyGravityPlaydate/Source/"

local function renderMiniPlatform(item)
    if item.arrows == 1 then -- platform with arrows
        sprite:draw(item.x-2,item.y-3,noFlip, 16, 48, 6, 8)
        sprite:draw(item.x+item.w-6,item.y-3,flipX, 16, 48, 6, 8)
    end
end

local function renderMini1Way(item)
    if item.direction==1 then -- up
        local flip, xOffset, yOffset
        if item.XtoY == 1 then
            flip = noFlip
            xOffset = -3
        else
            flip = flipX
            xOffset = -3
        end

        if item.endStone == 1 then
            yOffset = floor(item.distance/2) - 7
        else
            yOffset = item.distance/2 - 8
        end
        sprite:draw(item.x + xOffset, item.y + yOffset, flip, 48, 72, 16, 16)
    elseif item.direction==2 then -- down
        local flip, xOffset, yOffset
        if item.XtoY == 1 then
            flip = noFlip
            xOffset = -3
        else
            flip = flipX
            xOffset = -3
        end

        if item.endStone == 1 then
            yOffset = item.distance/2 - 6
        else
            yOffset = item.distance/2 - 5
        end
        sprite:draw(item.x+xOffset, item.y + yOffset, flip, 48, 72, 16, 16)

    elseif item.direction==3 then -- left
        local flip, xOffset, yOffset
        if item.XtoY == 1 then
            flip = flipY
            yOffset = -4
        else
            flip = noFlip
            yOffset = -2
        end

        if item.endStone == 1 then
            xOffset = (item.distance/2) -8
        else
            xOffset = item.distance/2 - 8
        end
        sprite:draw(item.x+xOffset, item.y+yOffset, flip, 32, 72, 16, 16)

    else -- right
        local flip, xOffset, yOffset
        if item.XtoY == 1 then
            flip = flipY
            yOffset = -4
        else
            flip = noFlip
            yOffset = -2
        end

        if item.endStone == 1 then
            xOffset = item.distance/2 - 6
        else
            xOffset = item.distance/2 - 6
        end
        sprite:draw(item.x+xOffset, item.y+yOffset, flip, 32, 72, 16, 16)
    end
end


local miniSpecialRenders = {
    [8] = renderMiniPlatform,
    [14] = renderMini1Way
}

local function renderMiniSpecials()
    for _,item in ipairs(specialT) do
        local drawFun = miniSpecialRenders[item.sType]
        if drawFun then
            drawFun(item)
        end
    end
end

local function writeMiniMap(levelNum)
    LoadFile(levelPath(levelNum))
    -- save miniMap
    local miniMapImage = gfx.image.new(levelProps.sizeX,levelProps.sizeY, miniMapEmptyColor)

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
    renderMiniSpecials()

    gfx.popContext()

    local miniMapPath = sourcePath .. levelPath(levelNum) .. "_miniMap.png"
    printT("writing " .. miniMapPath)
    writeToFile(miniMapImage, miniMapPath)
end

function writeAllMiniMaps()
    require "lua/gameScreen"

    for i = 1, numLevels do
        writeMiniMap(i)
    end
end
