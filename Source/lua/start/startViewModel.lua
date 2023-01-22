import "../common/PlanePhysicsViewModel.lua"

local playdate <const> = playdate
local gfx <const> = playdate.graphics
local currentTime <const> = playdate.sound.getCurrentTime
local pickRandom <const> = pickRandom
local setCollectsGarbage <const> = playdate.setCollectsGarbage
local setRefreshRate <const> = playdate.display.setRefreshRate
local animator <const> = playdate.graphics.animator
local lineSegment <const> = playdate.geometry.lineSegment
local enterEasing <const> = playdate.easingFunctions.outCubic
local enterDuration <const> = 300
--- time between start of button enter animations
local enterButtonTimeGap <const> = 100
--- seconds
local hintDelay < const> = 6

local buttonTimer <const> = playdate.timer.new(1500, 0, 1) -- duration, start, end
buttonTimer.discardOnCompletion = false
buttonTimer:pause()  -- disable auto start

local screenWidth <const> = screenWidth
local buttonHeight <const> = 48

local function updateViewState(self)
    local viewState <const> = self.viewState
    viewState.planeRot = self.planeRot
    viewState.planeX, viewState.planeY = self.planeX, self.planeY
    viewState.thrust = self.thrust
    viewState.planeTooltip = nil
    for _, item in ipairs(viewState.buttons) do
        if item.progress > 0 then
            viewState.planeTooltip = {text=item.text, progress = item.progress}
            break
        end
    end


    return viewState
end

local function getChallengesHint()
    local challengesUnlocked = 0
    for levelNum, levelRecords in ipairs(records) do
        local challenges = getChallengesForPath(levelPath(levelNum))
        for challengeIdx, score in ipairs(challenges) do
            if levelRecords[challengeIdx] <= score then
                -- challenge completed
                challengesUnlocked = challengesUnlocked + 1
            end
        end
    end

    return string.format("Achievements unlocked: %d / 75", challengesUnlocked)
end

print("hint", getChallengesHint())

local function getHintText()
    if #records > numLevels/2 then
        return getChallengesHint()
    end

    local candidates = {
        getChallengesHint(),
        "Button mapping can be adjusted in Settings"
    }

    if gameBgColor ~= gfx.kColorWhite then
        table.insert(candidates, "Low visibility?\nSet background to White in Settings")
    end
    if gameBgColor ~= gfx.kColorClear then
        table.insert(candidates, "Nostalgic for Win95?\nTry background Trippy in Settings")
    end
    if #records > 1 and rotationDelay > 1 then -- rotationDelay > 1 means that the current setting must be "slow"
        table.insert(candidates, "Feeling confident?\nSet turn speed to medium in Settings")
    end
    if InitialLives < 12 then
        table.insert(candidates, "Having a hard time?\nGive yourself some extra lives in Settings")
    end
    if blowerStrength > 0.1 then
        table.insert(candidates, "Bad hair day?\nLower blower strength in Settings")
    end
    if magnetStrength > 0.1 then
        table.insert(candidates, "Fatal attraction?\nLower magnet strength in Settings")
    end
    if frameRate == 30 then
        table.insert(candidates, "Not a pro gamer?\nLower the game speed in Settings")
    end
    if GetResourceLoader().graphicsStyle~="classic" then
        table.insert(candidates, "Did you play Crazy Gravity?\nTry style Classic in Settings")
    end

    return pickRandom(candidates)
end

class("StartViewModel").extends(PlanePhysicsViewModel)

function StartViewModel:resetPlane(initialPlaneX, initialPlaneY)
    self.flying = true -- always true for StartScreen
    -- position just outside of screen
    self.planeX, self.planeY = initialPlaneX or -22, initialPlaneY or 150
    if not initialPlaneX and not initialPlaneY then
        -- vx,vy set to 0 because the plane only enters the frame after enterDuration
        self.vx,self.vy,self.planeRot,self.thrust = 0,0,21,0 -- thrust only 0 or 1; use thrustPower to adjust.
    else
        self.vx,self.vy,self.planeRot,self.thrust = vx,vy,planeRot,thrust
    end
