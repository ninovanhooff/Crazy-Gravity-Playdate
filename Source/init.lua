---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:59
---

local sampleplayer = playdate.sound.sampleplayer
local gfx = playdate.graphics

math.randomseed(playdate.getSecondsSinceEpoch())
pi = 3.141592654
Debug = true
Sounds = true
tileSize = 8 -- refactor: probably hardcoded in a lot of places
screenWidth = playdate.display.getWidth()
screenHeight = playdate.display.getHeight()
screenWidthTiles = screenWidth / tileSize
screenHeightTiles = screenHeight / tileSize
outBufSize = 1024
print("hoi")

if Sounds then
    pickup_sound = sampleplayer.new("samples/pickup.wav")
    landing_sound = sampleplayer.new("samples/landing.wav")
    dump_sound = sampleplayer.new("samples/dump.wav")
    thrust_sound = sampleplayer.new("samples/thrust.wav")
    key_sound = sampleplayer.new("samples/key.wav")
    extra_sound = sampleplayer.new("samples/extra.wav")
    fuel_sound = sampleplayer.new("samples/fuel2.wav")
    dump_sound = sampleplayer.new("samples/dump.wav")
    explode_sound = sampleplayer.new("samples/explosion.wav")
end

sprite = gfx.image.new("images/sprite_decomposition_burkes.png") -- https://www.gingerbeardman.com/canvas-dither/
if not sprite then error("failed to load sprite") end
    --
menuFont = gfx.getFont()
if not menuFont then error("failed to load font") end

--titleBG = texture.load("titleBG.png")
--if not titleBG then error("could not load title image") end

if not highScores then
    highScores = {}
    printf("could not load highscores")
    -- table.save(highScores,"highScores.lua")
end
