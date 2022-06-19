---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:59
---

import "settings.lua"
import "records.lua"


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
--- the amount of timesteps to calculate before starting the game. Allows cannons to fir a few shots
preCalcFrames = 60
outBufSize = 1024
numLevels = 10
currentLevel = 3
extras = {0,0,0} -- See GameViewModel:ResetGame()
planePos = {}
planeSize = 24
camPos = {}
ApplyGameSets()

print("hoi")

sinThrustT= {}
for i = 0,23 do
    sinThrustT[i] = math.sin(-i/12*pi)
end

cosThrustT= {}
for i = 0,23 do
    cosThrustT[i] = math.cos(-i/12*pi)
end

if Sounds then
    pickup_sound = sampleplayer.new("sounds/pickup.wav")
    landing_sound = sampleplayer.new("sounds/landing.wav")
    dump_sound = sampleplayer.new("sounds/dump.wav")
    thrust_sound = sampleplayer.new("sounds/thrust.wav")
    key_sound = sampleplayer.new("sounds/key.wav")
    extra_sounds = {
        sampleplayer.new("sounds/extra_turbo.wav"),
        sampleplayer.new("sounds/extra_life.wav"),
        sampleplayer.new("sounds/extra_cargo.wav"),
    }
    fuel_sound = sampleplayer.new("sounds/fuel.wav")
    dump_sound = sampleplayer.new("sounds/dump.wav")
    explode_sound = sampleplayer.new("sounds/explosion.wav")
    unlock_sound = sampleplayer.new("sounds/unlock.wav")
end

gfx.setColor(gfx.kColorBlack)

sprite = gfx.image.new("images/sprite.png") -- https://www.gingerbeardman.com/canvas-dither/
if not sprite then error("failed to load sprite") end

defaultFont = gfx.font.new("fonts/Asheville Sans 14 Bold/Asheville-Sans-14-Bold")
monoFont = gfx.font.new("fonts/Marble Madness")
dotFont = gfx.font.new("fonts/Edit Undo/edit-undo.dot-brk-50")

if not dotFont then error("could not load dotFont") end
