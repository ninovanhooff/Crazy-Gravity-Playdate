local setMenuImage <const> = playdate.setMenuImage

local screenWidth <const> = screenWidth
local gameHeightTiles <const> = gameHeightTiles
local visibleMenuWidth <const> = screenWidth / 2
local screenHeight <const> = screenHeight
local ResourceLoader <const> = ResourceLoader
local levelPath <const> = levelPath
local clamp <const> = clamp
local round <const> = round
local floor <const> = math.floor
local gfx <const> = playdate.graphics
local noFlip <const> = gfx.kImageUnflipped
local textAlignmentCenter <const> = kTextAlignment.center
local sprite <const> = sprite
local menuImageOffset <const> = 100
local blurRoutePattern <const> = { 0x82, 0x10, 0x85, 0x20, 0xA, 0x20, 0x88, 0x22, 125, 239, 122, 223, 245, 223, 119, 221 }
local mapBackGroundPattern <const> = { 0x80, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0 }

local function ensureRouteProps(routeProps)
    if routeProps.initialized then
        return 0
    end
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

local function drawMapBorderCorners(menuImage, mapX, mapY, levelW, levelH)
    local markerSize = 8
    gfx.pushContext(menuImage)
    gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
    -- top-left
    sprite:draw(
        mapX, mapY,
        noFlip,
        0,48,
        markerSize, markerSize
    )
    --top-right
    sprite:draw(
        mapX + levelW - markerSize, mapY,
        noFlip,
        markerSize,48,
        markerSize, markerSize
    )
    --bottom-left
    sprite:draw(
        mapX, mapY + levelH - markerSize,
        noFlip,
        0,48+markerSize,
        markerSize, markerSize
    )
    --bottom-right
    sprite:draw(
        mapX + levelW - markerSize, mapY + levelH - markerSize,
        noFlip,
        markerSize,48+markerSize,
        markerSize, markerSize
    )
    gfx.popContext() -- menuImage
end

local function drawMissingBarrierKeys(mapX, mapY, miniMapMaskImage)
    local font = ResourceLoader.getMiniMapGlyphsFont()
    for _,item in ipairs(specialT) do
        local centerX = floor(item.x + item.w/2)-1 -- item is 1-based, img is 0-based
        local centerY = floor(item.y + item.h/2)-1
        if item.sType == 15 and item.missingKeyGlyphs and (item.discovered or miniMapMaskImage:sample(centerX, centerY) == gfx.kColorWhite) then
            local offsetX, offsetY = 0,0

            if item.direction == 1 then -- up
                offsetX = item.w/2
                if item.endStone == 1 then
                    offsetY = item.distance/2 - 4 -- good
                else
                    offsetY = item.distance/2 - 6 -- good
                end
            elseif item.direction == 2 then -- down
                offsetX = item.w/2
                if item.endStone == 1 then
                    offsetY = item.distance/2 - 2 -- good
                else
                    offsetY = item.distance/2 - 1 -- good
                end
            elseif item.direction == 3 then -- left
                if item.endStone == 1 then
                    offsetX = item.distance/2 -- good
                else
                    offsetX = item.distance/2 -- good
                end
                offsetY = item.h/2 - 5
            else -- right
                if item.endStone == 1 then
                    offsetX = item.distance/2 + 1-- good
                else
                    offsetX = item.distance/2 + 1-- good
                end
                offsetY = item.h/2 - 5
            end

            font:drawTextAligned(
                item.missingKeyGlyphs,
                mapX + item.x + offsetX,
                mapY + item.y + offsetY,
                textAlignmentCenter
            )
        end
    end
end


function RenderRoute()
    local camPos <const> = camPos
    local routeProps <const> = routeProps
    local planePos <const> = planePos

    local renderCost = ensureRouteProps(routeProps)

    -- fog
    gfx.pushContext(routeProps.miniMapMaskImage)
    sprite:draw(
        camPos[1]-3, camPos[2]-3, -- mask is a bit narrower and a bit taller than camera view
        noFlip,
        32, 32,
        56,34
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
    local mapX, mapY = 0,0

    -- try to center plane in visible area, while keeping as much of the map on screen as possible
    if levelW < visibleMenuWidth then
        mapX = (menuImageOffset + visibleMenuWidth/2) - (levelW/2)
    else
        local panningRange = levelW - visibleMenuWidth
        local planeOffX = -planePos[1] + menuImageOffset + visibleMenuWidth/2
        mapX = clamp(planeOffX, menuImageOffset - panningRange, menuImageOffset)
    end

    if levelH <= screenHeight then
        mapY = screenHeight/2 - levelH/2
    else
        local panningRange = levelH - screenHeight
        local planeOffY = -planePos[2] + screenHeight/2
        mapY = clamp(planeOffY, -panningRange, 0)
    end

    mapX = floor(mapX)
    mapY = floor(mapY)

    -- create menuImage with map background and masked miniMap
    local menuImage = gfx.image.new(screenWidth, screenHeight, gfx.kColorBlack)
    gfx.pushContext(menuImage)

    -- map background
    gfx.setPattern(mapBackGroundPattern)
    gfx.fillRect(mapX,mapY,levelW,levelH)

    -- miniMap
    miniMapImage:draw(mapX, mapY)

    -- barrier keys
    drawMissingBarrierKeys(mapX, mapY, routeProps.miniMapMaskImage)

    -- route
    routeProps.routeImage:draw(mapX, mapY)

    local markerSize = 16 -- actually 15, but don't want half pixel coordinates

    -- plane border marker
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    local markerX = mapX + planePos[1] - markerSize/2 + 1
    local markerY = mapY + planePos[2] - markerSize/2 + 1
    sprite:draw(
        markerX, markerY,
        noFlip,
        0,32,
        markerSize, markerSize
    )

    -- plane
    local miniRot = round(planeRot / 6) % 4
    gfx.setImageDrawMode(gfx.kDrawModeCopy)
    sprite:draw(
        markerX + 4,
        markerY + 4,
        noFlip,
        32 + miniRot * 7,88,
        7,7
    )
    gfx.popContext() -- menuImage

    drawMapBorderCorners(menuImage, mapX, mapY, levelW, levelH)

    setMenuImage(
        menuImage,
        menuImageOffset
    )

    -- blur previous route
    gfx.pushContext(routeProps.routeMaskImage)
    gfx.setPattern(blurRoutePattern)
    gfx.fillRect(0,0,levelW, levelH)
    gfx.popContext()-- routeMaskImage
end