end

function StartViewModel:loadFullResources()
    GetOptions():apply(false)
end

local function createLogoEnterAnimator()
    return animator.new(enterDuration, 0, 1, enterEasing)
end

--- param buttonIdx: 0-based
local function createButtonEnterAnimator(buttonIdx, x, y)
    local segment = lineSegment.new(screenWidth, y, x, y)
    return animator.new(enterDuration, segment, enterEasing, enterButtonTimeGap*buttonIdx)
end

function StartViewModel:init(initialPlaneX, initialPlaneY)
    StartViewModel.super.init(self)
    self:resetPlane(initialPlaneX, initialPlaneY)
    self.viewState = {}
    self.shouldPlayEnterSound = true

    -- many of this code should be called onResume, currently timers are already running when
    -- the VM is created before the StartScreen is shown

    self.startTime = currentTime()

    -- set high frameRate for smooth enter transitions
    setCollectsGarbage(false)
    setRefreshRate(50)

    self.viewState.logoAnimator = createLogoEnterAnimator()

    playdate.timer.performAfterDelay(enterDuration, function()
        setCollectsGarbage(true)
        setRefreshRate(GetOptions():getGameFps())
        -- when no initial positioning is provided,
        -- throw plane into the scene after enter animation completed
        if not initialPlaneX then
            self:resetPlane()
            self.vx, self.vy = 7.5, -7.5
        end
    end)


    self.viewState.buttons = {
        {
            text = "Settings",
            pType = 2,
            w = 96, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function()
                ui_confirm:play()
                require "lua/settings/SettingsScreen"
                return SettingsScreen()
            end,
            animator = createButtonEnterAnimator(0, 260,50)
        },
        {
            text = "Start",
            pType = 1,
            w = 128, h = buttonHeight,
            progress = 0.0,
            onClickScreen = function()
                ui_confirm:play()
                require "lua/level-select/levelSelectScreen"
                self:loadFullResources()
                return LevelSelectScreen()
            end,
            animator = createButtonEnterAnimator(1, 195, 140)
        },
    }
    updateViewState(self)
end

-- returns true if this rect may collide with planePos, does not take plane sub-pos ([3] and 4]) into
-- account. When false, it is guaranteed that this rect does not intersect with the plane
function StartViewModel:approxRectCollision(button)
    local x,y = button.animator:currentValue():unpack()
    -- plane size is 24px
    return self.planeX + 24 > x and self.planeX < x+button.w  and self.planeY+24 > y and self.planeY <y+button.h
end

--- Invokes Screen button's onClick function if activated
function StartViewModel:calcButtonCollision()
    local anyCollision = false
    for _, button in ipairs(self.viewState.buttons) do
        if self:approxRectCollision(button) then
            buttonTimer:start() -- does nothing when already running
            button.progress = buttonTimer.value
            if button.progress >= 1.0 then
                pushScreen(button.onClickScreen())
                return
            end
            anyCollision = true
        else
            button.progress = 0
        end
    end

    if not anyCollision then
        buttonTimer:reset()
    end

end

function StartViewModel:calcTimeStep()
    if self.shouldPlayEnterSound then
        swish_sound_reverse:play() -- play once
        self.shouldPlayEnterSound = false
    end
    self:processInputs()
    self:calcPlane()
    self:calcButtonCollision()
    if not self.viewState.hintText and currentTime() > self.startTime + hintDelay then
        self.viewState.hintText = getHintText()
    end
    return updateViewState(self)
end

function StartViewModel:pause()
    setCollectsGarbage(true) -- overly cautious: navigator guards against this too
    setRefreshRate(frameRate)
    if Sounds then thrust_sound:stop() end
end
