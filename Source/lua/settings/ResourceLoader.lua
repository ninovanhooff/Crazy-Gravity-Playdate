---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 02/07/2022 11:11
---
import "CoreLibs/utilities/sampler"
import "CoreLibs/object"
import "../MusicManager.lua"

local gfx <const> = playdate.graphics
local sampleplayer <const> = playdate.sound.sampleplayer

class("ResourceLoader").extends()

function ResourceLoader:init()
    ResourceLoader.super.init()
    self.soundVolume = 1.0
end

function ResourceLoader:loadBG(newBG)
    print("Changing background to ", newBG)
    if newBG == "white" then
        gameBgColor = gfx.kColorWhite
    elseif newBG == "win95" then
        gameBgColor = gfx.kColorClear
    else
        gameBgColor = gfx.kColorBlack
    end
end

function ResourceLoader:loadGraphicsStyle(graphicsStyle)
    print("graphicsStyle", graphicsStyle)
    local spritePath <const> = "images/sprite_" .. graphicsStyle ..".png"
    local bricksPath <const> = "images/bricks_" .. graphicsStyle ..".png"
    local spriteError
    if sprite then
        spriteError = sprite:load(spritePath)
    else
        sprite, spriteError = gfx.image.new(spritePath)
    end
    if not sprite then error("failed to load sprite for style " .. graphicsStyle ..": "..spriteError) end

    local bricksError
    if bricksImg then
        bricksError = bricksImg:load(bricksPath)
    else
        bricksImg, bricksError = gfx.image.new(bricksPath)
    end
    if not bricksImg then error("failed to load bricks image for style " .. graphicsStyle .. ": ".. bricksError) end
end

function ResourceLoader:loadSounds(useClassic)
    print("audioStyle classic?",useClassic)
    -- common sounds
    thrust_sound = sampleplayer.new("sounds/thrust.wav")
    explode_sound = sampleplayer.new("sounds/explosion.wav")
    unlock_sound = sampleplayer.new("sounds/unlock.wav")
    landing_sound = sampleplayer.new("sounds/landing.wav")
    swish_sound_reverse = sampleplayer.new("sounds/hollow-swish-airy-short-reverse.wav")

    -- style-specific sounds
    if useClassic then
        pickup_sound = sampleplayer.new("sounds/classic/pickup.wav")
        key_sound = sampleplayer.new("sounds/classic/key.wav")
        local extras_player = sampleplayer.new(playdate.sound.sample.new("sounds/classic/extra.wav"))
        extra_sounds = {
            extras_player, extras_player, extras_player
        }
        fuel_sound = sampleplayer.new("sounds/classic/fuel.wav")
        dump_sound = sampleplayer.new("sounds/classic/dump.wav")
    else
        pickup_sound = sampleplayer.new("sounds/pickup.wav")
        dump_sound = sampleplayer.new("sounds/dump.wav")
        key_sound = sampleplayer.new("sounds/key.wav")
        extra_sounds = {
            sampleplayer.new("sounds/extra_turbo.wav"),
            sampleplayer.new("sounds/extra_life.wav"),
            sampleplayer.new("sounds/extra_cargo.wav"),
        }
        fuel_sound = sampleplayer.new("sounds/fuel.wav")
    end
    self:setSoundVolume(self.soundVolume)
end

local function setVolume(self, volume, ...)
    self.soundVolume = volume
    for _,item in ipairs({ ... }) do
        item:setVolume(volume)
    end
end

--- volume range 0.0-1.0
function ResourceLoader:setSoundVolume(volume)
    Sounds = volume > 0.0
    print("set volume", volume)
    if Sounds then
        setVolume(self, volume, thrust_sound, explode_sound, unlock_sound, pickup_sound, landing_sound,
            key_sound, extra_sounds[1], extra_sounds[2], extra_sounds[3], fuel_sound, dump_sound)
    end
end

--- volume range 0.0-1.0. If 0.0, volume is not adjusted, but music is stopped
function ResourceLoader:setMusicVolume(volume)
    if volume == 0.0 then
        musicManager:stop()
    else
        musicManager:setVolume(volume)
    end
end
