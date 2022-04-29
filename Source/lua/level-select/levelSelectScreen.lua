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
    levelSelectViewModel = LevelSelectViewModel()
    levelSelectView = LevelSelectView(levelSelectViewModel)
end

function LevelSelectScreen:update()
    levelSelectViewModel:update()
    levelSelectView:render(levelSelectViewModel)
end
