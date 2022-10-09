---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 05/08/2022 11:15
---

local function test(expected, actual, description)
    print(description)
    if expected ~= actual then
        error(string.format("Expected %s, got %s", expected, actual))
    end
end

print "----TESTS"

test(0, roundToNearest(0,2), "roundToNearest(0,2)")
test(2, roundToNearest(1.2,2), "roundToNearest(1.2,2)")
test(2, roundToNearest(2,2), "roundToNearest(2,2)")
test(2, roundToNearest(2.1,2), "roundToNearest(2.1,2)")
test(4, roundToNearest(3,2), "roundToNearest(3,2)")
test(4, roundToNearest(3.1,2), "roundToNearest(3.1,2)")
test(-2, roundToNearest(-1.2,2), "roundToNearest(1.2,2)")
test(-2, roundToNearest(-2,2), "roundToNearest(2,2)")
test(-2, roundToNearest(-2.1,2), "roundToNearest(2.1,2)")
test(-2, roundToNearest(-3,2), "roundToNearest(3,2)")
test(-4, roundToNearest(-3.1,2), "roundToNearest(3.1,2)")

test(1, luaMod(0, 3), "luaMod(0,3)")
test(1, luaMod(1, 3), "luaMod(1,3)")
test(2, luaMod(2, 3), "luaMod(2,3)")
test(1, luaMod(3, 3), "luaMod(3,3)")
test(1, luaMod(4, 3), "luaMod(4,3)")


print "----TESTS OK"
