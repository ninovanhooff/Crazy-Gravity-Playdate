---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:36
---

local floor <const> = math.floor
local ceil <const> = math.ceil
local max <const> = math.max
local currentTime <const> = playdate.sound.getCurrentTime

function boolToNum(bool)
    if bool then return 1 else return 0 end
end

--- returns -1, 1, or 0 depending on whether x is negative, positive, or 0
function sign(x)
    return (x < 0 and -1) or (x > 0 and 1) or 0
end

function round(x, increment)
    if increment then return round(x / increment) * increment end
    return x >= 0 and floor(x + .5) or ceil(x - .5)
end


--- round to the nearest multiple of mult
--- ie to nearest 2: 1 -> 0, 2.1 -> 2, 2.6 -> 2, 3.1 -> 4, -1.1 -> -2
function roundToNearest(num, mult)
    return floor(num / mult + 0.5) * mult
end

function clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

function isarray(x)
    return type(x) == "table" and x[1] ~= nil
end

--- 1-based mod, where the result is 1 where it would be 0 for the regular mod operation
--- useful for cycling through 1-based indexes like table indexes
--- Usage example: luaMod(levelNumber, #levels+1) would give a 1-based level index that is always a valid index for the `levels` table
function luaMod(first, second)
    if first == 0 then
        return second - 1
    end
    return max(1, first % second)
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
function find(t, value)
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

-- ### END Lume functions

function IncrementStringNumber(str)
    printf("incr",str)
    num = tonumber(str) +1
    return string.format("%0.2d",num)
end

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

function Trunc_Zeros(num,precision)
    local precision = precision or 2
    local numString = string.format("%0."..precision.."f",num)
    local result = numString:gsub("%.?0+$","",1)
    --printf(result)
    return result
end

function Error_Handler(err)
    print(debug.traceback(err,2))
    return err
end

function inspect(tbl)
    for i,item in pairs(tbl) do
        print(i,item)
    end
end

function count(tbl)
    local cnt = 0
    for i,item in pairs(tbl) do
        cnt = cnt + 1
    end
    return cnt
end

function loopAnim(frames,skip)
    return floor((frameCounter % (frames*skip))*(1/skip))
end


function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function convertSpeed(cgSpeed)
    return cgSpeed * (20 / frameRate)
end

function convertInterval(cgInterval)
    return cgInterval / (20 / frameRate)
end

function RUS(capt) -- refactor: aRe yoU Sure dialog
    local RUSresult = MenuBR(capt,{{"Answer",1,{"No","Yes"},val=1}})
    if not RUSresult then return false end
    if RUSresult[1].val==1 then return false else return true end
end

function Show_SCE_ErrorDialog(msg,options)
    print("TODO show error dialog for" .. message)
end

function msg(display, text, msgdlg_args)
    print("TODO display message:" .. text)
end

function table.sum(tbl)
    local sum = 0
    for i,item in pairs(tbl) do
        sum = sum + item
    end
    return sum
end
