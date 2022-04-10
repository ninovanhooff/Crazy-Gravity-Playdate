---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by ninovanhooff.
--- DateTime: 10/04/2022 18:51
---

import "CoreLibs/object"

local random <const> = math.random
local unFlipped <const> = playdate.graphics.kImageUnflipped
local tileSize <const> = tileSize
local planePos <const> = planePos
local camPos <const> = camPos
local duration <const> = frameRate * 2
local shardDrag

class('GameExplosion').extends()

--- the amount of shards to create in both dimensions.
--- Total shard count is the square of this number
local shardingDim <const> = 6
local shardSize <const> = 24 / shardingDim -- plane is 24px in both dimensions

function GameExplosion:forShards(fun, ...)
    for _,col in ipairs(self.shards) do
        for _,item in ipairs(col) do
            fun(item, ...)
        end
    end
end

function GameExplosion:init()
    GameExplosion.super.init()
    shardDrag = (1 + drag) * 0.5
    local planeX, planeY = planePos[1]*tileSize+planePos[3], planePos[2]*tileSize+planePos[4]
    local planeSpriteOffsetX, planeSpriteOffsetY = planeRot%16*23, 391 +(boolToNum(planeRot>15))*46, 23
    self.timer = 0
    self.shards = {}
    for x = 0, shardingDim-1 do
        local shardsColumn = {}
        self.shards[x+1] = shardsColumn
        for y = 0,shardingDim-1 do
            shardsColumn[y+1] = {
                -- sprite offset x, sprite offset y,
                planeSpriteOffsetX + shardSize*x, planeSpriteOffsetY + shardSize*y,
                -- pixelPosition
                planeX + shardSize*x, planeY + shardSize*y,
                -- force x, force y
                x-shardingDim/2 + vx*0.8 + random() -0.5 ,y-shardingDim/2 + vy*0.8 +random() - 0.5
            }
        end
    end

    --self.explodeFrame = 0
    --
    --for i=0,2 do
    --    explodeI = i
    --    explodeX = random(-5,10)
    --    explodeY = random(-5,10)
    --    if Sounds then
    --        explode_sound:play()
    --    end
    --    for j = 0,14,2 do -- one exp(losion) loop
    --        explodeJ = j
    --        calcPlane()
    --        CalcGameCam()
    --        RenderGame()
    --        coroutine.yield() -- let system update the screen
    --    end
    --end
end

local function drawShard(item, camX, camY)
    sprite:draw(item[3]-camX, item[4]-camY, unFlipped, item[1], item[2], shardSize, shardSize)
end

function GameExplosion:renderShards()
    local camX, camY = camPos[1]*tileSize+camPos[3], camPos[2]*tileSize+camPos[4]
    self:forShards(drawShard, camX, camY)
    --for _,col in ipairs(self.shards) do
    --    for _,item in ipairs(col) do
    --        sprite:draw(planeX+item[3], planeY+item[4], unFlipped, item[1], item[2], shardSize, shardSize)
    --    end
    --end
end

function GameExplosion:renderExplosion()
    --sprite:draw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3]+explodeX, (planePos[2]-camPos[2])*8+planePos[4]-camPos[4]+explodeY, unFlipped, explodeJ*23, 489, 23, 23)
end

local function updateShard(shard)
    shard[3] += shard[5]
    shard[4] += shard[6]
    shard[5] *= shardDrag
    shard[6] = (shard[6]+gravity) * shardDrag
    shard[1] += random(-1,1)
    shard[2] += random(-1,1)
end

--- Updates the explosion
--- return whether the explosion is done
function GameExplosion:update()
    self:forShards(updateShard)
    self.timer = self.timer + 1
    return self.timer < duration
end

function GameExplosion:render()
    self:renderShards()
    self:renderExplosion()
end
