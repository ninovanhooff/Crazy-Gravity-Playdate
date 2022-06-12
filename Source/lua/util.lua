---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:36
---

local floor <const> = math.floor

function boolToNum(bool)
    if bool then return 1 else return 0 end
end

function sign(x)
    return x < 0 and -1 or 1
end

function clamp(x, min, max)
    return x < min and min or (x > max and max or x)
end

function isarray(x)
    return type(x) == "table" and x[1] ~= nil
end

local getiter = function(x)
    if isarray(x) then
        return ipairs
    elseif type(x) == "table" then
        return pairs
    end
    error("expected table", 3)
end

--- return index of value in table t; or nil
function find(t, value)
    local iter = getiter(t)
    for k, v in iter(t) do
        if v == value then return k end
    end
    return nil
end

function levelNumString(levelNumber)
    return string.format("%03d", levelNumber)
end

function levelPath(_levelNumber)
    local levelNumber = _levelNumber or currentLevel
    return "levels/User" .. levelNumString(levelNumber) .. ".pdz"
end

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
    -- todo, is there a playdate equivalent?
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

function pressed(btn)
    if controls.pressed(btn) or controls.held(btn) then
        return true
    else
        return false
    end
end

function pressedany() --pressed or held!!
    return pressed(cross) or pressed(circle) or pressed(triangle) or pressed(square) or pressed(up) or pressed(down) or pressed(left) or pressed(right) or pressed(ltrigger) or pressed(rtrigger) or pressed(start) or pressed(select)
end


function convertSpeed(cgSpeed)
    return cgSpeed * (20 / frameRate)
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
