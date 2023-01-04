--- Some samples that can be appended to main.lua
--- Can be used to start an arbitrary screen on launch
--- For developer Quality of Life

GetOptions():apply() -- load all sounds required for game

require("lua/settings/SettingsScreen")
pushScreen(SettingsScreen())

require "lua/level-select/LevelSelectScreen"
pushScreen(LevelSelectScreen())

require("lua/end-game/EndGameScreen") -- imports and FlyTo CreditsScreen CreditsScreen
pushScreen(FlyToCreditsScreen())
pushScreen(CreditsScreen())

require("lua/video-player/VideoPlayerScreen")
pushScreen(VideoPlayerScreen(
    "video/orientation",
    function()
        return VideoPlayerScreen("video/congratulations")
        --return EndGameScreen()
    end
))
