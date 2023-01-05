function eventKeyboard(playerName, key, down, x, y, vx, vy)
	if noTimeLeft then return end
	local player = playerList[playerName]
	
	if not player then return end
	
	player.keys[key] = down
	
	local fr, m
	
	if key < 4 then
		if key % 2 == 0 then
			m = down
			fr = (key == 2)
		end
		
		if key == 1 then
			m = down
		end
	end
	
	player:updatePosition(x, y, vx, vy, fr, m)
	
	if down then
		if player.onDialog then
			if key == 32 then
				player:updateDialog(0)
			end
		end
	end
end

function eventTextAreaCallback(textAreaId, playerName, eventName)
	if noTimeLeft then return end
	local player = playerList[playerName]
	if not player then return end
	
	local args = {}
	
	for arg in eventName:gmatch("[^%-]+") do
		args[#args + 1] = tonumber(arg) or arg
	end
	
	local eventCommand = table.remove(args, 1)
	
	if eventName == "craftable" then
		tfm.exec.chatMessage("craft-table", playerName)
	elseif eventName == "items" then
		tfm.exec.chatMessage("itens", playerName)
	end
end

function eventChatCommand(playerName, message)
	if noTimeLeft then return end
	local player = playerList[playerName]
	if not player and not admins[playerName] then return end
	
	local args = {}
	local val
	local command

	for arg in message:gmatch("%S+") do
		if arg == "nil" then
			val = nil
		elseif (arg == "true" or arg == "false") then
			val = (arg == "true")
		else
			val = tonumber(arg) or arg
		end
		args[#args + 1] = val
	end

	command = table.remove(args, 1)

	local answer = function(msg)
		for a, _ in next, admins do
			tfm.exec.chatMessage(tostring(msg), a)
		end
	end
	
	if admins[playerName] then
		if command == "admin" then
			for i=1, #args do
				admins[args[i]] = true
				answer(args[i] .. "has been set as admin.")
			end
		elseif command == "join" then
			if not player then
				playerList[playerName] = Player.new(playerName)
				system.loadPlayerData(playerName)
				tfm.exec.respawnPlayer(playerName)

				answer("Joining to the event...")
			else
				answer("You already exist")
			end
		elseif command == "save" then
			player:saveData()
			answer("Data saved")
		elseif command == "get" then
			local p
			if #args == 2 then
				p = playerList[args[2]] or player
			else
				p = player
			end
			answer(p:getData(args[1]))
		elseif command == "set" then
			local p
			if #args == 3 then
				p = playerList[args[3]] or player
			else
				p = player
			end
			player:setData(args[1], args[2])
		elseif command == "removealldata" then
			player:resetAllData()
			answer("Data removed")
		elseif command == "lang" then
			player.language = args[1] or "en"
			answer("Language changed to " .. player.language:upper())
		elseif command == "time" then
			tfm.exec.setGameTime(args[1], true)
			answer("Time set to " .. args[1] .. " seconds.")
		end
	end
end

function eventTalkToNPC(playerName, npcName)
	tfm.exec.chatMessage(("%s &gt; %s"):format(playerName, npcName))
	system.openEventShop("", playerName)
end