---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 02/07/2022 11:11
---


local gfx <const> = playdate.graphics
local sampleplayer <const> = playdate.sound.sampleplayer

class("ResourceLoader").extends()

--- use ResourceLoader:getSound(path)
local cachedSamplePlayers <const> = {}

--- use ResourceLoader:getImage(path)
local cachedImages <const> = {}

-- get or create the global singleton
function GetResourceLoader()
    if ResourceLoader.instance then
        return ResourceLoader.instance
    else
        ResourceLoader.instance = ResourceLoader()
        return ResourceLoader.instance
    end
end


function ResourceLoader:init()
    ResourceLoader.super.init(self)
    self.soundVolume = 1.0
    self.graphicsStyle = nil
    self.soundStyle = nil
end

function ResourceLoader:loadBG(newBG)
    if newBG == gameBgColor then
        return
    end

    gameBgColor = newBG
    gameFgColor = (newBG == gfx.kColorBlack and gfx.kColorWhite) or gfx.kColorBlack
    local tooltips <const> = Tooltips
    if tooltips then
        Tooltips.preRenderTooltips()
    end
end

function ResourceLoader:loadGraphicsStyle(graphicsStyle, onlyStartAssets)
    if self.graphicsStyle == graphicsStyle then
        printf("graphicsStyle already applied")
        return
    end

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
    self.graphicsStyle = graphicsStyle
end

function ResourceLoader:loadSounds(audioStyle, onlyStartAssets)
    -- common sounds
    if not thrust_sound then
        thrust_sound = self:getSound("sounds/thrust.wav")
    end
    if not swish_sound_reverse then
        swish_sound_reverse = self:getSound("sounds/hollow-swish-airy-short-reverse.wav")
    end

    ui_confirm = self:getSound("sounds/ui_confirm.wav")

    if onlyStartAssets then
        return
    end

    ui_cancel = self:getSound("sounds/ui_cancel.wav")
    explode_sound = self:getSound("sounds/explosion.wav")
    unlock_sound = self:getSound("sounds/unlock.wav")
    unlock_sound_denied = self:getSound("sounds/unlock_denied.wav")
    landing_sound = self:getSound("sounds/landing.wav")
    soundManager:loadGameSounds()

    -- style-specific sounds
    if audioStyle == "classic" then
        pickup_sound = self:getSound("sounds/classic/pickup.wav")
        key_sound = self:getSound("sounds/classic/key.wav")
        local extras_player = self:getSound("sounds/classic/extra.wav")
        extra_sounds = {
            extras_player, extras_player, extras_player
        }
        fuel_sound = self:getSound("sounds/classic/fuel.wav")
        dump_sound = self:getSound("sounds/classic/dump.wav")
    else
        pickup_sound = self:getSound("sounds/pickup.wav")
        dump_sound = self:getSound("sounds/dump.wav")
        key_sound = self:getSound("sounds/key.wav")
        extra_sounds = {
            self:getSound("sounds/extra_turbo.wav"),
            self:getSound("sounds/extra_life.wav"),
            self:getSound("sounds/extra_cargo.wav"),
        }
        fuel_sound = self:getSound("sounds/fuel.wav")
    end
    self:setSoundVolume(self.soundVolume)
    self.audioStyle = audioStyle
end

function ResourceLoader:getMonoFont()
    if not ResourceLoader.monoFont then
        ResourceLoader.monoFont = gfx.font.new("fonts/Roobert/Roobert-9-Mono-Condensed")
    end
    return ResourceLoader.monoFont
end

function ResourceLoader:getDotFont()
    if not ResourceLoader.dotFont then
        ResourceLoader.dotFont = gfx.font.new("fonts/Edit Undo/edit-undo.dot-brk-50")
    end
    return ResourceLoader.dotFont
end

function ResourceLoader:getSmallFont()
    if not ResourceLoader.smallFont then
        ResourceLoader.smallFont = gfx.font.new("fonts/Roobert/Roobert-10-Bold")
    end
    return ResourceLoader.smallFont
end

function ResourceLoader:getLcdFont()
    if not ResourceLoader.lcdFont then
        ResourceLoader.lcdFont = gfx.font.new("fonts/digital-7-mono/digital-7-mono-20")
    end
    return ResourceLoader.lcdFont
end

function ResourceLoader:getSound(pathWithExtension)
    if not cachedSamplePlayers[pathWithExtension] then
        cachedSamplePlayers[pathWithExtension] = sampleplayer.new(pathWithExtension)
        cachedSamplePlayers[pathWithExtension]:setVolume(self.soundVolume)
    end
    return cachedSamplePlayers[pathWithExtension]
end

--- volume range 0.0-1.0
function ResourceLoader:setSoundVolume(volume)
    self.soundVolume = volume
    for _,item in pairs(cachedSamplePlayers) do
        item:setVolume(volume)
    end
    soundManager:setVolume(volume)
    Sounds = volume > 0.0
end

--- volume range 0.0-1.0. If 0.0, volume is not adjusted, but music is stopped
function ResourceLoader:setMusicVolume(volume)
    musicManager:setVolume(volume)
    if volume == 0.0 then
        musicManager:stop()
    else
        musicManager:start()
    end
end

function ResourceLoader:getImage(pathWithExtension)
    if not cachedImages[pathWithExtension] then
        cachedImages[pathWithExtension] = gfx.image.new(pathWithExtension)
    end
    return cachedImages[pathWithExtension]
end
