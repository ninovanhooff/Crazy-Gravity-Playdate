import "CoreLibs/object"

local justPressed <const> = playdate.buttonJustPressed
local buttonB <const> = playdate.kButtonB
local halfScreenHeight <const> = screenHeight/2
local tileSize <const> = tileSize
local floor <const> = math.floor

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
    print(vy)
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
end

function CreditsViewModel:pause()
end

function CreditsViewModel:resume()
end

function CreditsViewModel:destroy()
    drag = self.origDrag
    gravity = self.origGravity
end
