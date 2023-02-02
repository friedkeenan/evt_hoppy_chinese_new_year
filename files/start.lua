do	
	for playerName, playerData in next, tfm.get.room.playerList do
		eventNewPlayer(playerName)
	end
	
	-- Fast loop
	local interval = 500
	local interpolation = 10
	local SUBCYCLES = interval / (interval / interpolation)
	local diftime = interval / SUBCYCLES
	for i=0, SUBCYCLES-1 do
		system.newTimer(function(id)
			system.newTimer(function(id)
					eventFastLoop(diftime)
			end, interval, true)
		end, interval + (diftime * i), false)
	end
	
	system.loadFile(93)
end

tfm.exec.newGame(xml, false)