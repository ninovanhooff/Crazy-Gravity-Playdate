import "CoreLibs/object"

--- the amount of shards to create in both dimensions.
--- Total shard count is the square of this number
local shardingDim <const> = 9
local shardSize <const> = 32 / shardingDim -- lock is 32 px in both dimension

local gfx <const> = playdate.graphics
local random <const> = math.random
local unFlipped <const> = playdate.graphics.kImageUnflipped
local tileSize <const> = tileSize
local planeX, planeY = 20,20
local planeSpriteOffsetX, planeSpriteOffsetY = 0,64
local vx, vy = 2,2
local camPos <const> = camPos
local frameRate <const> = frameRate
local duration <const> = frameRate * 2
local shardDrag

class('LockExplosion').extends()

--- return cam position as x,y
local function getCam()
    return 0,0
end

function LockExplosion:init()
    LockExplosion.super.init()
    shardDrag = (1 + drag) * 0.5
    
    self.blastShards = {}
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
            if random(1, shardingDim*2) == 1 then
                table.insert(self.blastShards, shardsColumn[y+1])
            end
        end
    end

    self.blastFrame = 0
end

local function forShards(self, fun, ...)
    for _,col in ipairs(self.shards) do
        for _,item in ipairs(col) do
            fun(self, item, ...)
        end
    end
end

local function drawShard(self, shard)
    sprite:draw(shard[3]-self.camX, shard[4]-self.camY, unFlipped, shard[1], shard[2], shardSize, shardSize)
end

local function renderShards(self)
    forShards(self, drawShard)
end

local function renderBlasts(self)
    for _,item in ipairs(self.blastShards) do
        sprite:draw(
                item[3] - self.camX,
                item[4] - self.camY, unFlipped,
                self.blastFrame *23, 489,
                23, 23
        )
    end

end

local function updateShard(_, shard)
    shard[3] += shard[5]
    shard[4] += shard[6]
    shard[5] *= shardDrag
    shard[6] = (shard[6]+gravity) * shardDrag
    shard[1] += random(-1,1)
    shard[2] += random(-1,1)
end

local function randomizeBlastShards(self)
    self.blastShards = {}
    for _ = 1, shardingDim*0.5 do
        table.insert(
            self.blastShards,
            self.shards[random(1,shardingDim)][random(1,shardingDim)]
        )
    end
end

--- Updates the explosion
--- return whether the explosion is done
function LockExplosion:update()
    if self.timer == 0 and Sounds then
        extra_sound:playAt(0, 1-(self.timer/duration))
   end
    self.camX, self.camY = getCam()
    forShards(self, updateShard)
    self.timer = self.timer + 1
    self.blastFrame += 1
    if self.blastFrame > 14 then
        self.blastFrame = 0
        randomizeBlastShards(self)
    end
    print(self.timer, duration)
    return self.timer < duration
end

function LockExplosion:render()
    renderShards(self)
    --renderBlasts(self)
end
