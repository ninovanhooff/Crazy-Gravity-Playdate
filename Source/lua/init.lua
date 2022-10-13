---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 11/03/2022 16:59
---

import "MusicManager"
import "input/InputManager"
import "settings/physicsSettings"
import "settings/options"
import "records"
import "levelSuggestion"
import "challenges"

if playdate.isSimulator then
    require "lua/unittests"
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
dotFont = gfx.font.new("fonts/Edit Undo/edit-undo.dot-brk-50") -- todo rename to dotFont50
--dotFont25 = gfx.font.new("fonts/Edit Undo/edit-undo.dot-horizontal-25")
dotFont25 = gfx.font.new("fonts/Edit Undo/edit-undo-dot-horiz-outlined-25")
if not dotFont25 then error("could not load dotFont25") end
printT("Before start options apply")
Options():apply(true)
printT("After start options apply")
