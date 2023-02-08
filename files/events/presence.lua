function eventNewPlayer(playerName, override)
	if override or (not isEventLoaded) then
		playerList[playerName] = Player:new(playerName)
		system.loadPlayerData(playerName)
		if override then
			tfm.exec.respawnPlayer(playerName)
		end
	end
end

function eventPlayerLeft(playerName)
	playerList[playerName] = nil
end

function eventPlayerDataLoaded(playerName, rawdata)
	local player = playerList[playerName]
	if player then
		player:init(rawdata)
	end
end

function eventPlayerDied(playerName)
	tfm.exec.respawnPlayer(playerName)
end

function eventFileLoaded(fileId, fileData)
	if fileId == "93" then
		local time = os.date("*t", os.time()/1000)
		roomList[1] = ("%s - %s"):format(tfm.get.room.name, ("%d:%d:%d"):format(time.hour, time.min, time.sec))
		for line in fileData:gmatch("[^\n]+") do
			roomList[#roomList + 1] = line
		end
		
		system.saveFile(table.concat(roomList, "\n", 1, math.min(128, #roomList)), 93)
	end
end