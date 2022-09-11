import "CoreLibs/object"

local gfx <const> = playdate.graphics
local asteroidSurface = gfx.image.new("images/asteroid_surface")
local rocketShip = gfx.image.new("images/rocket_ship")


class("FlyToCreditsView").extends()

function FlyToCreditsView:init(viewModel)
    FlyToCreditsView.super.init(self)
    _, viewModel.rocketShipHeight = rocketShip:getSize()
    gfx.pushContext(rocketShip)
    -- plane
    sprite:draw(
        18, 8*tileSize,
        unFlipped,
        planeRot%16*23, 391+(boolToNum(planeRot>15)*2-thrust)*23,
        23, 23
    )
    gfx.popContext()
end

function FlyToCreditsView:render(viewModel)
    asteroidSurface:draw(0,0)
    rocketShip:draw(88, viewModel.rocketShipY)
end
