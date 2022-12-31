class('SpeedHoldCamController').extends()

local abs <const> = math.abs
local sign <const> = sign
local round <const> = round
local speedStep <const> = 2
local avgFactor <const> = 2

function SpeedHoldCamController:init(maxHistoryLength, integralThreshold, label, speedHold) -- todo unused integral
    self.maxHistoryLength = maxHistoryLength
    self.integralThreshold = integralThreshold
    self.label = label
    self.speedHold = speedHold

    self.lastAvgTarget = nil
    self.lastError = 0
    self.speed = 0
    self.history = {}
    self.errorIntegral = 0

    -- next update iteration when a speed change is allowed
    self.holdSpeedUntil = 0
    self.updateCount = 0
end

--- returns new value based on value and target
function SpeedHoldCamController:update(value, target)
    if LockCamera then return value end

    local avgTarget <const> = ((self.lastAvgTarget or target)*avgFactor + target) / (avgFactor + 1)
    local error <const> = avgTarget - value
    local absError <const> = abs(error)
    local result = value

    table.insert(self.history, error)
    self.errorIntegral = self.errorIntegral + error
    if #self.history > self.maxHistoryLength then
        self.errorIntegral = self.errorIntegral - table.remove(self.history, 1)
    end


    local allowedError = 12
    local errorSpeed = error - self.lastError
    local targetSpeed = avgTarget - (self.lastAvgTarget or avgTarget)

    if self.lastAvgTarget and abs(self.lastAvgTarget - avgTarget) < 0.1 then
        -- crawl mode, useful when target is stationary. otherwise, camera could come to a stop way off center
        if abs(error) > speedStep then
            result = result + sign(error) * speedStep
        end
        self.speed = 0
        print(self.label, "CRAWL")
    elseif absError > allowedError and sign(errorSpeed) == sign(error) then
        --self:setSpeed(self.speed + sign(error)*speedStep)
        self:setSpeed((self.speed  + targetSpeed)*0.5 + sign(error))
        print(self.label, "SPEEDSTEP", self.speed)
    elseif absError <= allowedError then
        -- we are within allowed error range. Let's keep it that way
        -- by matching the target speed as close as possible
        self:setSpeed(targetSpeed, true)
        print(self.label, "MATCH", absError, allowedError, errorSpeed )
    end

    result = result + self.speed

    self.updateCount = self.updateCount + 1
    self.lastAvgTarget = avgTarget
    self.lastError = error
    return result
end

function SpeedHoldCamController:setSpeed(newSpeed, force)
    if self.updateCount < self.holdSpeedUntil and not force then return end
    self.holdSpeedUntil = self.updateCount + self.speedHold
    self.speed = round(newSpeed, speedStep)
end
