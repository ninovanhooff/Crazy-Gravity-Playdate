import "settings.lua"
import "drawUtil.lua"
import "specialsView.lua"
import "specialsViewModel.lua"
import "gameView.lua"

local unFlipped <const> = playdate.graphics.kImageUnflipped


colorT = {"red","green","blue","yellow"}
sumT = {0,8,24}
greySumT = {-1,56,32,0} -- -1:unused




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

function ApplyGameSets()
	burnRate = gameSettings[7].val -- amount of fuel each frame
	gravity,drag = gameSettings[1].val,gameSettings[2].val --add,mult per frame!!
	landingTolerance = {gameSettings[5].val*0.5,gameSettings[5].val} -- max vx,vy
	thrustPower,turboPower = gameSettings[6].val,0.2
	blowerStrength,magnetStrength = gameSettings[3].val,gameSettings[4].val
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
