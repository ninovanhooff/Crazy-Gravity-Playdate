local pendingNavigators = {}
local backStack = {}
local activeScreen

local function popScreenImmediately()
    printT("Popping off backstack:", activeScreen.className, activeScreen)
    table.remove(backStack)
    activeScreen:destroy()
end

function pushScreen(newScreen)
    table.insert(
        pendingNavigators,
        function()
            printT("Adding to backstack", newScreen.className, newScreen)
            table.insert(backStack, newScreen)
        end
    )
end

function popScreen()
    table.insert(pendingNavigators, popScreenImmediately)
end

function clearNavigationStack()
    table.insert(
        pendingNavigators,
        function()
            printT("Clearing navigationStack", activeScreen.className, activeScreen)
            while #backStack > 0 do
                activeScreen = backStack[#backStack]
                popScreenImmediately()
            end
        end
    )
end

--- internal namespace used to hide the class from external instantiation.
local navigatorNS <const> = {}

class("Navigator", {}, navigatorNS).extends()

function navigatorNS.Navigator:init()
    navigatorNS.Navigator.super.init(self)
end

function navigatorNS.Navigator:executePendingNavigators()
    if #pendingNavigators > 0 then
        for _, navigator in ipairs(pendingNavigators) do
            navigator()
        end
        pendingNavigators = {}
        local newPos = findIndexOf(backStack, activeScreen)
        if activeScreen and newPos and newPos ~= #backStack then
            -- the activeScreen was moved from the top of the stack to another position
            printT("Pausing screen", activeScreen.className, activeScreen)
            activeScreen:pause()
        end
        if #backStack < 1 then
            printT("ERROR: No active screen, adding Start Screen")
            require "lua/start/startScreen"
            table.insert(backStack, StartScreen())
        end
        activeScreen = backStack[#backStack]
        printT("Resuming screen", activeScreen.className, activeScreen)
        playdate.setCollectsGarbage(true) -- prevent permanently disabled GC by previous Screen
        activeScreen:resume()
    end
end

function navigatorNS.Navigator:updateActiveScreen()
    activeScreen:update()
end


function navigatorNS.Navigator:gameWillPause()
    printT("GameWillPause screen", activeScreen.className, activeScreen)
    activeScreen:gameWillPause()
end

function navigatorNS.Navigator:gameWillResume()
    printT("GameWillResume screen", activeScreen.className, activeScreen)
    activeScreen:gameWillResume()
end

function navigatorNS.Navigator:debugDraw()
    activeScreen:debugDraw()
end

-- return singleton
return navigatorNS.Navigator()
