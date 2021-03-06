---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 24/04/2022 22:29
---

import "CoreLibs/object"
import "../screen.lua"
import "levelSelectView.lua"
import "levelSelectViewModel.lua"

class("LevelSelectScreen").extends(Screen)

local levelSelectView, levelSelectViewModel

function LevelSelectScreen:init()
    LevelSelectScreen.super.init(self)
    levelSelectViewModel = LevelSelectViewModel()
end

function LevelSelectScreen:pause()
    levelSelectViewModel:pause()
end

function LevelSelectScreen:resume()
    levelSelectViewModel:resume()
    levelSelectView = LevelSelectView(levelSelectViewModel)
end

function LevelSelectScreen:update()
    levelSelectView:render(levelSelectViewModel)
    levelSelectViewModel:update()
end
