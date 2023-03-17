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

local oldRoutePattern <const> = {0x82, 0x10, 0x85, 0x20, 0xA, 0x20, 0x88, 0x22, 125, 239, 122, 223, 245, 223, 119, 221}

local function ensureRouteProps(routeProps)
    if routeProps.initialized then
        return 0
    end
    print("initializing routeProps")
    local minimapImage = ResourceLoader:getImage(levelPath() .. "_minimap")
    routeProps.levelSizeX, routeProps.levelSizeY = minimapImage:getSize()
    -- Initially hide minimap by making it transparent
    minimapImage:addMask(false) -- does nothing if it already has a mask
    routeProps.minimapImage = minimapImage
    routeProps.minimapMaskImage = minimapImage:getMaskImage()

    routeProps.routeImage = gfx.image.new(
        routeProps.levelSizeX, routeProps.levelSizeY
    )
    routeProps.routeMaskImage = routeProps.routeImage:getMaskImage()

    routeProps.initialized = true
    return 6
end


function RenderRoute()
    printT("render route " .. frameCounter)
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
    local minimapImage <const> = routeProps.minimapImage
    local levelW, levelH = routeProps.levelSizeX, routeProps.levelSizeY
    local xPos, yPos, srcX, srcY, menuImageOffset = 0,0,0,0,0

    if levelW <= screenWidth then
        xPos = (screenWidth - levelW) / 2
    else
        srcX = planePos[1] - levelW /2
    end

    if levelW < screenWidth / 2 then
        menuImageOffset = 100
    else
        menuImageOffset = floor((planePos[1] / levelW) * 200)
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

    print("src", srcX, srcY, levelW, levelH, "pos", xPos, yPos, menuImageOffset)

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

    setMenuImage(
        croppedImage,
        menuImageOffset
    )

    -- todo remove
    local writeToFile <const> = playdate.simulator.writeToFile
    local tempPath = "/Users/ninovanhooff/temp/"
    writeToFile(routeProps.routeImage, tempPath .. "pre-route.png")
    writeToFile(routeProps.routeMaskImage, tempPath .. "pre-route-mask.png")

    -- blur previous route
    gfx.pushContext(routeProps.routeMaskImage)
    gfx.setPattern(oldRoutePattern)
    gfx.fillRect(0,0,levelW, levelH)
    gfx.popContext()-- routeMaskImage

    -- todo remove
    writeToFile(routeProps.routeImage, tempPath .. "post-route.png")
    writeToFile(routeProps.routeMaskImage, tempPath .. "post-route-mask.png")
end
