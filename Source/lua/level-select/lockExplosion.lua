import "CoreLibs/object"

--- the amount of shards to create in both dimensions.
--- Total shard count is the square of this number
local shardingDim <const> = 9
local lockSize <const> = 32
local shardSize <const> = lockSize / shardingDim -- lock is 32 px in both dimension

local gfx <const> = playdate.graphics
local random <const> = math.random
local unFlipped <const> = playdate.graphics.kImageUnflipped
local spriteOffsetX <const>, spriteOffsetY <const> = 0,64
local duration <const> = frameRate --note time starts at -10
local shardDrag

class('LockExplosion').extends()

--- return cam position as x,y
local function shakeCam(self)
    if random() > 0.4 then
        if sign(self.vX) == sign(self.camX) then
            self.vX = -self.vX
        end
    end
    if random() > 0.4 then
        if sign(self.vY) == sign(self.camY) then
            self.vY = -self.vY
        end
    end
    self.camX += self.vX
    self.camY += self.vY
    return self.camX, self.camY
end

function LockExplosion:init()
    -- initial shard velocity and shake velocity
    self.vX, self.vY = 2,2
    self.camX, self.camY = 0,0

    LockExplosion.super.init()
    self.lockX, self.lockY = 20,20 -- todo param

    shardDrag = (1 + drag) * 0.55
    
    self.blastShards = {}
    self.timer = -10 -- start delay
    self.shards = {}

    for x = 0, shardingDim-1 do
        local shardsColumn = {}
        self.shards[x+1] = shardsColumn
        for y = 0,shardingDim-1 do
            shardsColumn[y+1] = {
                -- sprite offset x, sprite offset y,
                spriteOffsetX + shardSize*x, spriteOffsetY + shardSize*y,
                -- pixelPosition
                self.lockX + shardSize*x, self.lockY + shardSize*y,
                -- force x, force y
                x-shardingDim/2 + self.vX*0.8 + random() -0.5 ,y-shardingDim/2 + self.vY*0.8 +random()
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

local function updateShard(_, shard)
    shard[3] += shard[5]
    shard[4] += shard[6]
    shard[5] *= shardDrag
    shard[6] = (shard[6]+gravity) * shardDrag
    -- randomize sprite source location
    shard[1] += random(-1,1)
    shard[2] += random(-1,1)
end

--- Updates the explosion
--- @returns whether the explosion is running
function LockExplosion:update()
    if self.timer < 0 then -- start delay
        self.camX, self.camY = shakeCam(self) --todo remove
    else
        if self.timer == 0 and Sounds then
            extra_sound:playAt(0, 1-(self.timer/duration))
        end
        forShards(self, updateShard)
    end
    self.timer = self.timer + 1
    return self.timer < duration
end

function LockExplosion:render()
    gfx.pushContext()
    
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    if self.timer < 0 then
        sprite:draw(self.lockX + self.camX, self.lockY + self.camY, unFlipped, spriteOffsetX, spriteOffsetY, lockSize, lockSize)
    else
        renderShards(self)
    end
    
    gfx.popContext()
end
