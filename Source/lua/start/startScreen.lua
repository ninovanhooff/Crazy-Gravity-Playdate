---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 17/04/2022 17:10
---

import "CoreLibs/object"
import "../screen.lua"
import "startView.lua"
import "startViewModel.lua"

class("StartScreen").extends(Screen)

local renderStart <const> = RenderStart

function StartScreen:init()
    StartScreen.super.init(self)
end

function StartScreen:update()
    renderStart(self.viewModel:calcTimeStep())
end

function StartScreen:pause()
    self.viewModel:pause()
end

function StartScreen:resume()
    -- reset state entirely
    self.viewModel = StartViewModel()
end
