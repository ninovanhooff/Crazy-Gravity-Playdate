--- Achievement targets.
--- key = file path
--- value = {completion time, fuel spent, lives lost}
--- achievements are unlocked / completed when the user achieves a lower record, ie.
--- when the challenge is fuel 1200; the achievement is awarded when the user completes the level
--- with 1199 or less spent fuel

numChallenges = 3

challengeNames = {"Time Attack", "Fuel Saver", "Survivor"}

--- used for level paths not found in challenges below, like user generated levels, CREDITS etc
local defaultChallenges = {235, 1200, 0}

local challenges = {
    ["levels/LEVEL01"] = {10, 75, 0},
    ["levels/LEVEL02"] = {45, 300, 0},
    ["levels/LEVEL03"] = {40, 250, 0},
    ["levels/LEVEL04"] = {55, 300, 0},
    ["levels/LEVEL05"] = {75, 500, 0},
    ["levels/LEVEL06"] = {130, 900, 0},
    ["levels/LEVEL07"] = {250, 1550, 0},
    ["levels/LEVEL08"] = {100, 550, 0},
    ["levels/LEVEL09"] = {250, 1200, 0},
    ["levels/LEVEL10"] = {450, 1200, 0},
    ["levels/LEVEL11"] = {200, 1200, 0},
    ["levels/LEVEL12"] = {130, 1000, 0},
    ["levels/LEVEL13"] = {300, 2200, 0},
    ["levels/LEVEL14"] = {310, 1600, 0},
    ["levels/LEVEL15"] = {350, 2000, 0},
    ["levels/LEVEL16"] = {425, 2200, 0},
    ["levels/LEVEL17"] = {235, 1200, 0},
    ["levels/LEVEL18"] = {450, 2000, 0},
    ["levels/LEVEL19"] = {260, 1500, 0},
    ["levels/LEVEL20"] = {320, 1800, 0},
    ["levels/LEVEL21"] = {400, 2200, 0},
    ["levels/LEVEL22"] = {235, 1300, 0},
    ["levels/LEVEL23"] = {335, 1800, 0},
    ["levels/LEVEL24"] = {400, 2100, 0},
    ["levels/LEVEL25"] = {80, 400, 0},
}


function getChallengesForPath(path)
    return challenges[path] or defaultChallenges
end
