import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local halfScreenHeight <const> = screenHeight/2
local floor <const> = math.floor
local planePos <const> = planePos

class("CreditsViewModel").extends()

function CreditsViewModel:init()
    CreditsViewModel.super.init(self)
    InitGame("levels/temp",1)
    planePos[1] = 4
    planePos[2] = 28
    camPos[1] = 1
    camPos[2] = 1
    flying = true
    vy = -2
    self.origGravity = gravity
    self.origDrag = drag
    self.initialMoveUp = false -- todo

    -- this combination of gravity and drag stabilizes downward motion at 2px / frame
    -- and upward motion at 4px / frame
    gravity = 0.167
    drag = 0.922935

    --self.planeX, self.planeY = 106, screenHeight - 10
    --self.creditsY = 100
end

function CreditsViewModel:update()
    if self.initialMoveUp then
        planePos[4] = planePos[4] + vy
        vy = vy * 0.997
        if planePos[4]<0 then
            local substUnits = -floor(planePos[4]*0.125)
            planePos[2] = planePos[2]-substUnits
            planePos[4] = 8+(planePos[4]+(substUnits-1)*8)
        end

        if planePos[2] < 10 then
            self.initialMoveUp = false
        end
    else
        ProcessInputs()
        CalcTimeStep()
    end
end

function CreditsViewModel:pause()
end

function CreditsViewModel:resume()
end

function CreditsViewModel:destroy()
    drag = self.origDrag -- todo
    gravity = self.origGravity
end
