

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

class('LockAnimation').extends()

LockAnimation.type = enum({"ShakeAndExplode", "ShakeAndDenied"})

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

function LockAnimation:init(thumbRect, type)
    LockAnimation.super.init(self)
    self.thumbRect = thumbRect
    self.type = type
    -- initial shard velocity and shake velocity
    self.vX, self.vY = 2,2
    self.camX, self.camY = 0,0

    local center = thumbRect:centerPoint()

    self.lockX, self.lockY = center.x -lockSize/2,center.y - lockSize/2

    shardDrag = (1 + drag) * 0.55
    
    self.blastShards = {}
    --- When < 0 shake, else explode
    self.explosionTimer = -10
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
function LockAnimation:update()
    if self.explosionTimer < 0 then
        self.camX, self.camY = shakeCam(self)
    else
        if self.explosionTimer == 0 and Sounds then
            unlock_sound:play()
        end
        forShards(self, updateShard)
    end
    self.explosionTimer = self.explosionTimer + 1

    if self.explosionTimer == 0 and self.type == LockAnimation.type.ShakeAndDenied then
        unlock_sound_denied:play()
        return false
    end

    return self.explosionTimer < duration
end

function LockAnimation:render()
    gfx.pushContext()

    if self.explosionTimer < 0 then
        -- fully hide the thumb and draw a lock over it
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(self.thumbRect)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        sprite:draw(self.lockX + self.camX, self.lockY + self.camY, unFlipped, spriteOffsetX, spriteOffsetY, lockSize, lockSize)
    else
        -- reveal the thumb and draw shards over it
        gfx.setDitherPattern((self.explosionTimer/duration)*3, gfx.image.kDitherTypeBayer8x8) -- invert alpha due to bug in SDK
        gfx.fillRect(self.thumbRect)
        gfx.setImageDrawMode(gfx.kDrawModeNXOR)
        renderShards(self)
    end
    
    gfx.popContext()
end
