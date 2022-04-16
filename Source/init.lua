---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:59
---

local sampleplayer = playdate.sound.sampleplayer
local gfx = playdate.graphics

math.randomseed(playdate.getSecondsSinceEpoch())
pi = 3.141592654
Debug = false
Sounds = true
screenWidth = playdate.display.getWidth()
screenHeight = playdate.display.getHeight()
hudY = 224
tileSize = 8 -- refactor: probably hardcoded in a lot of places
gameBgColor = gfx.kColorBlack
gameWidthTiles = math.ceil(screenWidth / tileSize)
gameHeightTiles = math.ceil(hudY / tileSize)
frameRate = 30
outBufSize = 1024
numLevels = 10
currentLevel = 1
kill = 0 -- game ended?
extras = {0,0,0} -- See GameViewModel:ResetGame()
planePos = {}
camPos = {}
print("hoi")

if Sounds then
    pickup_sound = sampleplayer.new("sounds/pickup.wav")
    landing_sound = sampleplayer.new("sounds/landing.wav")
    dump_sound = sampleplayer.new("sounds/dump.wav")
    thrust_sound = sampleplayer.new("sounds/thrust.wav")
    key_sound = sampleplayer.new("sounds/key.wav")
    extra_sound = sampleplayer.new("sounds/extra.wav")
    fuel_sound = sampleplayer.new("sounds/fuel2.wav")
    dump_sound = sampleplayer.new("sounds/dump.wav")
    explode_sound = sampleplayer.new("sounds/explosion.wav")
end

gfx.setColor(gfx.kColorBlack)

sprite = gfx.image.new("images/sprite_bob.png") -- https://www.gingerbeardman.com/canvas-dither/
if not sprite then error("failed to load sprite") end

defaultFont = gfx.font.new("fonts/Asheville Sans 14 Bold/Asheville-Sans-14-Bold")
monoFont = gfx.font.new("fonts/Marble Madness")

--titleBG = texture.load("titleBG.png")
--if not titleBG then error("could not load title image") end

if not highScores then
    highScores = {}
    printf("could not load highscores")
    -- table.save(highScores,"highScores.lua")
end
