import "settings.lua"
import "drawUtil.lua"
import "specialsView.lua"
import "specialsViewModel.lua"
import "gameView.lua"

local unFlipped <const> = playdate.graphics.kImageUnflipped


colorT = {"red","green","blue","yellow"}
sumT = {0,8,24}
greySumT = {-1,56,32,0} -- -1:unused
local halfWidthTiles = math.ceil(gameWidthTiles*0.5)
local halfHeightTiles = math.ceil(gameHeightTiles*0.5)

function UnitCollision(x,y,w,h,testMode)
	--printf(x,y,w,h)
	for i=1,5,2 do
		if colBT[i]>=x and colBT[i]<x+w and colBT[i+1]>=y and colBT[i+1]<y+h then
			if not testMode then collision = true end
			return true
		end
	end
	return false
end

-- returns true if this rect collides with planePos, dus not take plane sub-pos ([3] and 4]) into
-- account. When false, it is guaranteed that this rect does not intersect with the plane
function ApproxRectCollision(x, y, w, h)
	-- plane size is 3
	return planePos[1]+2 > x and planePos[1] < x+w  and planePos[2]+2 > y and planePos[2] <y+h
end

function PixelCollision(x,y,w,h) -- needs work?
	for i=1,9,2 do
		--printf("pixelCol",planePos[1]*8+colT[i],x,planePos[2]*8+colT[i+1],y)
		--printf(planePos[1]*8+colT[i],x,planePos[2]*8+colT[i+1],y)
		if planePos[1]*8+colT[i]>x and planePos[1]*8+colT[i]<=x+w and planePos[2]*8+colT[i+1]>=y and planePos[2]*8+colT[i+1]<=y+h then -- -1
			collision = true
			return true
		end
	end
	return false
end

function OptimizeLevel()
	for i=1,levelProps.sizeX do
		local lastJ = -1
		for j=levelProps.sizeY,1,-1 do
			if brickT[i][j][1]<3 and j>1 then -- empty space
				if lastJ==-1 then
					lastJ = j
				end
			else -- always for j==1
				if lastJ~=-1 then
					for k=j+1,lastJ do
						brickT[i][k][3]=lastJ-j -- h
						brickT[i][k][5]=k-(j+1) -- subY
					end
					lastJ=-1
				end
			end
		end
	end

	for j=1,levelProps.sizeY do
		local lastI = -1
		for i=levelProps.sizeX,1,-1 do
			if brickT[i][j][1]<3 and i>1 then -- empty space
				if lastI==-1 then
					lastI = i
				end
			else -- always for i==1
				if lastI~=-1 then
					for k=i+1,lastI do
						brickT[k][j][2]=lastI-i -- w
						brickT[k][j][4]=k-(i+1) -- subX
					end
					lastI=-1
				end
			end
		end
	end
end

function TimeString(eSec) -- elapsed secs
	eMin = math.floor(eSec/60)
	eSec = math.floor(eSec % 60)
	if eMin<10 then eMin = "0"..eMin end
	if eSec<10 then eSec = "0"..eSec end
	return eMin..":"..eSec
end

function checkCam()
	if camPos[1]>levelProps.sizeX- gameWidthTiles then
		camPos[1] = levelProps.sizeX- gameWidthTiles
	end
	if camPos[2]>levelProps.sizeY-31 then
		camPos[2] = levelProps.sizeY-31
	end

	if camPos[1]<1 then camPos[1]=1 end
	if camPos[2]<1 then camPos[2]=1 end
end

function ApplyGameSets()
	burnRate = gameSettings[7].val -- amount of fuel each frame
	gravity,drag = gameSettings[1].val,gameSettings[2].val --add,mult per frame!!
	landingTolerance = {gameSettings[5].val*0.5,gameSettings[5].val} -- max vx,vy
	thrustPower,turboPower = gameSettings[6].val,0.2
	blowerStrength,magnetStrength = gameSettings[3].val,gameSettings[4].val
end

function ResetPlane()
	planePos = {homeBase.x+math.floor(homeBase.w*0.5-1),homeBase.y+1,0,4} --x,y,subx,suby
	camPos = {homeBase.x+math.floor(homeBase.w*0.5)-halfWidthTiles,homeBase.y-halfHeightTiles,0,0} --x,y,subx,suby
	checkCam()
	flying = false
	vx,vy,planeRot,thrust = 0,0,18,0 -- thrust only 0 or 1; use thrustPower to adjust.
	CalcPlaneColCoords()
	explodeI,collision = nil,false
	fuel = levelProps.fuel
	landedTimer,landedAt = 0,-1
