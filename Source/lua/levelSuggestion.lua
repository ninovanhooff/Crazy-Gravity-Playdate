---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 07/08/2022 22:52
---

--- returns challenge index in [challenges] to attempt next. Returns nil if all challenges were achieved
function firstUnCompletedChallenge(levelNum)
    local levelRecords = records[levelNum]
    if not levelRecords then
        return 1 -- first challenge
    end
    local challenges = getChallengesForPath(levelPath(levelNum))
    for challengeIdx, score in ipairs(challenges) do
        if levelRecords[challengeIdx] > score then
            -- challenge not completed
            return challengeIdx
        end
    end

    -- this code is probably only reached when the player has completed the game
    return nil
end
