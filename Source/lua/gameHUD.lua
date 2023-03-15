local ceil <const> = math.ceil
local max <const> = math.max
local abs <const> = math.abs
local gfx <const> = playdate.graphics
local unFlipped <const> = gfx.kImageUnflipped
local defaultFont = gfx.getFont()
local resourceLoader <const> = GetResourceLoader()
local monoFont <const> = resourceLoader:getMonoFont()
local smallFont <const> = resourceLoader:getSmallFont()
local renderTooltip <const> = Tooltips.renderTooltip
local screenWidth <const> = screenWidth
local inputManager <const> = inputManager
local currentTime <const> = playdate.sound.getCurrentTime
local hudY <const> = hudY
local centerTextCoordinates <const> = playdate.geometry.point.new(screenWidth/2, hudY+1)
local hudHeight <const> = screenHeight - hudY

local hudIcons = sprite -- hudIcons are placed at origin of the sprite
local hudBgClr = gfx.kColorWhite
local hudFgClr = gfx.kColorBlack
local hudPadding = 8 -- distance between items
local hudGutter = 4 -- distance between item icon and item value

local hudBlinkers = {}
for i = 1,#extras+1 do -- all extras +1 for keys
    hudBlinkers[i] = gfx.animation.blinker.new()
end

class('GameHUD').extends()

GameHUD.lowFuelThreshold = 700

function GameHUD:init()
    GameHUD.super.init(self)
    self.selectedChallenge = 1 -- 1: time, 2: fuel, 3: survivor
    self.challengeTarget = 1 -- seconds
    self.lastChallengeValue = nil
end

-- global singleton
if not gameHUD then
    gameHUD = GameHUD()
end

local function drawIcon(x, index, srcY)
    hudIcons:draw(x,hudY,unFlipped,index*16,srcY or 0,16,16)
end

function GameHUD:challengeViewState()
    local currentValue, iconIdx = "", 4
    if self.selectedChallenge == 1 then
        -- elapsed time
        currentValue = ceil(frameCounter/frameRate)
        iconIdx = 4
    elseif self.selectedChallenge == 2 then
        -- fuel
        currentValue = ceil(fuelSpent)
        iconIdx = 5
    elseif self.selectedChallenge == 3 then
        -- survivor
        currentValue = livesLost
        iconIdx = 6
    end
    return currentValue, iconIdx
end

function GameHUD:clear()
    gfx.setColor(hudBgClr)
    gfx.fillRect(0,hudY,screenWidth,16)
    gfx.setColor(hudFgClr)
end

function GameHUD:render(conservative)
    local renderCost = 0
    local secondsSinceInputConfigChange = currentTime() - inputManager.lastInputTypeChangeTime
    if secondsSinceInputConfigChange < 1 then
        self:renderControlsType()
        renderCost = renderCost + 2
    elseif secondsSinceInputConfigChange < 4 then
        self:renderControlsMapping()
        renderCost = renderCost + 2
    elseif frameCounter == 0 then
        self:renderStart()
        renderCost = renderCost + 2
    elseif conservative then
        self:renderChallenge()
        renderCost = renderCost + 2
    else
        self:renderFull()
        renderCost = renderCost + 6
    end

    if fuel < GameHUD.lowFuelThreshold and fuelEnabled and frameCounter > 0 then
        self:renderLowFuelTooltip()
        renderCost = renderCost + 2
    end
    return renderCost
end

function GameHUD:renderCenteredText(text)
    smallFont:drawTextAligned(
        text,
        centerTextCoordinates.x, centerTextCoordinates.y,
        kTextAlignment.center
    )
end

function GameHUD:renderControlsType()
    self:clear()
    self:renderCenteredText(inputManager:inputTypeString())
end

function GameHUD:renderControlsMapping()
    self:clear()
    self:renderCenteredText(inputManager:fullMappingString())
end

--- Render HUD for frame 0, with challenge centered
function GameHUD:renderStart()
    self:clear()

    local font = defaultFont
    local _, iconIdx = self:challengeViewState()
    -- render
    local textW = font:getTextWidth(self.challengeTarget)
    local totalWidth = textW + hudGutter + 16
    local x = (screenWidth - totalWidth)/2
    drawIcon(x, iconIdx,0)
    x = x + hudGutter + 16
    font:drawText(self.challengeTarget,x,hudY)
end

