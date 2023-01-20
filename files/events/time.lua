local time_count = 0
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
			end
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
					tfm.exec.freezePlayer(playerName, true, true)
					player:closeCrafting()
				end
			end
			
			noTimeLeft = true
			
			if remaining <= 0 then
				system.exit()
			end
		end
	else
		if not debugMode then
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