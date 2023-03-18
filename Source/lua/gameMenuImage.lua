local setMenuImage <const> = playdate.setMenuImage

local screenWidth <const> = screenWidth
local screenHeight <const> = screenHeight
local ResourceLoader <const> = ResourceLoader
local levelPath <const> = levelPath

local clamp <const> = clamp
local abs <const> = math.abs
local floor <const> = math.floor
local gfx <const> = playdate.graphics
local noFlip <const> = gfx.kImageUnflipped
local sprite <const> = sprite

local oldRoutePattern <const> = {0x82, 0x10, 0x85, 0x20, 0xA, 0x20, 0x88, 0x22, 125, 239, 122, 223, 245, 223, 119, 221}

local function ensureRouteProps(routeProps)
    if routeProps.initialized then
        return 0
    end
    print("initializing routeProps")
    local miniMapImage = ResourceLoader:getImage(levelPath() .. "_miniMap")
    routeProps.levelSizeX, routeProps.levelSizeY = miniMapImage:getSize()
    -- Initially hide miniMap by making it transparent
    miniMapImage:addMask(false) -- does nothing if it already has a mask
    routeProps.miniMapImage = miniMapImage
    routeProps.miniMapMaskImage = miniMapImage:getMaskImage()

    routeProps.routeImage = gfx.image.new(
        routeProps.levelSizeX, routeProps.levelSizeY
    )
    routeProps.routeMaskImage = routeProps.routeImage:getMaskImage()

    routeProps.initialized = true
    return 6
end

local function drawMapBorderCorners(menuImage, mapOffsetX, mapOffsetY, levelW, levelH)
    local markerSize = 8
    gfx.pushContext(menuImage)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    -- top-left
    sprite:draw(
        mapOffsetX, mapOffsetY,
        noFlip,
        0,48,
        markerSize, markerSize
    )
    --top-right
    sprite:draw(
        mapOffsetX + levelW - markerSize, mapOffsetY,
        noFlip,
        markerSize,48,
        markerSize, markerSize
    )
    --bottom-left
    sprite:draw(
        mapOffsetX, mapOffsetY + levelH - markerSize,
        noFlip,
        0,48+markerSize,
        markerSize, markerSize
    )
    print("bottom right", mapOffsetX + levelW - markerSize, mapOffsetY + levelH - markerSize)
    --bottom-right
    sprite:draw(
        mapOffsetX + levelW - markerSize, mapOffsetY + levelH - markerSize,
        noFlip,
        markerSize,48+markerSize,
        markerSize, markerSize
    )
    gfx.popContext() -- menuImage
end


function RenderRoute()
    printT("render route " .. frameCounter)
    local camPos <const> = camPos
    local routeProps <const> = routeProps
    local planePos <const> = planePos

    local renderCost = ensureRouteProps(routeProps)

    -- fog
    gfx.pushContext(routeProps.miniMapMaskImage)
    sprite:draw(
        camPos[1]+2, camPos[2]-2, -- mask is a bit narrower and a bit taller than camera view
        noFlip,
        32, 32,
        44,30
    )
    gfx.popContext()

    -- route
    gfx.pushContext(routeProps.routeImage)
    gfx.setColor(gfx.kColorBlack) -- bugfix: after touching down on checkpoint, gfx color would turn white permanently, across frames, even after pushing context??
    gfx.drawLine(
        routeProps.lastPlaneX, routeProps.lastPlaneY,
        planePos[1], planePos[2]
    )
    gfx.popContext()
    routeProps.lastPlaneX = planePos[1]
    routeProps.lastPlaneY = planePos[2]
    renderCost = renderCost + 4
    return renderCost
end
local renderRoute <const> = RenderRoute


function SetGameMenuImage()
    renderRoute()
    local routeProps <const> = routeProps
    local planePos <const> = planePos
    local miniMapImage <const> = routeProps.miniMapImage
    local levelW, levelH = routeProps.levelSizeX, routeProps.levelSizeY
    local xPos, yPos, srcX, srcY, menuImageOffset = 0,0,0,0,0

    if levelW <= screenWidth then
        xPos = (screenWidth - levelW) / 2
    else
        srcX = planePos[1] - levelW /2
    end

    local camPos <const> = camPos
    if levelW < screenWidth / 2 then
        menuImageOffset = 100
    else
        menuImageOffset = floor(((camPos[1]-1) / (levelW - gameWidthTiles)) * 200)
    end

    if levelH <= screenHeight then
        yPos = screenHeight/2 - levelH /2
    else
        srcY = planePos[2] - levelH /2
        --srcY = (halfHeightTiles - (camPos[2]-1 + halfHeightTiles)) / 2
    end

    print("rawSrc", srcX, srcY)

    srcX = floor(clamp(srcX, 0, abs(screenWidth - levelW)))
    srcY = floor(clamp(srcY, 0, abs(screenHeight - levelH)))
    xPos = floor(xPos)
    yPos = floor(yPos)
    local mapOffsetX = xPos-srcX
    local mapOffsetY = yPos-srcY

    print("src", srcX, srcY, levelW, levelH, "pos", xPos, yPos, menuImageOffset)
    -- create menuImage with map background and masked miniMap
    local menuImage = gfx.image.new(screenWidth, screenHeight, gfx.kColorBlack)
    -- map background
    gfx.pushContext(menuImage)
    gfx.setPattern({0x80, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0})
    gfx.fillRect(mapOffsetX,mapOffsetY,levelW,levelH)

    -- miniMap
    miniMapImage:draw(xPos, yPos, noFlip, srcX, srcY, levelW, levelH)

    -- route
    routeProps.routeImage:draw(xPos, yPos, noFlip, srcX, srcY, screenWidth, screenHeight)

    local markerSize = 16 -- actually 15, but don't want half pixel coordinates

    -- plane border marker
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    local markerX = mapOffsetX + planePos[1] - markerSize/2 + 1
    local markerY = mapOffsetY + planePos[2] - markerSize/2 + 1
    sprite:draw(
        markerX, markerY,
        noFlip,
        0,32,
        markerSize, markerSize
    )
    -- plane
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    sprite:draw(
        markerX + 4,
        markerY + 4,
        noFlip,
        16,32,
        7,7
    )
    gfx.popContext() -- croppedImage

    drawMapBorderCorners(menuImage, mapOffsetX, mapOffsetY, levelW, levelH)

    setMenuImage(
        menuImage,
        menuImageOffset
    )

    -- blur previous route
    gfx.pushContext(routeProps.routeMaskImage)
    gfx.setPattern(oldRoutePattern)
    gfx.fillRect(0,0,levelW, levelH)
    gfx.popContext()-- routeMaskImage
end
