import "CoreLibs/object"

local gfx <const> = playdate.graphics
local floor <const> = math.floor

local controlRoomBG = gfx.image.new("images/launch_control_room")
local rocketShip = gfx.image.new("images/rocket_ship")
local airlockCrank <const> = gfx.imagetable.new("images/airlock-crank/airlock-crank")
if #airlockCrank < 1 then
    error("no crank frames")
end
local rocketShipX <const> = 182
local tileSize <const> = tileSize


class("EndGameView").extends()

local function renderGame(viewModel)
    gfx.setColor(gfx.kColorBlack)

    -- bricks
    bricksView:render()

    -- rocket ship
    rocketShip:draw(
        rocketShipX-camPos[1]*tileSize-camPos[3],
        floor(viewModel.planePosY - 8*tileSize - camPos[2]*tileSize-camPos[4])
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

function EndGameView:init(viewModel)
    EndGameView.super.init(self)
    viewModel.numCrankFrames = #airlockCrank
end

function EndGameView:resume()
    gfx.clear(gameBgColor)
end


function EndGameView:render(viewModel)
    renderGame(viewModel)
    if viewModel.controlRoomAnimator then
        local controlRoomX = viewModel.controlRoomAnimator:currentValue()
        controlRoomBG:draw(controlRoomX,0)
        airlockCrank:getImage(viewModel.crankFrame + 1):draw(controlRoomX + 265,180)
    end
end