function GameHUD:renderChallenge(force)
    local currentValue, iconIdx = self:challengeViewState()
    if self.lastChallengeValue == currentValue and not force then
        return
    end
    -- render
    local textW = monoFont:getTextWidth(currentValue)
    local textX = screenWidth - textW - hudPadding
    local iconX = textX - hudGutter - 16
    gfx.setColor(hudBgClr)
    gfx.fillRect(iconX, hudY, screenWidth - iconX, hudHeight)
    gfx.setColor(hudFgClr)
    monoFont:drawText(currentValue, textX,hudY+2)
    local srcY = boolToNum(self.challengeTarget < currentValue)*16
    drawIcon(iconX, iconIdx,srcY)
    self.lastChallengeValue = currentValue
end

function GameHUD:renderFull()
    gfx.setColor(hudBgClr)
    gfx.fillRect(0,hudY,screenWidth,16)
    gfx.setColor(hudFgClr)

    local x = hudPadding

    -- lives
    if hudBlinkers[2].on then
        drawIcon(x, 0)
    end
    x = x+16+hudGutter
    -- drawText returns drawn text width
    x = x+defaultFont:drawText(extras[2], x, hudY)+hudPadding

    -- fuel
    if fuelEnabled then
        if fuel > 1500 or frameCounter % 20 > 10 then
            drawIcon(x, 5)
        end
        x = x+16+hudGutter
        gfx.drawRect(x, hudY+1, 32, 14)
        local fuelW = (fuel/6000)*28
        self.fuelIndicatorCenterX = x + 17
        gfx.setPattern({0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99, 0x99})
        gfx.fillRect(x+3, hudY+4, fuelW,8)
        gfx.setColor(hudFgClr)
        x = x+32+hudPadding
    end

    -- cargo
    if hudBlinkers[3].on then
        drawIcon(x, 7)
    end
    x = x+16+hudGutter
    local containerWidth = extras[3] * 10 + 4
    gfx.drawRect(x, hudY+1, containerWidth, 14)
    for i=0,#planeFreight-1 do
        hudIcons:draw(x+i*10+2, hudY+3, unFlipped, 115, 18,10,10)
    end
    x = x+containerWidth+hudPadding-1

    -- keys
    if barriersEnabled then
        if hudBlinkers[4].on then
            drawIcon(x, 1)
        end
        x=x+12+hudGutter
        for i=1,4 do
            local subX = (i+1)%2*8
            local subY = boolToNum(i>2)*9
            hudIcons:draw(x+subX, hudY+subY, unFlipped, 32 +subX, boolToNum(keys[i])*16 + subY,8,8)
        end
        x = x+15+hudPadding
    end

    -- turbo -> speed warning
    if(extras[1] > 0) then -- turbo enabled
        if hudBlinkers[1].on then
            hudIcons:draw(x, hudY, unFlipped, 48,16 ,16,16)
        end
    else
        drawIcon(x, 3) -- regular speed icon
    end
    x = x+16+hudGutter
    gfx.drawCircleInRect(x+1,hudY+1, 14,14)
    local speedPattern = gfx.image.kDitherTypeBayer8x8
    local warnX = 1/(landingTolerance.vX / abs(vx))
    local warnY = 1/(landingTolerance.vY / vy) -- only downwards movement is dangerous
    local warnAlpha = max(warnX, warnY)
    gfx.setDitherPattern(1-warnAlpha, speedPattern) -- invert alpha due to bug in SDK
    gfx.fillCircleInRect(x+4,hudY+4, 8,8)
    self.speedIndicatorCenterX = x + 8
    gfx.setDitherPattern(1, gfx.image.kDitherTypeNone)
    x = x+16+hudPadding

    self:renderChallenge(true)
end

function GameHUD:renderLowFuelTooltip()
    if self.fuelIndicatorCenterX then
        local text
        if fuel < 1 then
            text = "Out of fuel!"
        elseif fuel < GameHUD.lowFuelThreshold then
            text = "Go get fuel!"
        else
            text = "Fuel"
        end
        renderTooltip({text = text, alignment="above"}, self.fuelIndicatorCenterX, hudY - 1)
    end
end

function GameHUD:renderOverSpeedTooltip()
    if self.speedIndicatorCenterX then
        renderTooltip({text = "Watch your speed!", alignment="above"}, self.speedIndicatorCenterX, hudY - 1)
    end
end

function GameHUD:reset()
    self.fuelIndicatorCenterX = nil
    self.speedIndicatorCenterX = nil
end

--- Notify the GameHud that the count of one of the stats has changed.
--- @param itemId number @ 1: turbo, 2: lives, 3:cargo, 4: key
function GameHUD:onChanged(itemId)
    hudBlinkers[itemId]:start()
end
