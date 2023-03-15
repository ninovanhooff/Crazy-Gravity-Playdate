local setMenuImage <const> = playdate.setMenuImage

local screenWidth <const> = screenWidth
local screenHeight <const> = screenHeight
local ResourceLoader <const> = ResourceLoader
local levelPath <const> = levelPath
local cropImage <const> = cropImage

local clamp <const> = clamp

local abs <const> = math.abs
local floor <const> = math.floor
local gfx <const> = playdate.graphics
local noFlip <const> = gfx.kImageUnflipped

local sprite <const> = sprite

local function ensureRouteProps(routeProps)
    if routeProps.initialized then
        return 0
    end
    print("initializing routeProps")
    local minimapImage = ResourceLoader:getImage(levelPath() .. "_minimap")
    routeProps.levelSizeX, routeProps.levelSizeY = minimapImage:getSize()
    minimapImage:addMask(false) -- does nothing if it already has a mask
    routeProps.minimapImage = minimapImage
    routeProps.minimapMaskImage = minimapImage:getMaskImage()

    routeProps.routeImage = gfx.image.new(routeProps.levelSizeX, routeProps.levelSizeY)

    routeProps.initialized = true
    return 6
end


function RenderRoute()
    print("render route")
    local camPos <const> = camPos
    local routeProps <const> = routeProps
    local planePos <const> = planePos

    local renderCost = ensureRouteProps(routeProps)

    -- fog
    gfx.pushContext(routeProps.minimapMaskImage)
    sprite:draw(
        camPos[1]-7, camPos[2]-6,
        noFlip,
        32, 56,
        64,40
    )
    gfx.popContext()

    -- route
    gfx.pushContext(routeProps.routeImage)
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


return function()
    renderRoute()
    local routeProps <const> = routeProps
    local planePos <const> = planePos
    local minimapImage <const> = routeProps.minimapImage
    local srcW, srcH = routeProps.levelSizeX, routeProps.levelSizeY
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

    srcX = floor(clamp(srcX, 0, abs(screenWidth - srcW)))
    srcY = floor(clamp(srcY, 0, abs(screenHeight - srcH)))
    xPos = floor(xPos)
    yPos = floor(yPos)

    print("src", srcX, srcY, srcW, srcH, "pos", xPos, yPos, menuImageOffset)

    local croppedImage = cropImage(
        minimapImage,
        screenWidth, screenHeight,
        srcX, srcY,
        xPos, yPos
    )

    gfx.pushContext(croppedImage)
    -- route
    routeProps.routeImage:draw(xPos, yPos, noFlip, srcX, srcY, screenWidth, screenHeight)


    local markerSize = 16 -- actually 15, but don't want half pixel coordinates

    -- plane border marker
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    local markerX = xPos-srcX + planePos[1] - markerSize/2 + 1
    local markerY = yPos-srcY + planePos[2] - markerSize/2 + 1
    sprite:draw(
        markerX, markerY,
        noFlip,
        0,32,
        markerSize, markerSize
    )
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    sprite:draw(
        markerX + 4,
        markerY + 4,
        noFlip,
        16,32,
        7,7
    )
    gfx.popContext()

    setMenuImage(
        croppedImage,
        menuImageOffset
    )
end
