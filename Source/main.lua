import "util.lua"
import "level.lua"
import "game.lua"
import "init.lua"

function startGame()
    InitGame("levels/LEVEL01.CGPB")
    RenderGame(true)
end

sucs,err = xpcall(startGame,Error_Handler)
if sucs then
    printf("done")
    error("done")
else
    error(err)
end

local gfx = playdate.graphics

gfx.setColor(gfx.kColorBlack)

function playdate.update()
    gfx.fillRect(0, 0, 400, 240)
    playdate.drawFPS(0,0)
    playdate.timer:updateTimers()
end
