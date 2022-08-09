---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 29/04/2022 11:20
---

import "CoreLibs/object"
import "CoreLibs/timer"
import "../util.lua"
import "challenges.lua"
import "lua/gameScreen.lua"
import "../gameHUD.lua"

local numChallenges <const> = numChallenges
local levelNames <const> = levelNames
local justPressed <const> = playdate.buttonJustPressed
local justReleased <const> = playdate.buttonJustReleased
local buttonDown <const> = playdate.kButtonDown
local buttonUp <const> = playdate.kButtonUp
local buttonLeft <const> = playdate.kButtonLeft
local buttonRight <const> = playdate.kButtonRight
local buttonA <const> = playdate.kButtonA
local buttonB <const> = playdate.kButtonB

local ceil <const> = math.ceil

class("LevelSelectViewModel").extends()

function LevelSelectViewModel:init()
    LevelSelectViewModel.super.init()
    self.lastUnlocked = numLevelsUnlocked()
    --- the level for which an unlock animation should be played
    self.newUnlock = nil
    self.menuOptions = {}
    for i = 1,numLevels do
        self.menuOptions[i] = {
            title = levelNames[i],
            challenges = getChallengesForPath(levelPath(i)),
            levelNumber = i,
            -- scores added on resume
        }
    end
    self.selectedIdx = numLevelsUnlocked()
    self.selectedChallenge = firstUnCompletedChallenge(self.selectedIdx) or 1
end

function LevelSelectViewModel:resume()
    local numLevelsUnlocked = numLevelsUnlocked()
    print("numLevelsUnlocked", numLevelsUnlocked)
    if self.lastUnlocked ~= numLevelsUnlocked then
        self.lastUnlocked = numLevelsUnlocked
        self.newUnlock = numLevelsUnlocked
    end
    for i = 1,numLevels do
        local curOptions = self.menuOptions[i]
        local rawScores = records[i]
        local achievements = {}
        if rawScores then
            -- formatting for display
            curOptions.scores = {
                ceil(rawScores[1]),
                ceil(rawScores[2]),
                rawScores[3]
            }
            for j, score in ipairs(rawScores) do
                achievements[j] = score <= curOptions.challenges[j]
            end
        end
        curOptions.achievements = achievements
        curOptions.unlocked = numLevelsUnlocked >= i
    end
end

function LevelSelectViewModel:pause()
    self.newUnlock = nil
end

function LevelSelectViewModel:finish()
    if self.keyTimer then
        self.keyTimer:remove()
    end
    popScreen()
end

--- returns true when finished
function LevelSelectViewModel:update()
    if justPressed(buttonDown) then
        local function timerCallback()
            if self.selectedIdx < #self.menuOptions and (numLevelsUnlocked() >= self.selectedIdx + 1 or Debug) then
                self.selectedIdx = self.selectedIdx + 1
                self.selectedChallenge = firstUnCompletedChallenge(self.selectedIdx) or 1
            end
        end
        self.keyTimer = playdate.timer.keyRepeatTimer(timerCallback)
    elseif justPressed(buttonUp) then
        local function timerCallback()
            if self.selectedIdx > 1 then
                self.selectedIdx = self.selectedIdx - 1
                self.selectedChallenge = firstUnCompletedChallenge(self.selectedIdx) or 1
            end
        end
        self.keyTimer = playdate.timer.keyRepeatTimer(timerCallback)
    elseif justReleased(buttonDown | buttonUp) then
        if self.keyTimer then
            self.keyTimer:remove()
        end
    elseif justPressed(buttonLeft) then
        self.selectedChallenge = clamp(self.selectedChallenge-1, 1, numChallenges)
    elseif justPressed(buttonRight) then
        self.selectedChallenge = clamp(self.selectedChallenge+1, 1, numChallenges)
    elseif justPressed(buttonA) then
        currentLevel = self.selectedIdx
        pushScreen(
            GameScreen(levelPath(), self.selectedChallenge)
        )
    elseif justPressed(buttonB) then
        self:finish()
    end
end

function LevelSelectViewModel:selectedOption()
    return self.menuOptions[self.selectedIdx]
end
