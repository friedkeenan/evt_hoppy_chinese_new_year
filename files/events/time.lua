local time_count = 0
local ptt = {21, 43, 44, 51, 13}
function ptt:random()
	return self[math.random(#self)]
end
function eventLoop(elapsed, remaining)
	time_count = time_count + 500
	Timer.handle()
	
	for playerName, player in next, playerList do
		local obj = tfm.get.room.playerList[playerName]
		if obj then
			player:updatePosition(obj.x, obj.y, obj.vx, obj.vy)
		end
		
		if time_count%1000 == 0 then
			if player.drawing.active then
				if player.drawing.keep_drawing then
					player:playSound("deadmaze/objectif.mp3", 100, nil, nil)
				end
				
				if player.drawing.tipTimestamp then
					if os.time() > player.drawing.tipTimestamp then
						player:newDrawingTip()
					end
				end
			end
			
			if player.ef then
				if os.time() > player.ef.t then
					local c = player.ef
					local list = {}
					local dp = function(...)
						list[#list + 1] = {...}
					end
					local xs = 25
					local ys = 55
					for x=1, math.ceil(c.x2 - c.x1)/xs do
						for y=1, math.ceil(c.y2 - c.y1)/ys do
							local d = (math.random(2) == 1 and tfm.exec.displayParticle or dp)
							d(
								ptt:random(),
								c.x1 + ((x-1) * xs) + math.random(-xs/2, xs/2),
								c.y1 + ((y-1) * ys) + math.random(-ys/2, ys/2),
								0,
								math.random(2, 12) / 10,
								0,
								-0.005,
								playerName
							)
						end
					end
					Timer.new(500, false, function()
						for _, v in ipairs(list) do
							tfm.exec.displayParticle(v[1], v[2], v[3], 0, v[5], 0, v[7], playerName)
						end
					end)
				end
			end
		end
		
		if time_count%10000 == 0 then
			player:saveData()
		end
	end
	
	tfm.exec.stopMusic("musique", nil) -- Regular game music
	tfm.exec.stopMusic("magasin", nil) -- Shop music
	local timeMargin = 5000
	
	if remaining < timeMargin and isEventLoaded then
		if debugMode then
			if remaining > (timeMargin - 575) then
				tfm.exec.chatMessage("<R>WARNING !</R> <J>The event is on <r><b>debugMode</b></R>!!</J>")
			end
		else
			if not noTimeLeft then
				for playerName, player in next, playerList do
					player:closeCrafting()
					player:closeDrawing()
					tfm.exec.freezePlayer(playerName, true, true)
				end
			end
			
			noTimeLeft = true
			
			if remaining <= 0 then
				system.exit()
			end
		end
	else
		if debugMode then
			if noTimeLeft then
				for playerName, player in next, playerList do
					tfm.exec.freezePlayer(playerName, false, false)
				end
				
				noTimeLeft = false
			end
		end
	end
end

function eventFastLoop(dt)
	for _, player in next, playerList do
		if player.onDialog then
			player:updateDialog(2)
		end
	end
end