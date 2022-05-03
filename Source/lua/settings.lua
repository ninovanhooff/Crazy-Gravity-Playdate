---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 12/03/2022 14:27
---

-- title, min, max, step, default
-- to calculate maximum speed etc, use https://www.desmos.com/calculator/x1jxjgr3jh
gameSettings = {
    {"gravity",0.1,1,0.01,val=0.12},
    {"drag",0.1,1.5,0.01,val=0.96},
    {"blowerS",0.1,1,0.05,val=0.10},
    {"magnetS",0.1,1,0.05,val=0.10},
    {"landingTol",0.5,4,0.5,val=2.5},
    {"thrustPow",0.2,0.8,0.05,val=0.4},
    {"burnRate",1,10,1,val=5},
    {"Defaults",1,{"yes","no"},val=2}
}

function ApplyGameSets()
    burnRate = gameSettings[7].val -- amount of fuel each frame
    gravity,drag = gameSettings[1].val,gameSettings[2].val --add,mult per frame!!
    landingTolerance = {gameSettings[5].val*0.5,gameSettings[5].val} -- max vx,vy
    thrustPower,turboPower = gameSettings[6].val,0.2
    blowerStrength,magnetStrength = gameSettings[3].val,gameSettings[4].val
end