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