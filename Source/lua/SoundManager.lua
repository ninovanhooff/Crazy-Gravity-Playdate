---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 13/11/2022 16:11
---

local min <const> = math.min
local random <const> = math.random
local gfx <const> = playdate.graphics
local sampleplayer <const> = playdate.sound.sampleplayer
local distanceToPoint <const> = playdate.geometry.distanceToPoint
--- distance in tiles at which a sound cannot be heard anymore
local SOUND_DISTANCE_INFINITE <const> = 40
--- this animator is just a means to use the easing function to calculate sound falloff
local falloff <const> = gfx.animator.new(SOUND_DISTANCE_INFINITE, 1, 0, playdate.easingFunctions.inCirc)

class("SoundManager").extends()

function SoundManager:init()
    self.volume = 1.0
    self.enabled = true
end

local function forSounds(self, func)
    if not self.enabled then return end

    if self.volume == 0.0 or not self.sounds then return end

    for _, sound in pairs(self.sounds) do
        func(sound)
    end
end

local function loadSound(path)
    return {
        ["player"] = sampleplayer.new(path),
        ["minDistance"] = SOUND_DISTANCE_INFINITE
    }
end

local function playRandomPitch(player, times)
    player:play(times, player:getRate() + random() * 0.04)
end

function SoundManager:loadGameSounds()
    self.sounds = {
        ["barrier"] = loadSound("sounds/barrier.wav"),
        ["magnet"] = loadSound("sounds/electronic_hum.wav"),
        ["blower"] = loadSound("sounds/blower.wav"),
    }
    self.sounds.barrier.player:setRate(0.5)
end

if not soundManager then
    soundManager = SoundManager()
else
    print("WARN sound manager initiated multiple times")
end



function SoundManager:stop()
    forSounds(self, function(item)
        item.player:stop()
    end)
end

function SoundManager:setVolume(volume)
    self.volume = volume
    if volume == 0.0 then
        self:stop()
    end
end

function SoundManager:notifySoundCalcStart()
    forSounds(self, function(item)
        item.minDistance = SOUND_DISTANCE_INFINITE
    end)
end

function SoundManager:notifySoundCalcEnd()
    forSounds(self, function(item)
        if item.minDistance < SOUND_DISTANCE_INFINITE then
            local volume = self.volume*falloff:valueAtTime(item.minDistance)
            item.player:setVolume(volume)
            if not item.player:isPlaying() then
                playRandomPitch(item.player, 0)
            end
        elseif item.player:isPlaying() then
            item.player:stop()
        end
    end)
end

function SoundManager:soundForSpecial(item)
    if item.sType == 14 or item.sType == 15 then -- barrier or 1way
        return self.sounds.barrier
    elseif item.sType == 9 or item.sType == 11 then -- blower or rotator
        return self.sounds.blower
    elseif item.sType == 10 then -- magnet
        return self.sounds.magnet
    else
        return nil -- many specials are silent
    end
end

function SoundManager:addSoundForItem(item)
    if not self.sounds or not self.enabled then return end
    local distance = distanceToPoint(item.x + item.w/2, item.y+item.h/2, planePos[1], planePos[2])
    local sound = self:soundForSpecial(item)
    if sound then
        sound.minDistance = min(sound.minDistance, distance)
    end
end
