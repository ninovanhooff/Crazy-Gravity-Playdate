local setMenuImage <const> = playdate.setMenuImage

local screenWidth <const> = screenWidth
local screenHeight <const> = screenHeight
local ResourceLoader <const> = ResourceLoader
local cropImage <const> = cropImage

local clamp <const> = clamp

local abs <const> = math.abs
local floor <const> = math.floor
local gfx <const> = playdate.graphics
local noFlip <const> = gfx.kImageUnflipped


return function()
    local planePos <const> = planePos
    local minimapImage = ResourceLoader:getImage(levelPath() .. "_minimap")
    local srcW, srcH = minimapImage:getSize()
    local xPos, yPos, srcX, srcY, menuImageOffset = 0,0,0,0,0

    if srcW <= screenWidth then
        xPos = (screenWidth - srcW) / 2
    else
        srcX = planePos[1] - srcW/2
    end

    if srcW < screenWidth / 2 then
        menuImageOffset = 100
    else
        menuImageOffset = floor((planePos[1] / srcW) * 200)
    end

    if srcH <= screenHeight then
        yPos = screenHeight/2 - srcH/2
    else
        srcY = planePos[2] - srcH/2
        --srcY = (halfHeightTiles - (camPos[2]-1 + halfHeightTiles)) / 2
    end

    print("rawSrc", srcX, srcY)

    srcX = clamp(srcX, 0, abs(screenWidth - srcW))
    srcY = clamp(srcY, 0, abs(screenHeight - srcH))

    print("src", srcX, srcY, srcW, srcH, "pos", xPos, yPos, menuImageOffset)

    local croppedImage = cropImage(
        minimapImage,
        400, 240,
        srcX, srcY,
        xPos, yPos
    )

    gfx.pushContext(croppedImage)
    gfx.setColor(gfx.kColorXOR)
    local markerSize = 16
    --gfx.drawRect(
    --    xPos-srcX + planePos[1] - markerSize/2,
    --    yPos-srcY + planePos[2] - markerSize/2,
    --    markerSize, markerSize
    --)
    -- plane
    sprite:draw(
        xPos-srcX + planePos[1] - markerSize/2,
        yPos-srcY + planePos[2] - markerSize/2,
        noFlip,
        112,0,-- todo create marker sprite (both classic and playdate) and fill spriteX,Y here
        markerSize, markerSize
    )
    gfx.popContext()

    setMenuImage(
        croppedImage,
        menuImageOffset
    )
end
