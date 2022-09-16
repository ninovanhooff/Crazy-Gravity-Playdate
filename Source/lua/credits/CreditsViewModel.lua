import "CoreLibs/object"
import "lua/start/startScreen.lua"

class("CreditsViewModel").extends()

local function setCamPosTopLeft()
    camPos[1], camPos[3] = 1,0
    camPos[2], camPos[4] = 1,0
end

function CreditsViewModel:init()
    CreditsViewModel.super.init(self)
    InitGame("levels/temp",1)
    planePos[1] = 13
    planePos[2] = 28
    planePos[3] = 2
    setCamPosTopLeft()
    flying = true
    vy = -4
    self.origGravity = gravity
    self.origDrag = drag
    self.initialMoveUp = true

    -- this combination of gravity and drag slows down the plane very slowly
    gravity = 0.01
    drag = 0.98

    --self.planeX, self.planeY = 106, screenHeight - 10
    --self.creditsY = 100
end

function CreditsViewModel:update()
    ProcessInputs()
    CalcTimeStep()
    if self.initialMoveUp then
        setCamPosTopLeft()
        if vy > 0 then
            -- this combination of gravity and drag stabilizes downward motion at 2px / frame
            -- and upward motion at 4px / frame
            gravity = 0.07
            drag = 0.9662
            self.initialMoveUp = false
        end
    end
    print(camPos[2],  camPos[4])
    if camPos[2] == levelProps.sizeY - screenHeight/tileSize then
        local planePos <const> = planePos
        local planeX = planePos[1] * tileSize + planePos[3]
        -- subtract 1x tileSize to compensate for 1-based cam pos
        local planeY = planePos[2] * tileSize + planePos[4] - tileSize
        -- restart the game
        clearNavigationStack()
        pushScreen(StartScreen(planeX, planeY))
    end
end

function CreditsViewModel:pause()
end

function CreditsViewModel:resume()
end

function CreditsViewModel:destroy()
    drag = self.origDrag
    gravity = self.origGravity
end
