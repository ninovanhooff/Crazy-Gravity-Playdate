---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:59
---

-- tooltips imported at the bottom, requires font
import "MusicManager"
import "SoundManager"
import "input/InputManager"
import "settings/physicsSettings"
import "settings/options"
import "records"
import "levelSuggestion"
import "challenges"

if playdate.isSimulator and playdate.file.exists("lua/unittests.pdz") then
    require "lua/unittests"
end

local gfx = playdate.graphics

math.randomseed(playdate.getSecondsSinceEpoch())
pi = 3.141592654
Sounds = true
screenWidth, screenHeight = playdate.display.getSize()
hudY = 224
tileSize = 8 -- refactor: probably hardcoded in a lot of places
gameBgColor = gfx.kColorBlack
gameFgColor = gfx.kColorWhite
gameWidthTiles = math.ceil(screenWidth / tileSize)
gameHeightTiles = math.ceil(hudY / tileSize)
--- The frameRate for menu screens and the timebase for game logic. Game may run slower, see gameFps
frameRate = 30
playdate.display.setRefreshRate(frameRate)
--- The amount of frames per second the game runs at. When frameRate is 30 and gameFps is 15, the game runs at half speed
gameFps = frameRate
currentLevel = 1
extras = {0,0,0} -- See GameViewModel:ResetGame()
planePos = {}
planeSize = 24
camPos = {}



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
monoFont = gfx.font.new("fonts/Roobert/Roobert-9-Mono-Condensed")
smallFont = gfx.font.new("fonts/Roobert/Roobert-10-Bold")
dotFont = gfx.font.new("fonts/Edit Undo/edit-undo.dot-brk-50")

import "common/tooltip"

GetOptions():apply(true)
