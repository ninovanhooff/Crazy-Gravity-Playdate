---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 01/05/2022 17:06
---

local datastoreKey <const> = "records"

--- Used when the level is skipped by the user
SKIPPED_RECORD = {9999, 9999, 9999}

records = playdate.datastore.read(datastoreKey)
if not records then
    print("could not load records, saving defaults")
    records = {}
    playdate.datastore.write(records, datastoreKey)
end

function updateRecords(levelNumber, newRecord)
    print("updating records", levelNumber)
    local entry = records[levelNumber]

    if not entry then
        records[levelNumber] = newRecord
    else
        for i, prevValue in ipairs(entry) do
            if newRecord[i] < prevValue then -- lower is better
                entry[i] = newRecord[i]
            end
        end
    end

    playdate.datastore.write(records, datastoreKey)
end

function numLevelsUnlocked()
    return math.min(#records + 1, numLevels) -- first level is available immediately
end