end

function InitGame(path)
	LoadFile(path)
	curGamePath = path
	OptimizeLevel() --todo remove, bake into level files
	for i,item in ipairs(specialT) do
		if item.sType == 8 then --platform
			if item.pType == 1 then -- home
				homeBase = item
			end
		end
		initSpecial[item.sType](item)
	end
	if not homeBase then 
		error("lvl has no base")
	end
	ResetGame()
end

function ResetGame()
	ResetPlane()
	planeFreight = {} -- type, idx of special where picked up
	remainingFreight = {0,0,0,0} -- amnt for each type
	keys = {false,false,false,false} -- have? bool
	for i,item in ipairs(specialT) do
		if item.sType == 8 then --platform
			item.amnt = item.origAmnt
			if item.pType == 2 then -- freight
				remainingFreight[item.type+1] = remainingFreight[item.type+1]+item.amnt
			end
		elseif item.sType == 12 then -- cannon
			item.balls = {}
		end
	end
	ApplyGameSets()
	extras = {0,levelProps.lives,1} -- turbo, life(initial 3 lives), cargo
	-- time to beat
	if highScores[curGamePath] then
		lSec = highScores[curGamePath][1][2] -- {name,time}
	else
		lSec = 5940 -- 99'00
	end
	lMin = math.floor(lSec/60)
	lSec = math.floor(lSec%60)
	if lMin<10 then lMin = "0"..lMin end
	if lSec<10 then lSec = "0"..lSec end
	frameCounter = -60
	for i=1,60 do
		CalcTimeStep() -- let cannons fire a few shots, bringing counter to 0
	end
	explodeI = nil
	editorMode = false
	bricksView = BricksView()
end

function CalcGameCam()
	--printf("camBefore",camPos[1].." "..camPos[2].." "..camPos[3].." "..camPos[4])

	-- horizontal cam position
	if planePos[1]>camPos[1]+halfWidthTiles then
		camPos[3] = camPos[3] + planePos[1]-(camPos[1]+halfWidthTiles)
	elseif planePos[1]<camPos[1]+halfWidthTiles then
		camPos[3] = camPos[3] - (camPos[1]+halfWidthTiles-planePos[1])
	end
	if camPos[3]>tileSize-1 then
		local addUnits = math.floor(camPos[3]/tileSize)
		camPos[1] = camPos[1]+addUnits
		camPos[3] = camPos[3]-addUnits*8
	elseif camPos[3]<0 then
		--printf("before",planePos[1],planePos[3])
		local substUnits = -math.floor(camPos[3]/tileSize)
		camPos[1] = camPos[1]-substUnits
		camPos[3] = tileSize+(camPos[3]+(substUnits-1)*tileSize)
		--printf("after",planePos[1],planePos[3])
	end
	if camPos[1]<1 then
		camPos[1],camPos[3]=1,0
	elseif camPos[1]+gameWidthTiles >=levelProps.sizeX then
		camPos[1],camPos[3] = levelProps.sizeX- gameWidthTiles,0
	end

	-- vertical cam position
	if planePos[2]>camPos[2]+halfHeightTiles then
		camPos[4] = camPos[4] + planePos[2]-(camPos[2]+halfHeightTiles)
	elseif planePos[2]<camPos[2]+halfHeightTiles then
		camPos[4] = camPos[4] - (camPos[2]+halfHeightTiles - planePos[2])
	end
	if camPos[4]>7 then
		local addUnits = math.floor(camPos[4]/tileSize)
		camPos[2] = camPos[2]+addUnits
		camPos[4] = camPos[4]-addUnits*tileSize
	elseif camPos[4]<0 then
		--printf("before",planePos[1],planePos[3])
		local substUnits = -math.floor(camPos[4]/tileSize)
		camPos[2] = camPos[2]-substUnits
		camPos[4] = tileSize+(camPos[4]+(substUnits-1)*tileSize)
		--printf("after",planePos[1],planePos[3])
	end
	local offScreenTileY = gameHeightTiles+1
	if camPos[2]<1 then
		camPos[2],camPos[4]=1,0
	elseif camPos[2]+offScreenTileY>levelProps.sizeY or (camPos[2]+offScreenTileY==levelProps.sizeY and camPos[4]>0) then
		camPos[2],camPos[4] = levelProps.sizeY-offScreenTileY,0
	end
	--printf("camAfter",camPos[1].." "..camPos[2].." "..camPos[3].." "..camPos[4])
