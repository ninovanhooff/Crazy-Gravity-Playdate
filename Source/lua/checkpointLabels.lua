local pickRandom <const> = pickRandom
local random <const> = math.random

local checkpointWaitingLabels <const> = {
    "Back so soon?", "Back again?", "Papers, please", "You look familiar", "Synthesizing Gravity",
    "Sit...", "Gimme five!", "Take five!", "Planet Express?", "Lunch order?", "I wanted to say...",
    "Delivery for ME?", "Pizza? I didn't order...", "What are you doing here?",
    "Reticulating splines...", "Max confusion!", "Pit stop?", "Brake engaged",
    "Hold yer horses!", "3,2,1...", "Tired?", "Freeze!", "What now?", "Thrusters deactivated",
    "Tag!", "Out of ammo?", "Chill pill?", "Thirsty?", "Bedtime?", "Timeout!",
    "Fixing your cape?", "No smile?", "Put me in, coach!",
    "Stop! In the Name of Love", "Gimme now!", "Come here often?", "Oven still on?", "WHAT?",
    "WAZZZUP?", "Come here often?", "It's Groundhog Day..", "Knock knock?", "Live long", "Toilet?!",
    "Hi!", "Fuel?", "Meow!", "Whoosh!", "Harder? Better?", "Coffee is brewing...", "Boldly going"
}
local checkpointDoneLabels <const> = {
    "Let's go!", "Safe and sound!", "Keep going!", "Nice!", "See ya!", "You can do it!",
    "Good boy!", "And away you go!", "I'm having Turkey", "No hug?", "How nice!",
    "With chilli, yummy!", "Is that you, Fry?", "Where is Bender?", "Time to go!", "All good!",
    "Seatbelts on!", "Giddy up!", "Let's jam!", "You've got this!", "Unfreeze!", "Back to work!",
    "Scram!", "Gotta jet!", "You're it!", "Locked and loaded!", "Stay calm!", "Refreshed!",
    "One more run!", "Start the clock!",
    "Up, up and away!", "Why so serious?", "Ready to play!", "Think it over!", "Lookin' good!",
    "Didn't think so!", "It's on fire!", "WHAAAT?", "WAZZZUUUUP?!?!", "Didn't think so!",
    "I know who you are!", "..again?", ".. and get rich", "Customers only!", "Bye!", "Woof!",
    "Anytime!", "Faster! Stronger!", "Caffeine injected", "Away already?"
}

local fixedPairs <const> = {
    { "Lowest prices!", "..are just the beginning!"},
    { "Don't stop believin'", "Hold on to that Feelin'"},
    { "Rewards card?", "Paper or plastic?" },
    { "Marco?" , "Polo!" },
    { "World record?" , "Nope. Too slow." },
    { "Don't get cooked..." , "And stay off the hook!" },
    { "Berries?" , "And Cream!" },
    { "More Espresso?" , "Less Depresso!" },
    { "Heeeere's", "Johnny!" },
    { "So long!", "And thanks for all the fish!" },
    { "Nobody here...", "..but us chickens" },
    { "It's over...", "9000 !?!" },
    { "You know Bagu?", "I am error" },
    { "You've got a", "pizza my heart" },
    { "To the window?", "To the wall!" },
    { "Been a while", "Crocodile!" },
    { "See ya later", "Alligator" }
}

local fixedPairChance = #fixedPairs / #checkpointWaitingLabels
if fixedPairChance > 1 then fixedPairChance = 1/fixedPairChance end
print("fixedpairchance", fixedPairChance)

local function getCheckpointLabelsPair()
    if random() < fixedPairChance then
        local pair = pickRandom(fixedPairs)
        return table.unpack(pair)
    end
    return pickRandom(checkpointWaitingLabels), pickRandom(checkpointDoneLabels)
end

return getCheckpointLabelsPair
