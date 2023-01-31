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
		
		player:updatePosition(x, y, vx, vy, fr, m)
		player.ef = nil
	end
	
	
	
	if down then
		if player.onDialog then
			if key == 32 then
				player:updateDialog(0)
			end
		else
			if key == 3 then
				player:talkToNpc(x, y)
			else
				if player.drawing.active then
					if key == 32 then
						player:setKeepDrawing(nil)
					elseif key == 88 then -- [Z]
						player:undoDrawingAction()
					end
				else
					if key == 32 then
						player:placeLamp(x, y)
						player:psst(false)
					end
				end
				if key > 48 and key <= 57 then
					player:setSelectedSlot(key - 48, false)
				else
					if player.interface then
						if key ~= 3 then
							player:showLampInterface(false)
						end
					end
				end
			end
			
			if key == 69 then -- [E]
				player:showInventory(not player.items.displaying)
			end
		end
	end
end

function eventMouse(playerName, x, y)
	local player = playerList[playerName]
	
	if player then
		if player.drawing.active then
			player:registerPoint(x, y)
		elseif player.crafting.active then
			player:closeCrafting()
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

	if eventName == "inv" then
		local id = textAreaId % 10
		player:setSelectedSlot(id, player.crafting.active)
	elseif not player:getData("finished") then
		if eventName == "craft_action" then
			local id = textAreaId % 10
			if player.crafting.active then
				local re = false
				if player.crafting.size == 3 then
					if player.crafting[4].id == 9 then
						re = true
						player:initDrawing()
					end
				end
			
				if not re then
					player:pushItem(id, false)
					if id == player.crafting.size + 1 and player.crafting.size == 5 then
						player:closeCrafting()
						player:showLampInterface(true)
					end
				end
			end
		elseif eventName == "craft_a_lamp" then
			player:setCrafting(5)
		elseif eventName == "craft_a_lamp_draw" then
			player:setCrafting(3)
		elseif eventName == "draw_send" then
			player:finishDrawing()
		elseif eventName == "draw_undo" then
			player:undoDrawingAction()
		elseif eventName == "draw_tip" then
			player:newDrawingTip()
		end
	end
	
	if eventName == "close" then
		ui.removeTextArea(textAreaId, playerName)
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
		elseif command == "give" then
			if tonumber(args[1]) and args[1] < 10 then
				player:insertItem(args[1], tonumber(args[2]) or 1)
			end
		elseif command == "seeHan" then
			if #args == 0 then
				HanPreview:hide(player.name)
			else
				local hanId = table.remove(args, 1)
				
				local xc, yc = player:getUiCenterFromMap()
				if #args == 0 then
					args = nil
				end
				HanPreview:show(player.name, hanId, xc, yc, args)
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
			player:setData(args[1], args[2], true)
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
	--tfm.exec.chatMessage(("%s &gt; %s"):format(playerName, npcName))
	system.openEventShop("evt_hoppy_cny", playerName)
end

function eventPlayerBonusGrabbed(playerName, bonusId)
	local player = playerList[playerName]
	
	if player then
		player:collectMapItem(bonusId%100)
	end
end

do
	local z = {
		[1] = {
			x1 = 0,
			x2 = 280,
			
			y1 = 0,
			y2 = 330
		},
		[2] = {
			x1 = 210,
			x2 = 834,
			y1 = 247,
			y2 = 535
		},
		[3] = {
			x1 = 1005,
			y1 = 0,
			
			x2 = 1333,
			y2 = 409
		}
	}
	function eventEmotePlayed(playerName, emoteType, emoteParam)
		local player = playerList[playerName]
		
		if player then
			if emoteType == tfm.enum.emote.sleep then
				for i, s in ipairs(z) do
					if (player.x >= s.x1) and (player.x <= s.x2) then
						if (player.y >= s.y1) and (player.y <= s.y2) then
							player.ef = s
							player.ef.t = os.time() + 1000
							break
						end
					end
				end
			else
				player.ef = nil
			end
		end
	end
end