end

local sinColT= {}
for i = 0,23 do
	sinColT[i] = {
		math.sin(i/12*pi)*10+11,
		math.sin((i/12+0.75)*pi)*12+11,
		math.sin((i/12-0.75)*pi)*12+11
	}
end

local cosColT= {}
for i = 0,23 do
	cosColT[i] = {
		math.cos(i/12*pi)*10+11,
		math.cos((i/12+0.75)*pi)*12+11,
		math.cos((i/12-0.75)*pi)*12+11
	}
end

function CalcPlaneColCoords()
	colT = nil
	colT = {}
	local sinColTR = sinColT[planeRot]
	local cosColTR = cosColT[planeRot]
	colT[1] = cosColTR[1]+planePos[3] -- tip x
	colT[2] = sinColTR[1]+planePos[4] -- tip y
	colT[3] = cosColTR[2]+planePos[3] -- right base x
	colT[4] = sinColTR[2]+planePos[4] -- right base y
	colT[5] = cosColTR[3]+planePos[3] -- left base x
	colT[6] = sinColTR[3]+planePos[4] -- left base y
	colT[7] = (colT[5]+colT[1])*0.5
	colT[8] = (colT[6]+colT[2])*0.5
	colT[9] = (colT[3]+colT[1])*0.5
	colT[10] = (colT[4]+colT[2])*0.5
	colBT = nil
	colBT = {}
	for i=1,5,2 do
		colBT[i]=math.max(planePos[1]+math.floor(colT[i]*0.125),1.0)
		colBT[i+1]=math.max(planePos[2]+math.floor(colT[i+1]*0.125),1.0)
	end
end

function CalcTimeStep()
	frameCounter = frameCounter + 1
	if flying then --physics
		vx = vx*drag -- thrust?
		vy = (vy+gravity)*drag
		planePos[3] = planePos[3] + vx
		planePos[4] = planePos[4] + vy
		if planePos[3]>7 then
			local addUnits = math.floor(planePos[3]*0.125)
			planePos[1] = planePos[1]+addUnits
			planePos[3] = planePos[3]-addUnits*8
		elseif planePos[3]<0 then
			--printf("before",planePos[1],planePos[3])
			local substUnits = -math.floor(planePos[3]*0.125)
			planePos[1] = planePos[1]-substUnits
			planePos[3] = 8+(planePos[3]+(substUnits-1)*8)
			--printf("after",planePos[1],planePos[3])
		end
		if planePos[4]>7 then
			local addUnits = math.floor(planePos[4]*0.125)
			planePos[2] = planePos[2]+addUnits
			planePos[4] = planePos[4]-addUnits*8
		elseif planePos[4]<0 then
			local substUnits = -math.floor(planePos[4]*0.125)
			planePos[2] = planePos[2]-substUnits
			planePos[4] = 8+(planePos[4]+(substUnits-1)*8)
		end
	end
	if planePos[1]<1 then -- level edges
		planePos[1],planePos[3]=1,1
		vx = 0
	end
	if planePos[1]>levelProps.sizeX-3 then -- level edges
		planePos[1],planePos[3]=levelProps.sizeX-2,0 -- fine-tune
		vx = 0
	end
	if planePos[2]<1 then -- level edges
		planePos[2],planePos[4]=1,1
		vy = 0
	end
	if planePos[2]>levelProps.sizeY-3 then -- level edges
		planePos[2],planePos[4]=levelProps.sizeY-3,7
		vy = 0
	end
	
	CalcGameCam()
	--printf("plane".." "..planePos[1].." "..planePos[2].." "..planePos[3].." "..planePos[4].." "..vx.." "..vy)
	
	-- brick collision
	collision = false
	CalcPlaneColCoords()
	for i=1,5,2 do
		if brickT[colBT[i]][colBT[i+1]][1]>1 then
			--print("collision",i,colBT[i],colBT[i+1])
			collision = true
		end
	end
	
	for i,item in ipairs(specialT) do
		--if item.x+item.w+10>=camPos[1] and item.x-10<=camPos[1]+60 and item.y+item.h+10>=camPos[2] and item.y-10<camPos[2]+32 then -- visible with 10 units margin
			specialCalcT[item.sType](item,i)
		--end
	end
	if collision and not Debug then
		if Sounds then thrust_sound:stop() end
		print("KABOOM")
		for i=0,2 do
			explodeI = i
			explodeX = math.random(-5,10)
			explodeY = math.random(-5,10)
			if Sounds then
				explode_sound:play()
			end
			for j = 0,14,2 do -- one exp(losion) loop
				explodeJ = j
				RenderGame()
				coroutine.yield() -- let system update the screen
			end
		end
		DecreaseLife()
	end
