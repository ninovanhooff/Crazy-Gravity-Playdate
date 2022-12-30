local abs <const> = math.abs
local gfx <const> = playdate.graphics

local camPos <const> = camPos
local tileSize <const> = tileSize


class('BricksView').extends()

function BricksView:init()
    BricksView.super.init(self)
    self.bufferWidthTiles = gameWidthTiles + 1
    self.bufferHeightTiles = gameHeightTiles + 1
    self.activeBuffer = gfx.image.new(self.bufferWidthTiles * tileSize, self.bufferHeightTiles* tileSize, gameBgColor)
    self.inactiveBuffer = self.activeBuffer:copy()
    self.bricksImg = bricksImg
    self.brickPatternOverride = brickPatternOverride
    self.sizeY = levelProps.sizeY
    gfx.lockFocus(self.activeBuffer)
        self:initBricks()
    gfx.unlockFocus()
end

--- Returns an estimation of the number of tiles that had to be re-rendered,
--- a measure of computational cost
function BricksView:render()
    local shiftX, shiftY = camPos[1] - self.camPosX, camPos[2] - self.camPosY
    if shiftX ~= 0 or shiftY ~=0 then
        --printf("Render", frameCounter, camPos[1],self.camPosX, shiftX, camPos[2], self.camPosY, shiftY, math.abs(shiftY*self.bufferWidthTiles + shiftX*self.bufferHeightTiles))
        self.inactiveBuffer:clear(gameBgColor)
        gfx.lockFocus(self.inactiveBuffer)
            self.activeBuffer:draw(-shiftX*tileSize, -shiftY*tileSize)
            if shiftX < 0 then
                for x = 0, -shiftX-1, 1 do
                    self:renderLineVert(camPos[1]+x, camPos[2], x*tileSize)
                end
            elseif shiftX > 0 then
                for x = 0, shiftX-1, 1 do
                    self:renderLineVert(self.camPosX+self.bufferWidthTiles + x, camPos[2], (self.bufferWidthTiles - shiftX+x) * tileSize)
                end
            end
            if shiftY < 0 then
                for y = 0, -shiftY-1, 1 do
                    self:renderLineHoriz(camPos[1], camPos[2]+y, y*tileSize)
                end
            elseif shiftY > 0 then
                for y = 0, shiftY-1, 1 do
                    self:renderLineHoriz(camPos[1], self.camPosY+self.bufferHeightTiles + y, (self.bufferHeightTiles-shiftY+y) * tileSize)
                end
            end
        gfx.unlockFocus()
        self.activeBuffer, self.inactiveBuffer = self.inactiveBuffer, self.activeBuffer
    end

    self.camPosX = camPos[1]
    self.camPosY = camPos[2]
    self.activeBuffer:draw(-camPos[3], -camPos[4])
    -- when the camera moves vertically, a row of tiles has to be rendered.
    return abs(shiftY*self.bufferWidthTiles + shiftX*self.bufferHeightTiles)
end

function BricksView:initBricks()
    local startJ = camPos[2]
    local maxJ=camPos[2]+ self.bufferHeightTiles-1
    local i = camPos[1]
    local j = camPos[2]

    while j<=maxJ do -- bricks
        self:renderLineHoriz(i,j, (j-startJ)*tileSize)
        j = j + 1
    end

    self.camPosX = camPos[1]
    self.camPosY = camPos[2]
end

--- render column bricks, brute force, fail safe
--- Starts drawing at 1,1 so use a drawOffset to position the result
function BricksView:renderLineVert(i,j, drawOffsetX)
    local sumT <const> = sumT
    local greySumT <const> = greySumT
    local noFlip <const> = gfx.kImageUnflipped
    local brickPatternOverride <const> = self.brickPatternOverride
    local bricksImg <const> = self.bricksImg
    local brickT <const> = brickT
    local startJ = j
    while j<= startJ + self.bufferHeightTiles-1 do
        if j > self.sizeY then return end

        local curBrick = brickT[i]
        if not curBrick then
            break
        end
        curBrick = curBrick[j]
        local brickPattern = brickPatternOverride or curBrick[1]

        if curBrick[1]>2 then
            if curBrick[1]>=7 then --concrete
                bricksImg:draw(
                        drawOffsetX, (j-startJ)*8,
                        noFlip,
                        240+(curBrick[2]*curBrick[3]+curBrick[4])*8,
                        greySumT[curBrick[3]]+curBrick[5]*8,
                        8*(curBrick[3]-curBrick[4]),
                        8*(curBrick[3]-curBrick[5])
                )
            elseif curBrick[1]>=3 then --color
                bricksImg:draw(
                        drawOffsetX, (j-startJ)*8,
                        noFlip,
                        (brickPattern-3)*48+sumT[curBrick[2]]+curBrick[4]*8,
                        sumT[curBrick[3]]+curBrick[5]*8,
                        (curBrick[2]-curBrick[4])*8,
                        (curBrick[3]-curBrick[5])*8
                )
            end
        end
        j = j + curBrick[3]-curBrick[5]
        curBrick = nil
    end
end

--- render a row of bricks, brute force, fail safe
function BricksView:renderLineHoriz(i,j, drawOffsetY)
    if j > self.sizeY then return end

    local sumT <const> = sumT
    local greySumT <const> = greySumT
    local noFlip <const> = gfx.kImageUnflipped
    local brickPatternOverride <const> = self.brickPatternOverride
    local bricksImg <const> = self.bricksImg
    local brickT <const> = brickT
    local startI = i
    while i<=startI+self.bufferWidthTiles do
        local curBrick = brickT[i]
        if not curBrick then break end
        curBrick = curBrick[j]

        local brickPattern = brickPatternOverride or curBrick[1]

        if curBrick[1]>2 then
            if curBrick[1]>=7 then --concrete
                bricksImg:draw(
                        (i -startI) * 8, drawOffsetY,
                        noFlip,
                        240+curBrick[2]*curBrick[3]*8,
                        greySumT[curBrick[3]]+curBrick[5]*8,
                        8*(curBrick[3]-curBrick[4]),
                        8*(curBrick[3]-curBrick[5])
                )
                i = i + curBrick[3]-curBrick[4]
            elseif curBrick[1]>=3 then --color
                bricksImg:draw(
                        (i -startI) * 8, drawOffsetY,
                        noFlip,
                        (brickPattern-3)*48+sumT[curBrick[2]]+curBrick[4]*8,
                        sumT[curBrick[3]]+curBrick[5]*8,
                        (curBrick[2]-curBrick[4])*8,
                        (curBrick[3]-curBrick[5])*8
                )
                i = i + curBrick[2]-curBrick[4]
            end
        else
            i = i + curBrick[2]-curBrick[4]
        end

    end
end
