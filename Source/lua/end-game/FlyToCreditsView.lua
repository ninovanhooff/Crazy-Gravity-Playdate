

local gfx <const> = playdate.graphics
local asteroidSurface = gfx.image.new("images/asteroid_surface")
local startBG = gfx.image.new("images/start_background")
local rocketShip = gfx.image.new("images/rocket_ship")
local rocketShipX = 81
local planeX = rocketShipX + 25


class("FlyToCreditsView").extends()

function FlyToCreditsView:init(viewModel)
    FlyToCreditsView.super.init(self)
    _, viewModel.rocketShipHeight = rocketShip:getSize()
end

function FlyToCreditsView:render(viewModel)
    if viewModel.bgType == FlyToCreditsViewModel.bgTypes.surface then
        asteroidSurface:draw(0,0)
    elseif viewModel.bgType == FlyToCreditsViewModel.bgTypes.asteroids then
        startBG:draw(0,0)
    elseif viewModel.bgType == FlyToCreditsViewModel.bgTypes.stars then
        gfx.clear(gfx.kColorBlack)
        gfx.setColor(gfx.kColorWhite)
        -- draw stars
        local random <const>  = math.random
        local screenWidth <const> = screenWidth
        local screenHeight <const> = screenHeight
        for _ = 1, 10 do
            gfx.drawPixel(random(1, screenWidth), random(1, screenHeight))
        end
    else
        error("bgType not implemented in View:", viewModel.bgType)
    end
    local rocketShipY = viewModel.rocketShipY
    rocketShip:draw(rocketShipX, rocketShipY)
    local loopSpecs = viewModel.exhaustLoopSpecs
    if loopSpecs then
        loopSpecs.loop:draw(
            rocketShipX + loopSpecs.offsetX,
            rocketShipY + loopSpecs.offsetY
        )
    end
    -- plane
    sprite:draw(
        planeX, viewModel.planeY,
        unFlipped,
        planeRot%16*23, 391+(boolToNum(planeRot>15)*2-thrust)*23,
        23, 23
    )
end