end

function DecreaseLife()
	if extras[2]==0 then
		kill = 1
	else
		for i=0,10 do -- blink life in and out
			RenderGame(true)
			if i%2==0 then
				sprite:draw(5+(extras[2]-1)*25,5,23, 23, unFlipped, 23, 23, 0, 255)
			end
		end
		
		extras[2] = extras[2]-1
		for i,item in ipairs(planeFreight) do
			specialT[item[2]].amnt = specialT[item[2]].amnt+1 -- replace freight on pltfrms
			remainingFreight[item[1]+1] = remainingFreight[item[1]+1] + 1
		end
		planeFreight = {}
		ResetPlane()
	end
end

function Benchmark(n)
	calcTimeStep()
	benchTimer = timer.create()
	for i=1,n do
		CalcTimeStep()
		RenderGame()
	end
	local t = benchTimer:peekdelta()
	benchTimer = nil
	return t
end

function IncrementStringNumber(str)
	printf("incr",str)
	num = tonumber(str) +1
	return string.format("%0.2d",num)
end

function CompareScore(a,b)
	return a[2]<b[2]
end

function VictoryMenuBR()
	local n
	if not highScores[curGamePath] then
		highScores[curGamePath] = {}
	end
	curScores = highScores[curGamePath]
	table.insert(curScores,{utils.nickname():sub(1,10),math.floor(frameCounter/frameRate)})
	table.sort(curScores,CompareScore)
	while #curScores>3 do table.remove(curScores) end
	table.save(highScores,"highscores.lua")
	_,patEnd,match = curGamePath:find(".+%/.*(%d%d)")
	if match then
		newGamePath = curGamePath:sub(1,patEnd-2)..IncrementStringNumber(match)..curGamePath:sub(patEnd+1)
	end
	printf(curGamePath,newGamePath)
	if not (match and file.exists(newGamePath)) then
		newGamePath = nil
	end
	RenderVictoryMenu(curScores)
	delay(500*1000)
	while running() do
		RenderVictoryMenu(curScores)

		repeat
			delay(1000*80)
			controls.update()
			if pressedany() then
				break
			end

		until not running()
		if pressed(cross) then
			--load next
			InitGame(newGamePath)
			break
		elseif pressed(circle) then
			kill = 1
			break
		elseif pressed(triangle) then
			-- restart
			ResetGame()
			break
		end
	end
end

function RenderVictoryMenu(data)
	BGRender(true)
	pgeDrawRect(175,60,125,45+(#data+2)*12-3,menuBGClr)
	for i=0,1 do
		for j = 0,1 do
			sprite:draw(172+i*120, 55+j*35+j*(#data+2)*12, unFlipped, 5-i*4, 464-j*4, 23, 23)--corner blocks
		end
	end
	sprite:draw(298, 71, unFlipped, 500, 213, 11, 14+(#data+2)*12+5) --right rod
	sprite:draw(175, 71, unFlipped, 500, 213, 11, 14+(#data+2)*12+5) --left rod
	sprite:draw(188, 98+(#data+2)*12-2, unFlipped, 173, 80, 104, 11) -- bottom rod
	sprite:draw(188, 59, unFlipped, 173, 80, 104, 11) -- top rod
	local menucurX,menucurY

	pgeDrawTextcenter(70,black,"Level Complete!")
	pgeDrawTextcenter(82,black,"Your time: "..TimeString(frameCounter*0.05))
	for i,item in ipairs(data) do
		pgeDrawText(189,91+i*12,black,i..".") -- rank
		pgeDrawText(200,91+i*12,black,item[1])
		pgeDrawText(263,91+i*12,black,TimeString(item[2]))
	end

	if newGamePath then
		sprite:draw(188, 85+(#data+2)*12, unFlipped, 84, 463, 10, 10)
		pgeDrawText(197,85+(#data+2)*12,black,"Next")
	end
	sprite:draw(223, 85+(#data+2)*12, unFlipped, 123, 463, 10, 10)
	sprite:draw(263, 85+(#data+2)*12, unFlipped, 96, 463, 10, 10)
	pgeDrawText(232,85+(#data+2)*12,black,"Restrt")
	pgeDrawText(272,85+(#data+2)*12,black,"Quit")
	--sprite:draw(187, menucurY, unFlipped, 0, 368, 20, 20) -- cursor
end
