--- the amount of shards to create in both dimensions.
--- Total shard count is the square of this number
local shardingDim <const> = 5
local shardSize <const> = 24 / shardingDim -- plane is 24px in both dimensions

local gfx <const> = playdate.graphics
local random <const> = math.random
local unFlipped <const> = playdate.graphics.kImageUnflipped
local resourceLoader <const> = GetResourceLoader()
local tileSize <const> = tileSize
local planePos <const> = planePos
local camPos <const> = camPos
local frameRate <const> = frameRate
local duration <const> = frameRate * 2
local fadeOutStartTime <const> = duration - frameRate
local fastForwardTime <const> = fadeOutStartTime + 10
local shardDrag

class('GameExplosion').extends()

--- return cam position as x,y
local function getCam()
    return camPos[1]*tileSize+camPos[3], camPos[2]*tileSize+camPos[4]
end

function GameExplosion:init(scrimHeight)
    GameExplosion.super.init(self)
    shardDrag = (1 + drag) * 0.5
    local planeX, planeY = planePos[1]*tileSize+planePos[3], planePos[2]*tileSize+planePos[4]

    self.scrimHeight = scrimHeight
    self.camX, self.camY = getCam()
    self.blastShards = {}
    self.timer = 0
    self.shards = {}

    local planeSpriteOffsetX, planeSpriteOffsetY = planeRot%16*23, 391 +(boolToNum(planeRot>15))*46, 23
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

-- used by :update()
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
function GameExplosion:update()
    if self.blastFrame == 0 and Sounds then
        explode_sound:playAt(0, (1-(self.timer/duration)) * resourceLoader.soundVolume)
   end
    self.camX, self.camY = getCam()
    forShards(self, updateShard)
    self.timer = self.timer + 1
    self.blastFrame += 1
    if self.blastFrame > 14 then
        self.blastFrame = 0
        randomizeBlastShards(self)
    end
    return self.timer < duration
end

function GameExplosion:fastForward()
    if self.timer < fastForwardTime  then
        self.timer = fastForwardTime
    end
end

function GameExplosion:render()
    renderShards(self)
    renderBlasts(self)
    -- gradually fade out the game after 1 second of explosion
    if self.timer > fadeOutStartTime then
        gfx.setDitherPattern(1.2-((self.timer-frameRate)/frameRate), gfx.image.kDitherTypeDiagonalLine) -- invert alpha due to bug in SDK
        gfx.fillRect(0,0, screenWidth, self.scrimHeight)
    end
end
