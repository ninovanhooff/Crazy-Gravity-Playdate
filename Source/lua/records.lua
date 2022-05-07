---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 01/05/2022 17:06
---

local datastoreKey <const> = "records"

records = playdate.datastore.read(datastoreKey)
if not records then
    print("could not load records, saving defaults")
    records = {}
    playdate.datastore.write(records, datastoreKey)
end

function updateRecords(levelPath, newRecord)
    print("updating records", levelPath)
    local entry = records[levelPath]

    if not entry then
        records[levelPath] = newRecord
    else
        for i, prevValue in ipairs(entry) do
            if newRecord[i] < prevValue then -- lower is better
                entry[i] = newRecord[i]
            end
        end
    end

    playdate.datastore.write(records, datastoreKey)
end
