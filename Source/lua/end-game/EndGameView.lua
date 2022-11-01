



local gfx <const> = playdate.graphics
local floor <const> = math.floor

local controlRoomBG = gfx.image.new("images/launch_control_room")
local launchTowerImg = gfx.image.new("images/launch_tower")
local rocketShip = gfx.image.new("images/rocket_ship")
local airlockCrank <const> = gfx.imagetable.new("images/launch_control_crank")
local launchButton <const> = gfx.imagetable.new("images/launch_control_button")
if #airlockCrank < 1 then
    error("no crank frames")
end
local rocketShipX <const> = 175
local tileSize <const> = tileSize


class("EndGameView").extends()

function EndGameView:init(viewModel)
    EndGameView.super.init(self)
    viewModel.numCrankFrames = #airlockCrank
end

function EndGameView:resume()
    gfx.clear(gameBgColor)
end

function EndGameView:renderGame(viewModel)
    gfx.setColor(gfx.kColorBlack)

    -- bricks
    bricksView:render()

    local rocketShipScreenX = rocketShipX-camPos[1]*tileSize-camPos[3]
    local rocketShipScreenY = floor(viewModel.planePosY - 7*tileSize - camPos[2]*tileSize-camPos[4])

    -- rocket ship
    launchTowerImg:draw(
        rocketShipScreenX - 20,
        viewModel.launchTowerY - camPos[2]*tileSize-camPos[4]
    )
    rocketShip:draw(rocketShipScreenX, rocketShipScreenY)
    if viewModel.rocketExhaustLoop then
        viewModel.rocketExhaustLoop:draw(
            rocketShipScreenX + viewModel.exhaustLoopOffsetX,
            rocketShipScreenY + viewModel.exhaustLoopOffsetY
        )
    end

    -- specials
    for _,item in ipairs(specialT) do -- special blocks
        local scrX,scrY = (item.x-camPos[1])*8-camPos[3],(item.y-camPos[2])*8-camPos[4]
        if item.x+item.w>=camPos[1] and item.x<=camPos[1]+gameWidthTiles+1 and item.y+item.h>=camPos[2] and item.y<camPos[2]+gameHeightTiles+1 then
            specialRenders[item.sType-7](item, scrX, scrY)
        end
    end

    -- plane
    sprite:draw(
        floor((planePos[1]-camPos[1])*8+planePos[3]-camPos[3]),
        floor((planePos[2]-camPos[2])*8+planePos[4]-camPos[4]),
        unFlipped,
        planeRot%16*23, 391+(boolToNum(planeRot>15)*2-thrust)*23,
        23, 23
    )
end


function EndGameView:render(viewModel)
    self:renderGame(viewModel)
    if viewModel.controlRoomAnimator then
        local controlRoomX = viewModel.controlRoomAnimator:currentValue()
        controlRoomBG:draw(controlRoomX,0)
        airlockCrank:getImage(viewModel.crankFrame):draw(controlRoomX + 283,184)
        launchButton:getImage(viewModel.launchButtonFrame):draw(controlRoomX + 174, 154)
    end

    if viewModel.videoPlayerView and not viewModel.videoViewModel.finished then
        viewModel.videoPlayerView:render(viewModel.videoViewModel)
    end
end
