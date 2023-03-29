---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:36
---

local floor <const> = math.floor
local random <const> = math.random
local currentTime <const> = playdate.sound.getCurrentTime

function boolToNum(bool)
    if bool then return 1 else return 0 end
end

--- returns -1, 1, or 0 depending on whether x is negative, positive, or 0
function sign(x)
    return (x < 0 and -1) or (x > 0 and 1) or 0
end

--- round to the nearest multiple of increment
--- ie to nearest 2: 1 -> 0, 2.1 -> 2, 2.6 -> 2, 3.1 -> 4, -1.1 -> -2
function round(num, increment)
    local increment = increment or 1
    return floor(num / increment + 0.5) * increment
end

function clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

function isarray(x)
    return type(x) == "table" and x[1] ~= nil
end

--- 1-based mod, where the result is 1 where it would be 0 for the regular mod operation
--- useful for cycling through 1-based indexes like table indexes
--- Usage example: luaMod(levelNumber, #levels) would give a 1-based level index that is always a valid index for the `levels` table
function luaMod(first, second)
    return (first - 1) % second + 1
end

function pickRandom(tbl)
    return tbl[random(1, #tbl)]
end

--- calculate the shortest distance to reach destRotation from startRotation
--- assumes a circle with 24 angles, so that angle 0 == angle 24 and the maximum angle is 23
--- example: smallestPlaneRotation(23, 1) => -2
function smallestPlaneRotation(destRotation, startRotation)
    return ((destRotation - startRotation) + 12) % 24 - 12
end

function planeRotationToDeg(rotation)
    return (90 + (rotation * 15)) % 360
end

function clampPlaneRotation(rotation)
    local modded = rotation % 24
    if modded < 0 then
        return modded + 24
    else
         return modded
    end
end

-- ### START Lume functions

local identity = function(x)
    return x
end

local iscallable = function(x)
    if type(x) == "function" then return true end
    local mt = getmetatable(x)
    return mt and mt.__call ~= nil
end

local getiter = function(x)
    if isarray(x) then
        return ipairs
    elseif type(x) == "table" then
        return pairs
    end
    error("expected table", 3)
end

local iteratee = function(x)
    if x == nil then return identity end
    if iscallable(x) then return x end
    if type(x) == "table" then
        return function(z)
            for k, v in pairs(x) do
                if z[k] ~= v then return false end
            end
            return true
        end
    end
    return function(z) return z[x] end
end


--- return index of value in table t; or nil
function findIndexOf(t, value)
    local iter = getiter(t)
    for k, v in iter(t) do
        if v == value then return k end
    end
    return nil
end

function match(t, fn)
    fn = iteratee(fn)
    local iter = getiter(t)
    for k, v in iter(t) do
        if fn(v) then return v, k end
    end
    return nil
end

function map(t, fn)
    fn = iteratee(fn)
    local iter = getiter(t)
    local rtn = {}
    for k, v in iter(t) do rtn[k] = fn(v, k) end
    return rtn
end

-- ### END Lume functions

function printf(...)
    local arg = {...}
    if Debug then
        print(table.unpack(arg))
    end
end

function printT(...)
    local arg = {...}
    print(currentTime(), table.unpack(arg))
end

function inspect(tbl)
    for i,item in pairs(tbl) do
        print(i,item)
    end
end

function loopAnim(frames,skip)
    return floor((frameCounter % (frames*skip))*(1/skip))
end


function convertSpeed(cgSpeed)
    return cgSpeed * (20 / frameRate)
end

function convertInterval(cgInterval)
    return cgInterval / (20 / frameRate)
end

--- sums HASHED entries
function table.sum(tbl)
    local sum = 0
    for i,item in pairs(tbl) do
        sum = sum + item
    end
    return sum
end
