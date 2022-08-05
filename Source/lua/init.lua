---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:59
---
Debug = true -- no commit


import "input/InputManager.lua"
import "settings/physicsSettings.lua"
import "settings/options.lua"
import "records.lua"
import "CoreLibs/utilities/sampler"
if Debug then
    import "unittests.lua"
end

local gfx = playdate.graphics

math.randomseed(playdate.getSecondsSinceEpoch())
pi = 3.141592654
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
currentLevel = 3
extras = {0,0,0} -- See GameViewModel:ResetGame()
planePos = {}
planeSize = 24
camPos = {}

print("hoi")

sinThrustT= {}
for i = 0,23 do
    sinThrustT[i] = math.sin(-i/12*pi)
end

cosThrustT= {}
for i = 0,23 do
    cosThrustT[i] = math.cos(-i/12*pi)
end

gfx.setColor(gfx.kColorBlack)

-- workaround to use the playdate button glyphs from the system font. Example usage: "_Ⓐ_" will print the expected button symbol
-- https://devforum.play.date/t/using-glyphs-illustrated-in-designing-for-playdate/3678/7
local originalSystemFont = playdate.graphics.getSystemFont()
gfx.setFont( originalSystemFont, playdate.graphics.font.kVariantItalic )
gfx.setFont(playdate.graphics.getSystemFont(playdate.graphics.font.kVariantBold))
monoFont = gfx.font.new("fonts/Marble Madness")
dotFont = gfx.font.new("fonts/Edit Undo/edit-undo.dot-brk-50")
if not dotFont then error("could not load dotFont") end

Options():apply()
