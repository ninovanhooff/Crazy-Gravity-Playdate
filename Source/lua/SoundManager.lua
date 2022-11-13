---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 13/11/2022 16:11
---

local min <const> = math.min
local random <const> = math.random
local sampleplayer <const> = playdate.sound.sampleplayer
local distanceToPoint <const> = playdate.geometry.distanceToPoint
local halfWidthTiles <const> = math.ceil(gameWidthTiles*0.5)
local halfHeightTiles <const> = math.ceil(gameHeightTiles*0.5)
--- distance in tiles at which a sound cannot be heard anymore
local SOUND_DISTANCE_INFINITE <const> = 50

class("SoundManager").extends()

function SoundManager:init()
    self.volume = 1.0
end

function SoundManager:loadGameSounds()
    self.barrier_sound = sampleplayer.new("sounds/barrier.wav")
    self.blower_sound = sampleplayer.new("sounds/blower.wav")
    self.gameSoundsLoaded = true
end

if not soundManager then
    soundManager = SoundManager()
else
    print("WARN sound manager initiated multiple times")
end

local function playRandomPitch(player, times)
    player:play(times, 0.98 + random() * 0.04)
end

function SoundManager:setVolume(volume)
    self.volume = volume
    if volume == 0.0 then
        self.barrier_sound:stop()
        self.blower_sound:stop()
    end
end

function SoundManager:notifySoundCalcStart()
    self.minBarrierSoundDistance = SOUND_DISTANCE_INFINITE
    self.minBlowerSoundDistance = SOUND_DISTANCE_INFINITE
end

function SoundManager:notifySoundCalcEnd()
    if self.volume == 0.0 or not self.gameSoundsLoaded then
        return
    end
    if self.minBarrierSoundDistance < SOUND_DISTANCE_INFINITE then
        local volume = self.volume*(1.0-(self.minBarrierSoundDistance/SOUND_DISTANCE_INFINITE))
        self.barrier_sound:setVolume(volume)
        if not self.barrier_sound:isPlaying() then
            playRandomPitch(self.barrier_sound, 0)
        end
    elseif self.barrier_sound:isPlaying() then
        self.barrier_sound:stop()
    end

    if self.minBlowerSoundDistance < SOUND_DISTANCE_INFINITE then
        local volume = self.volume*(1.0-(self.minBlowerSoundDistance/SOUND_DISTANCE_INFINITE))
        self.blower_sound:setVolume(volume)
        if not self.blower_sound:isPlaying() then
            playRandomPitch(self.blower_sound, 0)
        end
    elseif self.blower_sound:isPlaying() then
        self.blower_sound:stop()
    end
end

function SoundManager:addSoundForItem(item)
    local distance = distanceToPoint(item.x, item.y, camPos[1]+halfWidthTiles, camPos[2]+halfHeightTiles)
    if item.sType == 14 or item.sType == 15 then -- barrier or 1way
        self.minBarrierSoundDistance = min(self.minBarrierSoundDistance, distance)
    elseif item.sType == 9 or item.sType == 11 then -- fan or rotator
        self.minBlowerSoundDistance = min(self.minBlowerSoundDistance, distance)
    end
end
