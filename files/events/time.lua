function eventLoop(elapsed, remaining)
	Timer.handle()
	
	for playerName, player in next, playerList do
		local obj = tfm.get.room.playerList[playerName]
		if obj then
			player:updatePosition(obj.x, obj.y, obj.vx, obj.vy)
		end
	end
	
	local timeMargin = 5000
	
	if remaining < timeMargin and isEventLoaded then
		if debugMode then
			if remaining > (timeMargin - 750) then
				tfm.exec.chatMessage("<R>WARNING !</R> <J>The event is on <r><b>debugMode</b></R>!!</J>")
			end
		else
			if not noTimeLeft then
				for playerName, player in next, playerList do
					tfm.exec.freezePlayer(playerName, true, true)
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