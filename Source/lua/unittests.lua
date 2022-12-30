---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 05/08/2022 11:15
---

local function test(expected, actual, description)
    if expected ~= actual then
        print(description)
        error(string.format("Expected %s, got %s", expected, actual))
    end
end

local round <const> = round
local function roundTest(expected, number, increment)
    test(expected, round(number, increment), table.concat({"round", number, increment}, ", "))
end

roundTest(0, 0,2)
roundTest(0, 0.1,2)
roundTest(0, 0.1,1)
roundTest(0, 0.1) -- default for increment is 1
roundTest(2, 1.2,2)
roundTest(2, 2,2)
roundTest(2, 2.1,2)
roundTest(4, 3,2)
roundTest(4, 3.1,2)
roundTest(-2, -1.2,2)
roundTest(-2, -2,2)
roundTest(-2, -2.1,2)
roundTest(-2, -3,2)
roundTest(-4, -3.1,2)
roundTest(-3, -3.1,1)
roundTest(-3, -3.1)

test(1, luaMod(1, 3), "luaMod(1,3)")
test(2, luaMod(2, 3), "luaMod(2,3)")
test(3, luaMod(3, 3), "luaMod(3,3)")
test(1, luaMod(4, 3), "luaMod(4,3)")
test(2, luaMod(5, 3), "luaMod(5,3)")
test(3, luaMod(6, 3), "luaMod(6,3)")
test(1, luaMod(7, 3), "luaMod(7,3)")
test(7, luaMod(7, 7), "luaMod(8,8)")
test(1, luaMod(8, 7), "luaMod(9,8)")


print "----TESTS OK"
