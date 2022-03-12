import "settings.lua"
import "drawUtil.lua"
import "specials.lua"

local gfx = playdate.graphics

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
						--brickT[i][k][4]=lastJ-j
						brickT[i][k][3]=lastJ-j -- h
						brickT[i][k][5]=k-(j+1)
					end
					lastJ=-1
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

function CalcPlatform(item,idx)
	--platform collision
	if PixelCollision(item.x*8,item.y*8+32,item.w*8,16) and (planeRot~=18 or(vy > landingTolerance[2] or math.abs(vx)> landingTolerance[1]))   then
		collision = true
		print("platform collide!!")
	end
	-- crate collision
	if item.pType~=1 then -- not landing, pickup
		if item.amnt>0 then -- lower row
			UnitCollision(item.x+1,item.y+2,2+math.floor(item.amnt*0.5)*2,2)
			if item.amnt>2 then --upper row
				UnitCollision(item.x+2,item.y,math.floor((item.amnt-1)*0.5)*2,2)
			end
		end
	end	
	
	--landing
	if flying and planeRot == 18 then -- upright
		if planePos[2]==item.y+1 and planePos[1]>=item.x-2 and planePos[1]<item.x+item.w-1 and planePos[4]>=3 and vy>0 and vy <= landingTolerance[2] and math.abs(vx)<= landingTolerance[1] then
			flying = false
			collision = false
			vx,vy=0,0
			planePos[4]=4
			printf("LANDED AT",idx)
			landedTimer = 0
			landedAt = idx
			if Sounds then landing_sound:play() end
		end
	elseif not flying then
		if landedTimer>20 and landedAt==idx then -- 0.9 secs and landed at cur pltfrm
			printf(item.pType,#planeFreight,"HJ")
			if item.pType==1 and #planeFreight>0 then -- dump
				if Sounds then 
					dump_sound:play()
				end
				table.remove(planeFreight,1)
				if table.sum(remainingFreight)==0 then
					printf("VICTORY")
					VictoryMenuBR()
				else
					printf("HUH",table.sum(remainingFreight))
				end
			elseif item.amnt>0 then --pickup
				printf(#planeFreight,extras[3],pType)
				if item.pType==2 and #planeFreight<extras[3] then -- freight
					remainingFreight[item.type+1] = remainingFreight[item.type+1] -1
					table.insert(planeFreight,{item.type,landedAt})
					item.amnt = item.amnt -1
					if Sounds then pickup_sound:play() end
				elseif item.pType==3 and fuel<6000 then
					fuel = math.fmin(6000,fuel+3000)
					item.amnt = item.amnt -1
					if Sounds then fuel_sound:play() end
				elseif item.pType==4 and item.amnt>0 then -- extras
					extras[item.type]=extras[item.type]+1
					item.amnt = item.amnt -1
					if Sounds then extra_sound:play() end
				elseif item.pType==5 then -- key
					printf("KEY",item.color)
					keys[item.color]=true
					item.amnt = item.amnt -1
					if Sounds then key_sound:play() end
				end
			end
			landedTimer = 0
		else
			landedTimer = landedTimer + 1
		end
	end
	
end

function CalcBlower(item,idx)
	if item.direction==1 then --up
		if UnitCollision(item.x,item.y,6,item.distance,true) then
			local mult = item.distance-(item.y+item.distance - planePos[2])
			vy = vy - (mult/item.distance)*blowerStrength*3
		end
	elseif item.direction==2 then --down
		if UnitCollision(item.x,item.y+8,6,item.distance,true) then
			printf("blower a",vy,planePos[2],item.y+8)
			local mult = item.distance-(planePos[2] - (item.y+8))
			vy = vy + (mult/item.distance)*blowerStrength
			printf("blower b",vy,item.y)
		end
	elseif item.direction==3 then --left
		if UnitCollision(item.x,item.y,item.distance,6,true) then
			local mult = item.distance-(item.x+item.distance - planePos[1])
			vx = vx - (mult/item.distance)*blowerStrength*4
		end
	elseif item.direction==4 then --right
		if UnitCollision(item.x+8,item.y,item.distance,6,true) then
			local mult = item.distance-(planePos[1] - (item.x+8))
			vx = vx + (mult/item.distance)*blowerStrength*4
		end	
	end
end

function CalcMagnet(item,idx)
	if item.direction==1 then --up
		if UnitCollision(item.x,item.y,4,item.distance,true) then
			local mult = item.distance-(item.y+item.distance - planePos[2])
			vy = vy + (mult/item.distance)*magnetStrength*3
		end
	elseif item.direction==2 then --down
		if UnitCollision(item.x,item.y+6,4,item.distance,true) then
			printf("magn a",vy,planePos[2],item.y+6)
			local mult = item.distance-(planePos[2] - (item.y+6))
			vy = vy - (mult/item.distance)*magnetStrength
			printf("magn b",vy,item.y)
		end
	elseif item.direction==3 then --left
		if UnitCollision(item.x,item.y,item.distance,4,true) then
			local mult = item.distance-(item.x+item.distance - planePos[1])
			vx = vx + (mult/item.distance)*magnetStrength*4
		end
	elseif item.direction==4 then --right
		if UnitCollision(item.x+6,item.y,item.distance,4,true) then
			local mult = item.distance-(planePos[1] - (item.x+6))
			vx = vx - (mult/item.distance)*magnetStrength*4
		end	
	end
end

function CalcRotator(item,idx)
	if (item.direction==1 and UnitCollision(item.x,item.y,5,item.distance,true))
	or (item.direction==2 and UnitCollision(item.x,item.y+8,5,item.distance,true))
	or (item.direction==3 and UnitCollision(item.x,item.y,item.distance,5,true))
	or (item.direction==4 and UnitCollision(item.x+8,item.y,item.distance,5,true)) then
		if frameCounter%2==1 then
			if item.rotates==1 then -- left
				planeRot = planeRot - 1
			else
				planeRot = planeRot + 1
			end
			planeRot = math.fmod(planeRot,23)
			planeRot = math.random(planeRot,0)
		end
	end
end

function CalcCannon(item,idx)
	if frameCounter%(80-item.rate)==0 then -- add a ball
		table.insert(item.balls,{0,math.random(0,72)}) -- px position,color offset
	end
	for j,jtem in ipairs(item.balls) do
		jtem[1] = jtem[1]+item.speed
		if jtem[1]>(item.distance-1)*8 then
			table.remove(item.balls,j)--WARNING!!
		else
			--collision
			if item.direction==1 then
				PixelCollision(item.x*8+8,(item.y+item.distance)*8-jtem[1],8,8)--+2
			elseif item.direction==2 then
				PixelCollision(item.x*8+8,item.y*8+jtem[1]+24,8,8)
			elseif item.direction==3 then
				PixelCollision((item.x+item.distance)*8-jtem[1],item.y*8+8,8,8)
			else
				PixelCollision(item.x*8+24+jtem[1],item.y*8+8,8,8)
			end
		end
	end
end

function CalcRod(item)
	if item.pos1+item.pos2>=item.distance*8-24 then
		item.d1=-1
		item.speed1 = math.random(item.speedMin,item.speedMax+1)
	elseif item.pos1<2 then
		item.d1=1
		item.speed1 = math.random(item.speedMin,item.speedMax+1)
	elseif (item.chngOften==1 and math.random(1,150)==62) then
		item.d1=-1+math.random(0,2)*2
		item.speed1 = math.random(item.speedMin,item.speedMax+1)
	end
	if item.fixdGap == 1 then
		if item.pos2<2 then
			item.d1 = -1
		end
		item.speed2=item.speed1
		item.d2=-item.d1
	elseif item.pos1+item.pos2>=item.distance*8-24 then
		item.d2=-1
		item.speed2 = math.random(item.speedMin,item.speedMax+1)
	elseif item.pos2<2 then
		item.d2=1
		item.speed2 = math.random(item.speedMin,item.speedMax+1)
	elseif (item.chngOften==1 and math.random(1,150)==62) then
		item.d2=-1+math.random(0,2)*2
		item.speed2 = math.random(item.speedMin,item.speedMax+1)
	end
	item.pos1 = item.pos1+item.speed1*item.d1
	item.pos2 = item.pos2+item.speed2*item.d2
	if item.direction==1 then -- horiz
		PixelCollision(item.x*8+24,item.y*8+6,item.pos1,12) -- left rod
		PixelCollision(item.x*8+item.distance*8-item.pos2,item.y*8+6,item.pos2,12) -- right rod
	else -- vert
		PixelCollision(item.x*8+6,item.y*8+24,12,item.pos1) -- top
		PixelCollision(item.x*8+6,item.y*8+item.distance*8-item.pos2,12,item.pos2) -- bottom
	end
end

function Calc1Way(item)
	local activated = false
	if item.direction==1 then --up
		if UnitCollision(item.x+4+(item.XtoY-2)*(-4+item.actW),item.y+item.distance*0.5+3-item.actH*0.5,item.actW,item.actH,true) then
			activated = true
			PixelCollision(item.x*8+32,(item.y+item.distance)*8-4-item.pos,32,item.pos)
		end
	elseif item.direction==2 then --down
		if UnitCollision(item.x+4+(item.XtoY-2)*(-4+item.actW),item.y+item.distance*0.5+3-item.actH*0.5,item.actW,item.actH,true) then
			activated = true
			PixelCollision(item.x*8+32,item.y*8+36,32,item.pos)
		end	
	elseif item.direction==3 then --left
		if UnitCollision(item.x+item.distance*0.5+3-item.actW*0.5,item.y+8-(item.XtoY-1)*4-boolToNum(item.XtoY==1)*item.actH,item.actW,item.actH,true) then
			activated = true
			PixelCollision((item.x+item.distance)*8-4-item.pos,item.y*8+32,item.pos,32)
		end	
	elseif item.direction==4 then --right
		if UnitCollision(item.x+item.distance*0.5+3-item.actW*0.5,item.y+8-(item.XtoY-1)*4-boolToNum(item.XtoY==1)*item.actH,item.actW,item.actH,true) then
			activated = true
			PixelCollision(item.x*8+36,item.y*8+32,item.pos,32)
		end	
	end
	if activated then
		item.pos = item.pos - barrierSpeed
		if item.pos<0 then
			item.pos = 0
		end
	else
		item.pos = item.pos+barrierSpeed
		if item.pos>item.distance*8-boolToNum(item.endStone==1)*16-4 then
			item.pos=item.distance*8-boolToNum(item.endStone==1)*16-4
		end
	end
end

function CalcBarrier(item)
	item.activated = false
	if item.direction==1 then --up
		if UnitCollision(item.x+3-item.actW*0.5,item.y+item.distance*0.5-item.actH*0.5,item.actW,item.actH,true) then
			item.activated = true
			PixelCollision(item.x*8+8,(item.y+item.distance)*8-4-item.pos,32,item.pos)
		end
	elseif item.direction==2 then --down
		if UnitCollision(item.x+3-item.actW*0.5,item.y+4+item.distance*0.5-1-item.actH*0.5,item.actW,item.actH,true) then
			item.activated = true
			PixelCollision(item.x*8+8,item.y*8+36,32,item.pos)
		end	
	elseif item.direction==3 then --left
		if UnitCollision(item.x+item.distance*0.5-item.actW*0.5,item.y+3-item.actH*0.5,item.actW,item.actH,true) then
			item.activated = true
			PixelCollision((item.x+item.distance)*8-4-item.pos,item.y*8+8,item.pos,32)
		end	
	elseif item.direction==4 then --right
		if UnitCollision(item.x+4+item.distance*0.5-item.actW*0.5-1,item.y+3-item.actH*0.5,item.actW,item.actH,true) then
			item.activated = true
			PixelCollision(item.x*8+36,item.y*8+8,item.pos,32)
		end	
	end
	local mayPass = true
	if item.activated then
		for j,jtem in ipairs(colorT) do
			if item[jtem]==1 and not keys[j] then -- required but players doesnt have it
				mayPass = false
			end
		end
	end
	if item.activated and mayPass then
		item.pos = item.pos - barrierSpeed
		if item.pos<0 then
			item.pos = 0
		end
	else
		item.pos = item.pos+barrierSpeed
		if item.pos>item.distance*8-boolToNum(item.endStone==1)*16-4 then
			item.pos=item.distance*8-boolToNum(item.endStone==1)*16-4
		end
	end
end


specialCalcT = {}
specialCalcT[8] = CalcPlatform
specialCalcT[9] = CalcBlower
specialCalcT[10] = CalcMagnet
specialCalcT[11] = CalcRotator
specialCalcT[12] = CalcCannon
specialCalcT[13] = CalcRod
specialCalcT[14] = Calc1Way
specialCalcT[15] = CalcBarrier

function InitPlatform(item)
	item.origAmnt = item.amnt
end

function InitBlower(item)
	local coords = {}
	if item.direction==1 then
		coords = {0,item.distance,6,8}
	elseif item.direction==2 then
		coords = {0,0,6,8}
	elseif item.direction==3 then
		coords = {item.distance,0,8,6}
	else
		coords = {0,0,8,6}
	end
	for i=coords[1],coords[1]+coords[3]-1 do
		for j=coords[2],coords[2]+coords[4]-1 do
			brickT[item.x+i][item.y+j][1]=2 -- collision occupied
		end
	end
end

function InitMagnet(item)
	local coords = {}
	if item.direction==1 then
		coords = {0,item.distance,4,6}
	elseif item.direction==2 then
		coords = {0,0,4,6}
	elseif item.direction==3 then
		coords = {item.distance,0,6,4}
	else
		coords = {0,0,6,4}
	end
	for i=coords[1],coords[1]+coords[3]-1 do
		for j=coords[2],coords[2]+coords[4]-1 do
			brickT[item.x+i][item.y+j][1]=2 -- collision occupied
		end
	end
end


function InitRotator(item)
	local coords = {}
	if item.direction==1 then
		coords = {0,item.distance,5,8}
	elseif item.direction==2 then
		coords = {0,0,5,8}
	elseif item.direction==3 then
		coords = {item.distance,0,8,5}
	else
		coords = {0,0,8,5}
	end
	for i=coords[1],coords[1]+coords[3]-1 do
		for j=coords[2],coords[2]+coords[4]-1 do
			brickT[item.x+i][item.y+j][1]=2 -- collision occupied
		end
	end
end

function InitCannon(item)
	local coords = {};local receiverCoords = {}
	if item.direction==1 then
		coords = {0,item.distance,3,5}
		receiverCoords = {0,0,2,3}
	elseif item.direction==2 then
		coords = {0,0,3,5}
		receiverCoords = {0,2+item.distance,2,3}
	elseif item.direction==3 then
		coords = {item.distance,0,5,3}
		receiverCoords = {0,0,3,2}
	else
		coords = {0,0,5,3}
		receiverCoords = {2+item.distance,0,3,2}
	end
	for i=coords[1],coords[1]+coords[3]-1 do
		for j=coords[2],coords[2]+coords[4]-1 do
			brickT[item.x+i][item.y+j][1]=2 -- collision occupied
		end
	end
	for i=receiverCoords[1],receiverCoords[1]+receiverCoords[3]-1 do -- receiver
		for j=receiverCoords[2],receiverCoords[2]+receiverCoords[4]-1 do
			brickT[item.x+i][item.y+j][1]=2 -- collision occupied
		end
	end
end

function InitRod(item)
	item.d1,item.d2=1,1 -- direction of rods, positive is extending
	item.speed1 = math.random(item.speedMin,item.speedMax)
	if item.fixdGap==1 then
		item.d2,item.speed2=-item.d1,item.speed1
		item.pos2=item.distance*8-item.pos1-item.gapSize-24
	else
		item.speed2 = math.random(item.speedMin,item.speedMax)
	end
	local coords = {};local receiverCoords = {}
	if item.direction==1 then
		coords = {0,0,3,3}
		receiverCoords = {0+item.distance,0,3,3}
	elseif item.direction==2 then -- vert
		coords = {0,0,3,3}
		receiverCoords = {0,item.distance,3,3}
	end
	for i=coords[1],coords[1]+coords[3]-1 do
		for j=coords[2],coords[2]+coords[4]-1 do
			brickT[item.x+i][item.y+j][1]=2 -- collision occupied
		end
	end
	for i=receiverCoords[1],receiverCoords[1]+receiverCoords[3]-1 do -- receiver
		for j=receiverCoords[2],receiverCoords[2]+receiverCoords[4]-1 do
			brickT[item.x+i][item.y+j][1]=2 -- collision occupied
		end
	end
end

function Init1Way(item)
	if item.direction==1 then
		for i=0,11 do
			for j=0,3 do
				if not (j>1 and i>3 and i<8) then
					brickT[item.x+i][item.y+j+item.distance][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i = 4,7 do
				for j =0,1 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	elseif item.direction==2 then
		for i=0,11 do
			for j=0,3 do
				if not (j<2 and i>3 and i<8) then
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i = 4,7 do
				for j =4+item.distance-2,4+item.distance-1 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	elseif item.direction==3 then
		for i=0,3 do
			for j=0,11 do
				if not (i>1 and j>3 and j<8) then
					brickT[item.x+i+item.distance][item.y+j][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i=0,1 do
				for j=4,7 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	else -- direction is right
		for i=0,3 do
			for j=0,11 do
				if not (i<2 and j>3 and j<8) then
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i=4+item.distance-2,4+item.distance-1 do
				for j=4,7 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	end
end

function InitBarrier(item)
	if item.direction==1 then
		for i=0,5 do
			for j=0,3 do
				if not (j>1 and i>3) then
					brickT[item.x+i][item.y+j+item.distance][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i = 1,4 do
				for j =0,1 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	elseif item.direction==2 then
		for i=0,5 do
			for j=0,3 do
				if i>1 and j>1 then
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i = 1,4 do
				for j =4+item.distance-2,4+item.distance-1 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	elseif item.direction==3 then
		for i=0,3 do
			for j=0,5 do
				if not (i>1 and j<3) then
					brickT[item.x+i+item.distance][item.y+j][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i=0,1 do
				for j=0,3 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	else
		for i=0,3 do
			for j=0,5 do
				if not (i<2 and j>3) then
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
		if item.endStone==1 then
			for i=4+item.distance-2,4+item.distance-1 do
				for j=1,4 do
					brickT[item.x+i][item.y+j][1]=2 -- collision occupied
				end
			end
		end
	end
	
	item.activated = false
end

initSpecial = {}
initSpecial[8]=InitPlatform
initSpecial[9]=InitBlower
initSpecial[10]=InitMagnet
initSpecial[11]=InitRotator
initSpecial[12]=InitCannon
initSpecial[13]=InitRod
initSpecial[14]=Init1Way
initSpecial[15]=InitBarrier

function drawInterfaceBox(x,w)
	gfx.drawline(x,hudY+1,x+w,hudY+1,interfaceBoxUpperClr)
	gfx.drawline(x,hudY+1,x,hudY+14,interfaceBoxUpperClr)
	gfx.drawline(x+w,hudY+2,x+w,hudY+14,interfaceBoxLowerClr)
	gfx.drawline(x+1,hudY+14,x+w,hudY+14,interfaceBoxLowerClr)
	gfx.drawrect(x+1,hudY+2,w-1,13,black)
end

function checkCam()
	if camPos[1]>levelProps.sizeX-59 then
		camPos[1] = levelProps.sizeX-59
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
	camPos = {homeBase.x+math.floor(homeBase.w*0.5)-30,homeBase.y+3-16,0,0} --x,y,subx,suby
	checkCam()
	flying = false
	vx,vy,planeRot,thrust = 0,0,18,0 -- thrust only 0 or 1; use thrustPower to adjust.
	CalcPlaneColCoords()
	explodeI,collision = nil,false
	fuel = levelProps.fuel
	landedTimer,landedAt = 0,-1
end
function InitGame(path)
	kill = nil
	LoadFile(path)
	curGamePath = path
	OptimizeLevel()
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
	barrierSpeed = 2
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
end

function CalcGameCam()
	printf("camBefore",camPos[1].." "..camPos[2].." "..camPos[3].." "..camPos[4])
	if planePos[1]>camPos[1]+30 then
		camPos[3] = camPos[3] + planePos[1]-(camPos[1]+30)
	elseif planePos[1]<camPos[1]+30 then 
		camPos[3] = camPos[3] - (camPos[1]+30-planePos[1])
	end
	if camPos[3]>7 then
		local addUnits = math.floor(camPos[3]*0.125)
		camPos[1] = camPos[1]+addUnits
		camPos[3] = camPos[3]-addUnits*8
	elseif camPos[3]<0 then
		--printf("before",planePos[1],planePos[3])
		local substUnits = -math.floor(camPos[3]*0.125)
		camPos[1] = camPos[1]-substUnits
		camPos[3] = 8+(camPos[3]+(substUnits-1)*8)
		--printf("after",planePos[1],planePos[3])
	end
	if camPos[1]<1 then
		camPos[1],camPos[3]=1,0
	elseif camPos[1]+59>=levelProps.sizeX then
		camPos[1],camPos[3] = levelProps.sizeX-59,0
	end
	
	if planePos[2]>camPos[2]+16 then
		camPos[4] = camPos[4] + planePos[2]-(camPos[2]+16)
	elseif planePos[2]<camPos[2]+16 then 
		camPos[4] = camPos[4] - (camPos[2]+16 - planePos[2])
	end
	if camPos[4]>7 then
		local addUnits = math.floor(camPos[4]*0.125)
		camPos[2] = camPos[2]+addUnits
		camPos[4] = camPos[4]-addUnits*8
	elseif camPos[4]<0 then
		--printf("before",planePos[1],planePos[3])
		local substUnits = -math.floor(camPos[4]*0.125)
		camPos[2] = camPos[2]-substUnits
		camPos[4] = 8+(camPos[4]+(substUnits-1)*8)
		--printf("after",planePos[1],planePos[3])
	end
	if camPos[2]<1 then
		camPos[2],camPos[4]=1,0
	elseif camPos[2]+31>levelProps.sizeY or (camPos[2]+31==levelProps.sizeY and camPos[4]>0) then
		camPos[2],camPos[4] = levelProps.sizeY-31,0
	end
	printf("camAfter",camPos[1].." "..camPos[2].." "..camPos[3].." "..camPos[4])
end

function CalcPlaneColCoords()
	colT = nil
	colT = {}
	colT[1] = (math.cos(-planeRot/12*pi)*10+11+planePos[3]) -- tip x
	colT[2] = (math.sin(planeRot/12*pi)*10+11+planePos[4]) -- tip y
	colT[3] = (math.cos((-planeRot/12-0.75)*pi)*12+11+planePos[3]) -- right base x
	colT[4] = (math.sin((planeRot/12+0.75)*pi)*12+11+planePos[4]) -- right base y
	colT[5] = (math.cos((-planeRot/12+0.75)*pi)*12+11+planePos[3]) -- left base x
	colT[6] = (math.sin((planeRot/12-0.75)*pi)*12+11+planePos[4]) -- left base y
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
	printf("plane".." "..planePos[1].." "..planePos[2].." "..planePos[3].." "..planePos[4].." "..vx.." "..vy)
	
	-- brick collision
	collision = false
	CalcPlaneColCoords()
	for i=1,5,2 do
		if brickT[colBT[i]][colBT[i+1]][1]>1 then
			print("collision",i,colBT[i],colBT[i+1])
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
			end
		end
		DecreaseLife()
	end
end

function DecreaseLife()
	if extras[2]==0 then
		local result = nil
		while not result do 
			result = MenuBR("GAME OVER!",{{"Restart?",1,{"yes","no"},val=1}})
		end
		if result[1].val==1 then
			ResetGame()
		else
			kill = 1
		end
	else
		for i=0,10 do -- blink life in and out
			RenderGame(true)
			if i%2==0 then
				pgeDraw(5+(extras[2]-1)*25,5,23,23,46,414,23,23,0,255)
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

function RenderGame()
	bgOffX=nil;bgOffY=nil
	bgOffX = math.floor((camPos[1]*8+camPos[3] % 128)*0.25)
	bgOffY = math.floor((camPos[2]*8+camPos[4] % 128)*0.25)
	for i=0,15 do -- bg
		for j = 0,8 do
			pgeDraw(i*32-bgOffX,j*32-bgOffY,32,32,levelProps.bg*32,60,32,32,0,255)
		end
	end

	--gfx.setDitherPattern(0.81, gfx.image.kDitherTypeBayer8x8)
	--gfx.fillRect(0,0,400,240)

	sprite:setInverted(false)
	gfx.setColor(gfx.kColorBlack)

	for i,item in ipairs(specialT) do -- special blocks
		scrX,scrY = (item.x-camPos[1])*8-camPos[3],(item.y-camPos[2])*8-camPos[4]
		if item.x+item.w>=camPos[1] and item.x<=camPos[1]+61 and item.y+item.h>=camPos[2] and item.y<camPos[2]+33 then
			specialRenders[item.sType-7](item)
		end
	end
	maxI=nil;maxJ=nil
	if camPos[3]==0 then 
		maxI = camPos[1]+59
	else
		maxI = camPos[1]+60
	end
	if camPos[4]==0 then 
		maxJ = camPos[2]+31
	else
		maxJ = camPos[2]+32
	end
	
	RenderLineHoriz(maxI)
	RenderLineVert(maxJ)
	
	local i = camPos[1]+1
	while i<=maxI do -- bricks
		local j = camPos[2]+1
		while j<=maxJ do
			local curBrick = brickT[i][j]
			if not curBrick then printf("curBrick",i,j,camPos[1],camPos[2]) end
			--if curBrick[1]~=0 then printf(curBrick[2],curBrick[3],curBrick[4],curBrick[5]) end
			if curBrick[1]>2 and curBrick[4]==0 and curBrick[5]==0 then
				if curBrick[1]<7 then --colors
					pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],curBrick[2]*8,curBrick[3]*8,(curBrick[1]-3)*48+sumT[curBrick[2]],sumT[curBrick[3]],curBrick[2]*8,curBrick[3]*8,0,255)
					--printf("color:",(i-camPos[1])*8,(j-camPos[2])*8,curBrick[2]*8,curBrick[3]*8,(curBrick[1]-3)*48+sumT[curBrick[2]],sumT[curBrick[3]],curBrick[2]*8,curBrick[3]*8)
				else -- concrete
					pgeDraw((i-camPos[1])*8-camPos[3],(j-camPos[2])*8-camPos[4],8*curBrick[3],8*curBrick[3],240+curBrick[2]*curBrick[3]*8,greySumT[curBrick[3]],curBrick[3]*8,curBrick[3]*8,0,255)
				end
			end
			j = j + curBrick[3]-curBrick[5]
			curBrick = nil
		end
		i = i + 1
	end
	
	pgeDraw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3],(planePos[2]-camPos[2])*8+planePos[4]-camPos[4],23,23,planeRot%16*23,391+(boolToNum(planeRot>15)*2-thrust)*23,23,23) -- plane

	gfx.setColor(hudBGClr)
	gfx.fillRect(0,hudY,400,16)
	
	--explosion
	if collision and not Debug then
		pgeDraw((planePos[1]-camPos[1])*8+planePos[3]-camPos[3]+explodeX,(planePos[2]-camPos[2])*8+planePos[4]-camPos[4]+explodeY,23,23,explodeJ*23,489,23,23)
	end
	
	--interface
	
	pgeDraw(1,hudY+1,28,14,232,314,28,14) -- remain freight stat
	drawInterfaceBox(30,106)
	local freightPosCount = 0
	for i,item in ipairs(remainingFreight) do
		for j=0,math.fmin(item-1,7) do
			pgeDraw(32+freightPosCount*13,hudY+3,12,12,64+i*16,346,16,16)
			freightPosCount = freightPosCount + 1
		end
	end
	
	local planeFreightX = 147
	pgeDraw(planeFreightX,hudY+1,28,14,hudY+4,314,28,14) -- planeFreight stat
	drawInterfaceBox(planeFreightX+29,14*extras[3])
	for i,item in ipairs(planeFreight) do
		pgeDraw(planeFreightX+31+(i-1)*13,hudY+3,12,12,80+item[1]*16,346,16,16)
	end
	
	local keysX = 220
	pgeDraw(keysX,hudY+1,28,14,344,314,28,14) -- keys
	drawInterfaceBox(keysX+30,50)
	for i=1,4 do
		if keys[i] then
			pgeDraw(keysX+32+(i-1)*12,hudY+3,12,12,185+(frameCounter % 7)*16,414+(i-1)*16,16,16)
		end
	end
	
	local fuelX = 300
	pgeDraw(fuelX+2,hudY+1,28,14,316,314,28,14) -- fuel stat
	drawInterfaceBox(fuelX+32,48)
	local fuelW = math.round(44*fuel/6000/4)*4
	pgeDraw(fuelX+34,hudY+4,fuelW,9,231,328,fuelW,9)
	
	for i=0,extras[2]-1 do -- lives
		pgeDraw(5+i*25,5,23,23,46,414,23,23,0,180)
	end
	
	drawInterfaceBox(382,75) -- Time
	menuFont:print(384,hudY+4,green,TimeString(frameCounter*0.05).."/"..lMin..":"..lSec)
		
	local warnX = 460
	
	if math.abs(vx) > landingTolerance[1] or vy > landingTolerance[2] then --red
		pgeDraw(warnX,hudY,16,16,165,461,16,16)
	elseif math.abs(vx) > landingTolerance[1]-1 or vy > landingTolerance[2] - 1 then --yellow
		pgeDraw(warnX,hudY,16,16,149,461,16,16)
	else -- green
		pgeDraw(warnX,hudY,16,16,133,461,16,16)
	end
	
	if Debug then
		if collision then
			pgeDraw(470,hudY,8,8,64,338,8,8)
		end
		--- plane collision
		local colOffX = (planePos[1]-camPos[1])*8-camPos[3]
		local colOffY = (planePos[2]-camPos[2])*8-camPos[4]
		gfx.drawline(colOffX+colT[1],colOffY+colT[2],colOffX+colT[3],colOffY+colT[4],red)
		gfx.drawline(colOffX+colT[3],colOffY+colT[4],colOffX+colT[5],colOffY+colT[6],red)
		gfx.drawline(colOffX+colT[5],colOffY+colT[6],colOffX+colT[1],colOffY+colT[2],red)
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

function GameBR(path)
	InitGame(path)
	BGRender = RenderGame
	while running() and kill== nil do
		CalcTimeStep()
		RenderGame()
		delayMicroSecs = math.max((0.048-frameTime)*1000000,0)
		if Debug then -- refactor only run the simulation when any button is pressed?
			repeat
				controls.update()
				if pressedany() or math.abs(controls.analogy())>40 or math.abs(controls.analogx())>40 then
					break
				end
				delay(1000*20)
			until not running()
		end
		if pressed(cross+circle) and Debug then
			kill = 1
		elseif pressed(cross) or pressed(circle) then
			if fuel>0 then
				thrust = 1
				fuel = fuel - burnRate
				if not flying then 
					vx = 0
					vy = 0
				end
				flying = true
				vx = vx + math.cos(-planeRot/12*pi)*(thrustPower+extras[1]*turboPower)
				vy = vy - math.sin(-planeRot/12*pi)*(thrustPower+extras[1]*turboPower)
				if Sounds and not thrust_sound:isplaying() then thrust_sound:play() end
			else
				thrust = 0
			end
		else 
			thrust = 0
			if Sounds then thrust_sound:stop() end
		end
		if pressed(up) or pressed(ltrigger+rtrigger) or controls.analogy()<-100 then
			if planeRot~=18 then
				if planeRot>18 or planeRot<6 then
					planeRot = planeRot-1
				else
					planeRot = planeRot+1
				end
			end
			if planeRot<0 then planeRot = 23 end
		elseif pressed(left) or pressed(ltrigger) or controls.analogx()<-40 then
			if flying then
				planeRot = planeRot - 1
				if planeRot<0 then
					planeRot = 23
				end
			end
		elseif pressed(right) or pressed(rtrigger) or controls.analogx()>40 then
			if flying then 
				planeRot = planeRot + 1
				planeRot = planeRot % 24
				
			end
		elseif pressed(triangle) then
			local path = "scr"..math.random(1000,9999)..".png"
			gfx.screenshot(path)
			ShowMessage("Screenshot","Saved to "..path) 
--		elseif pressed(square) then
--			Debug = not Debug
--			delay(50*10000)
		elseif pressed(select) then -- settings menu
			Result = MenuBR("Settings Menu",gameSettings)
			if Result then
				if Result[8].val==1 then
					loadScript("defGameSets.lua")
				else
					for i,item in ipairs(Result) do -- apply changes
						assert(loadstring("gameSettings["..i.."].val".."="..item.val))()
					end
				end
				ApplyGameSets()
				table.save(Result,"gameSettings.lua")
			end
			delay(500*1000)
		elseif pressed(start) then -- game pause menu
			actionResult = MenuBR("Pause Menu",{{"Action",1,{"Resume","Restart","Quit"},val=1}})
			if actionResult then
				if actionResult[1].val==2 then -- restart
					ResetGame()
					--kill=1
				elseif actionResult[1].val==3 then -- quit
					kill = 1
				end
			end
		end
	end
	wav.stopall()
	print("v",collectgarbage("count"))
	brickT = nil
	specialT = nil
	ForceGarbageCollect()
	print("n",collectgarbage("count"))
	
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
	table.insert(curScores,{utils.nickname():sub(1,10),math.floor(frameCounter/20)})
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
	gfx.drawrect(175,60,125,45+(#data+2)*12-3,menuBGClr)
	for i=0,1 do
		for j = 0,1 do
			pgeDraw(172+i*120,55+j*35+j*(#data+2)*12,16,16,5-i*4,464-j*4,23,23)--corner blocks
		end
	end
	pgeDraw(298,71,7,14+(#data+2)*12+5,500,213,11,14+(#data+2)*12+5) --right rod
	pgeDraw(175,71,7,14+(#data+2)*12+5,500,213,11,14+(#data+2)*12+5) --left rod
	pgeDraw(188,98+(#data+2)*12-2,104,7,173,80,104,11) -- bottom rod
	pgeDraw(188,59,104,7,173,80,104,11) -- top rod
	local menucurX,menucurY
	
	menuFont:printcenter(70,black,"Level Complete!")
	menuFont:printcenter(82,black,"Your time: "..TimeString(frameCounter*0.05))
	for i,item in ipairs(data) do 
		menuFont:print(189,91+i*12,black,i..".") -- rank
		menuFont:print(200,91+i*12,black,item[1])
		menuFont:print(263,91+i*12,black,TimeString(item[2]))
	end
	
	if newGamePath then
		pgeDraw(188,85+(#data+2)*12,10,10,84,463,10,10)
		menuFont:print(197,85+(#data+2)*12,black,"Next")
	end
	pgeDraw(223,85+(#data+2)*12,10,10,123,463,10,10)
	pgeDraw(263,85+(#data+2)*12,10,10,96,463,10,10)
	menuFont:print(232,85+(#data+2)*12,black,"Restrt")
	menuFont:print(272,85+(#data+2)*12,black,"Quit")
	--pgeDraw(187,menucurY,12,11,0,368,20,20) -- cursor
end
