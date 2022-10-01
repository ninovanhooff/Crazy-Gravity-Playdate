import "CoreLibs/object"
import "CoreLibs/animation"


local gfx <const> = playdate.graphics
local loop <const> = gfx.animation.loop
local floor <const> = math.floor

local controlRoomBG = gfx.image.new("images/launch_control_room")
local launchTowerImg = gfx.image.new("images/launch_tower")
local launchBurnImgTable = gfx.imagetable.new("images/rocket_ship_burn")
local rocketShip = gfx.image.new("images/rocket_ship")
local airlockCrank <const> = gfx.imagetable.new("images/airlock-crank/airlock-crank")
if #airlockCrank < 1 then
    error("no crank frames")
end
local rocketShipX <const> = 175
local tileSize <const> = tileSize


class("EndGameView").extends()

function EndGameView:init(viewModel)
    EndGameView.super.init(self)
    viewModel.numCrankFrames = #airlockCrank
    self.launchBurnLoop = loop.new(100, launchBurnImgTable, true)

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
    self.launchBurnLoop:draw(
        rocketShipScreenX + 22,
        rocketShipScreenY + 114
    )

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
        airlockCrank:getImage(viewModel.crankFrame + 1):draw(controlRoomX + 265,180)
    end
end
