function Player:new(playerName)
	local info = tfm.get.room.playerList[playerName] or {}
    local this = setmetatable({
		name = playerName,
		
		x = 0,
		y = 0,
		vx = 0,
		vy = 0,
		
		progress = {},
		
		language = tfm.get.room.community,
		gender = info.gender or 0,
		
		isFacingRight = true,
		isMoving = false,
		
		latency = 0,
		
		keys = {},
		
		items = {
			displaying = false,
			selected = 0,
			coverId = -1
		},
		lampsIds = {},
		drawing = {
			active = false,
			lines = {},
			points = {},
			keepDrawingId = 0,
			finished = false,
			consecutive_points = 0,
			consecutive_previous = 0,
			keep_drawing = false
		},
		mapItems = {},
		crafting = {
			active = false
		},
		Npc = {
			x = 0,
			y = 0,
			isFacingRight = true
		}
	}, self)
	
	this.__index = self
	
	do
		tfm.exec.lowerSyncDelay(this.name)
		
		for _, keyId in next, keys do
			system.bindKeyboard(this.name, keyId, true, true)
			system.bindKeyboard(this.name, keyId, false, true)
			this.keys[keyId] = false
		end
		
		system.bindMouse(this.name, true)
	end

	return this
end

function Player:playBackgroundMusic(play)
	if play then
		self:stopMusic("musique", false)
		self:stopMusic("magasin", false)
		local music = {
			"cite18/musique/camp1.mp3",
			"cite18/musique/museum.mp3",
			"cite18/musique/museum2.mp3"
		}
		
		local track = music[math.random(#music)]
			
		self:playMusic(track, "Main", 32, true, true)
		self.playingMusic = true
	else
		self:stopMusic("Main", true)
		self.playingMusic = false
	end
end

function Player:init(rawdata, reset)
    reset = reset or false
	if rawdata then
		local moduleData = data.getFromModule(rawdata, "HCNY")
		self.progress = data.decode(moduleData)
		self.dataFile = rawdata
	end
	
	do
		for i=1, 9 do
			self.progress["i" .. i] = self:getData("i" .. i) or 0
		end
		
		self.progress.hans = self.progress.hans or 0
		self.progress.inst = self.progress.inst or 0
		self.progress.finished = self.progress.finished or false
		self.progress.started = self.progress.started or false
	end
	
	self:initInventory()
	
	tfm.exec.addNPC("Mirko", {
		title = 468,
		look = "210;23_FFFFFF+FFFFFF+FFFFFF,0,11_FFFFFF+FFFFFF,45,69_10101+F9FFFF+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+FFEFD8+FFEFD8,49_FFFFFF+FFFFFF+FFFFFF+FFFFFF,0,23,0",
		x = 311,
		y = 844,
		female = true,
		lookAtPlayer = true,
		interactive = true
	}, self.name)

	self:setLampsDisplay(true)
	
	
	if self:getData("finished") then		
		self:placeMainNpc("toptree")
		-- tfm.exec.giveConsumables(self.name, "", 10) -- GIVE TRUFFLE
	else
		self:setMapItems(true)
		self:showLampInstallPlace(true)
		
		if self:getData("started") then
			self:placeMainNpc("village")
		else
			self:placeMainNpc("entrance")
		end
		
		self:psst(true, "psst")
		self:truffleExclamation(true)
	end
	
	self:playBackgroundMusic(true)
	
	system.giveAdventurePoint(self.name, "evt_hoppy_cny_rounds", "1")
end

function Player:saveData()
	if self.dataFile then
		local rawdata = data.encode(self.progress)
		self.dataFile = data.setToModule(self.dataFile, "HCNY", rawdata)

		system.savePlayerData(self.name, self.dataFile)
	end
end

function Player:resetDefaultData()
	self:setData("hans", 0, false)
	self:setData("inst", 0, false)
	self:setData("finished", false, false)
	
	self:saveData()
end


function Player:resetAllData()
	for i=1, 9 do
		self:setData("i" .. i, 0, flase)
	end
	
	self:setData("hans", 0, false)
	self:setData("inst", 0, false)
	self:setData("finished", false, false)
	
	self:saveData()
end

function Player:setData(key, value, write)
	self.progress[key] = value
	if write then
		self:saveData()
	end
end

function Player:getData(key)
	return self.progress[key]
end

function Player:setVignette(coverage, scale, fadeIn)
	coverage = coverage or 1

	local old = self.vignetteId or -1

	self.vignetteId = tfm.exec.addImage("183b987c56f.png", "~1", 400, 200, self.name, scale, scale, 0, coverage, 0.5, 0.5, fadeIn)

	tfm.exec.removeImage(old, fadeIn)
end

function Player:removeVignette(fadeOut)
	if self.vignetteId then
		self.vignetteId = tfm.exec.removeImage(self.vignetteId, fadeOut)
	end
end

function Player:hideOffscreen(hide, color)
	if hide == false then
		for i=1901, 1904 do
			ui.removeTextArea(i, self.name)
		end
	else
		color = color or 0x010101

		ui.addTextArea(1901, "", self.name, -1205, -400, 1200, 1200, color, color, 1.0, true)
		ui.addTextArea(1902, "", self.name, 805, -400, 1200, 1200, color, color, 1.0, true)

		ui.addTextArea(1903, "", self.name, -400, -1200, 1200, 1200, color, color, 1.0, true)
		ui.addTextArea(1904, "", self.name, -400, 405, 1200, 1200, color, color, 1.0, true)

		--self:setMute(self.ambienceMuted,true)
	end
end

function Player:setForeground(display, color, alpha, uiLayer)
	if display then
		local x, y, w, h
		if uiLayer then
			x, y, w, h = -1200, -1200, 3200, 2800
		else
			x, y, w, h = -1200, -1200, 20000, 19800
		end

		ui.addTextArea(9696, "", self.name, x, y, w, h, color, color, alpha, uiLayer)
	else
		ui.removeTextArea(9696, self.name)
	end
end

function Player:updatePosition(x, y, vx, vy, facingRight, isMoving)
	local f, m
	self.x = x or self.x
	self.y = y or self.y
	self.vx = vx or self.vx
	self.vy = vy or self.vy

	if facingRight ~= nil then
		self.isFacingRight = facingRight
		f = true
	end

	if isMoving ~= nil then
		local k = self.keys
		self.isMoving = isMoving or k[0] or k[1] or k[2]
		m = true
	end

	self:handleNear(self.x, self.y, self.vx, self.vy)
	
	if f or m then
		self:setHoldingItem(true)
	end
end

function Player:handleNear(x, y, vx, vy)	
	if self.onDialog and math.pythag(x, y, self.Npc.x, self.Npc.y) > 75 then
		self:closeDialog()
	end
end

function Player:setMapItems(set)
	if set then
		self.mapItems = {}
		
		local item = {}
		for i=1, 7 do
			item = enum.items[i]
			local pos = item.pos[math.random(#item.pos)]
			
			tfm.exec.addBonus(0, pos.x, pos.y, 100 + i, 0, false, self.name)
			local id = tfm.exec.addImage(item.sprite, "_50", pos.x, pos.y, self.name, 0.375, 0.375, 0, 1.0, 0.5, 0.5, false)
			self.mapItems[i] = {
				x = pos.x,
				y = pos.y,
				imageId = id,
				active = true
			}
		end
	else
		if self.mapItems then
			for index, Item in ipairs(self.mapItems) do
				Item.active = false
				tfm.exec.removeBonus(100 + index, self.name)
				if Item.imageId then
					Item.imageId = tfm.exec.removeImage(Item.imageId, false)
				end
			end
		end
	end
end

function Player:collectMapItem(itemId)
	local mi = self.mapItems[itemId]
	if mi and mi.active then
		self:insertItem(itemId, 1)
		system.giveAdventurePoint(self.name, "evt_hoppy_cny_materials", "1")
		
		-- Graphic Effects
		
		tfm.exec.removeBonus(100 + itemId, self.name)
		if mi.imageId then
			mi.imageId = tfm.exec.removeImage(mi.imageId, false)
		end
		
		for i=1, math.random(4, 6) do
			tfm.exec.displayParticle(tfm.enum.particle.cloud, mi.x, mi.y, math.random(-10, 10)/10, math.random(-10,10)/10, 0, 0, self.name)
		end
		
		-- Sound
		local sound = ({
			"deadmaze/bruit/sac1.mp3",
			"deadmaze/bruit/sac2.mp3",
		})[math.random(2)]
		self:playSound("cite18/lance.mp3", 37, nil, nil)
		self:playSound(sound, 40, nil, nil)
		
		local item = enum.items[itemId]
		
		-- New sprite
		mi.imageId = tfm.exec.addImage(item.sprite, "_50", mi.x, mi.y, self.name, 0.375, 0.375, 0, 0.33, 0.5, 0.5, false)
		
		self:setHoldingItem(true)
		
		mi.active = false
		
		-- Truffle Window
		local pending = false
		for i=1, 7 do
			if self.mapItems[i] and self.mapItems[i].active then
				pending = true
				break
			end
		end
		
		if not pending then
			self:psst(true, "retreat")
			self:truffleExclamation(true)
		end
	end
end

function Player:setLampsDisplay(display)
	if type(display) == "number" then
		if self.lampsIds[display] then
			tfm.exec.removeImage(self.lampsIds[display], false)
			self.lampsIds[display] = -1
		end
		
		local lamp = enum.lamp[display]
		self.lampsIds[display] = tfm.exec.addImage(
			lamp.sprite or enum.items.lamp.sprite,
			lamp.foreground and "!1" or "_200",
			lamp.x, lamp.y,
			self.name,
			0.75, 0.75,
			0, 1.0,
			0.5, 0.5,
			false
		)
	else
		for i=1, #self.lampsIds do
			if self.lampsIds[i] then
				tfm.exec.removeImage(self.lampsIds[i], false)
			end
			
			self.lampsIds[i] = nil
		end
		
	
		if display then
			local installed = self:getData("inst" or 0)
			local lamp
			for i=1, math.min(installed, #enum.lamp) do
				lamp = enum.lamp[i]
				self.lampsIds[i] = tfm.exec.addImage(
					lamp.sprite or enum.items.lamp.sprite,
					lamp.foreground and "!45" or "_200",
					lamp.x, lamp.y,
					self.name,
					0.75, 0.75,
					0, 1.0,
					0.5, 0.5,
					false
				)
			end
		end
	end
end

function Player:showLampInstallPlace(show)
	local lampId = self:getData("inst") + 1
	
	if self.installLampId then
		self.installLampId = tfm.exec.removeImage(self.installLampId, true)
	end
	if self.installLampId2 then
		self.installLampId2 = tfm.exec.removeImage(self.installLampId2, true)
	end
	
	ui.removeClickable(79, self.name)
	
	if show and lampId <= #enum.lamp then
		if self.items[9].amount > 0 then
			local lamp = enum.lamp[lampId]
			self.installLampId = tfm.exec.addImage(
				"185cb8722a8.png", "!100",
				lamp.x, lamp.y,
				self.name,
				0.5, 0.5,
				math.rad(45), 0.5,
				0.5, 0.5,
				true
			)
			self.installLampId2 = tfm.exec.addImage(
				"185cb8722a8.png", "!100",
				lamp.x, lamp.y,
				self.name,
				0.5, 0.5,
				0, 0.5,
				0.5, 0.5,
				true
			)
			
			ui.addClickable(79, lamp.x-20, lamp.y-20, 40, 40, self.name, "install", false)
		end
	end
end

local pencil_ids = {
	2252,
	2256,
	2349,
	2379,
	2513,
	2514
}

function Player:placeLamp(x, y)
	local lampId = self:getData("inst") + 1
	
	if lampId <= #enum.lamp and self.items[9].amount > 0 then
		local lamp = enum.lamp[lampId]
		
		if math.pythag(x, y, lamp.x, lamp.y) <= 45 then -- Success
			self:extractItem(9, 1)
			self:setData("inst", lampId, true)
			system.giveAdventurePoint(self.name, "evt_hoppy_cny_installed", "1")
			system.giveEventGift(self.name, "evt_hoppy_cny_golden_ticket_1")
			
			self:setLampsDisplay(lampId)
			
			do
				self:playSound("cite18/fleche4.mp3", 55, nil, nil)
				self:playSound("cite18/flamme.mp3", 55, nil, nil)
				local pr = {2, 11, 13}
				
				for i=1, math.random(6, 9) do
					local e = math.random(-20, 20)/10
					tfm.exec.displayParticle(pr[math.random(#pr)], lamp.x, lamp.y, e, -1.7, -e/20, math.random(20, 35)/100, self.name)
				end
			end
			
			self:showLampInstallPlace(true)
			
			if lampId % 4 == 0 then -- every 4 lamps give pencils
				local ccid = math.ceil(lampId / 4)
				tfm.exec.giveConsumables(self.name, pencil_ids[ccid], 5)
			end
			
			if lampId == #enum.lamp then
				self:finishEvent()
			end
		end
	end
end

function Player:finishEvent()
	self:playSound("tfmadv/niveausup.mp3", 100, nil, nil)
	self:playBackgroundMusic(true)
	self:setData("finished", true, true)
	
	self:setMapItems(false)
	self:closeDrawing()
	self:closeCrafting()
end

function Player:placeMainNpc(where)
	local Npc = self.Npc
	local x, y, facingRight
	local sx -- scale X
	local shouldPlace = not not where
	if where == "village" then
		x = 1150
		y = 388
		facingRight = false
		shouldPlace = false
	elseif where == "entrance" then
		x = 553
		y = 827
		facingRight = false
	elseif where == "toptree" then
		x = 146
		y = 313
		facingRight = false
		shouldPlace = false
	end
	
	sx = facingRight and 1.0 or -1.0
	
	if Npc.imageId then
		Npc.imageId = tfm.exec.removeImage(Npc.imageId, false)
		ui.removeTextArea(900, self.name)
		ui.removeTextArea(901, self.name)
		ui.removeClickable(78, self.name)
	end
	
	if where then
		Npc.sprite = "185e39764da.png"
		Npc.x = x
		Npc.y = y
		Npc.isFacingRight = facingRight
		Npc.place = where
		if shouldPlace then
			Npc.imageId = tfm.exec.addImage(Npc.sprite, "!250", Npc.x, Npc.y, self.name, sx, 1.0, 0, 1.0, 0.5*sx, 0.5, false)
			
			local xo, yo = Npc.x - 47, Npc.y - 38
			ui.addTextArea(901, "<font color='#000000'><p align='center'>Truffle</p></font>", self.name, xo+1, yo+1, 90, 0, 0x0, 0x0, 1.0, false)
			ui.addTextArea(900, "<font color='#F7E5BA'><p align='center'>Truffle</p></font>", self.name, xo, yo, 90, 0, 0x0, 0x0, 1.0, false)
			ui.addClickable(78, Npc.x - 20, Npc.y - 20, 40, 40, self.name, "truffle_talk", false)
		else
			if not self.gameNpcSpawned then
				tfm.exec.addNPC("Truffle", {
					title = 234,
					look = "263;0,0,0,0,0,0,0,0,0",
					x = Npc.x,
					y = Npc.y + 2,
					female = false,
					lookLeft = not facingRight,
					interactive = true
				}, self.name)
				self.gameNpcSpawned = true
			end
		end
	end
end

function Player:talkToNpc(x, y)
	local Npc = self.Npc
	if math.pythag(x, y, Npc.x, Npc.y) < 45 then
		if Npc.place == "village" then
			if not self.interface then
				self:showLampInterface(true)
			end
			self:truffleExclamation(false)
		elseif Npc.place == "entrance" then
			self:newDialog("welcome", false)
			self:truffleExclamation(false)
		elseif Npc.place == "toptree" then
			self:newDialog("thanks", false)
		end
	end
end

function Player:showLampInterface(show)
	self:psst(false)
	if self.interface then
		
		if self.interface.mainId then
			self.interface.mainId = tfm.exec.removeImage(self.interface.mainId, true)
		end
		
		for i=1, 2 do
			if self.interface[i].iconId then tfm.exec.removeImage(self.interface[i].iconId, true) end
			for k, id in next, self.interface[i].items do
				if id then tfm.exec.removeImage(id, true) end
				ui.removeTextArea(960 + k, self.name)
			end
			
			ui.removeTextArea(60 + i, self.name)
			ui.removeClickable(120 + i, self.name)
		end
		
		self.interface = nil
		
		if show ~= true then
			self:playSound("cite18/fleche-debut.mp3", 67, nil, nil)
		end
	end
	
	if show and not (self.drawing.active or self.crafting.active or self:getData("finished")) then
		self.interface = {{items={}}, {items={}}}
		self.interface.mainId = tfm.exec.addImage("185e3742fcc.png", ":50", 400, 210, self.name, 0.95, 0.95, 0, 1.0, 0.5, 0.5, true)
		
		local rr
		
		-- Maybe this could have been done better in another way, but the moment I wrote it,
		-- I was rushing some code. It works without flaws, so if it isn't broken, don't fix it !
		do -- 1
			self.interface[1].iconId = tfm.exec.addImage(
				enum.items.lamp.sprite, ":70",
				265, 225,
				self.name,
				2.25, 2.25,
				0, 1.0,
				0.5, 0.5,
				true
			)
			
			ui.addTextArea(
				61,
				styles.ititle:format(Text:get("craft lamp", self.language)),
				self.name,
				55, 60,
				330, 0,
				0x0, 0x0,
				1.0, true
			)
			
			for i=1, 5 do
				local y = 105 + (i - 1) * 50
				self.interface[1].items[i] = tfm.exec.addImage(
					enum.items[i].sprite, ":80",
					75, y,
					self.name,
					0.5, 0.5,
					0, 1.0,
					0.0, 0.0
				)
				ui.addTextArea(
					960 + i,
					styles.ilist:format(self.items[i].amount .. " / 1"),
					self.name,
					120, y+8,
					100, 0,
					0x0, 0x0,
					1.0, true
				)
			end
			do
				ui.addClickable(121, 60, 55, 310, 310, self.name, "craft_a_lamp", true)
			end
		end
		
		do -- 2
			self.interface[2].iconId = tfm.exec.addImage(
				enum.items.lamp_final.sprite, ":70",
				630, 225,
				self.name,
				2.25, 2.25,
				0, 1.0,
				0.5, 0.5,
				true
			)
			
			ui.addTextArea(
				62,
				styles.ititle:format(Text:get("draw lamp", self.language)),
				self.name,
				410, 60,
				330, 0,
				0x0, 0x0,
				1.0, true
			)
			for i=6, 8 do
				local y = 155 + (i - 6) * 50
				self.interface[2].items[i] = tfm.exec.addImage(
					enum.items[i].sprite, ":80",
					435, y,
					self.name,
					0.5, 0.5,
					0, 1.0,
					0.0, 0.0
				)
				ui.addTextArea(
					960 + i,
					styles.ilist:format(self.items[i].amount .. " / 1"),
					self.name,
					490, y+8,
					100, 0,
					0x0, 0x0,
					1.0, true
				)
			end
			if self:getData("hans") < 24 then
				ui.addClickable(122, 422, 55, 310, 310, self.name, "craft_a_lamp_draw", true)
			end
		end
		
		self:playSound("cite18/fleche2.mp3", 67, nil, nil)
	end
end

function Player:showDrawingInterface(show)
	self:psst(false)
	if show and not self:getData("finished") and (self:getData("hans") < 24) then
		self:showInventory(false)
		self:placeMainNpc(false)
		self:showLampInterface(false)
		self:showCrafting(false)
		self:hideOffscreen(true, 0x010101)
		
		local x, y = self:getUiCenterFromMap()
		self.drawing.coverId = tfm.exec.addImage("185e3747cb8.png", "!1000", x, y-7, self.name, 1.0, 1.0, 0, 1.0, 0.5, 0.5, true) -- Wood behind
		self.drawing.canvasId = tfm.exec.addImage("185e50f1e58.png", "!1020", x, y, self.name, 1.0, 1.0, 0, 1.0, 0.5, 0.5, true) -- Huge lamp
		
		do
			local text = {
				[3] = styles.drawui:format("draw_send", Text:get("draw finish", self.language)),
				[2] = "<font size='8.5'>\n\n</font>",
				[1] = styles.drawui:format("draw_undo", Text:get("draw undo", self.language))
			}
			text = table.concat(text, "")
			
			local y = 185
			
			ui.addTextArea(40, text, self.name, 640, y, 160, 200, 0x0, 0x0, 1.0, true)
			self.drawing.interfaceId = tfm.exec.addImage("185e3742fcc.png", ":20", 715, y+29, self.name, 0.1, 0.4, math.rad(90), 1.0, 0.5, 0.5, true)
			
			self.drawing.tipId = 0
			ui.addTextArea(39, "", self.name, 40, 375, 720, 50, 0x010101, 0x010101, 0.5, true)
			local t = styles.drawuitip:format("haninfo " .. self.drawing.hanId, "%s")
			local han =  enum.han[self.drawing.hanId]
			local hanchar = han and han.name or "?"
			if self.language == "cn" then
				t = t:format(hanchar)
			else
				local f = ("han %d name"):format(self.drawing.hanId)
				t = t:format(("%s - %s"):format(hanchar, Text:get(f, self.language, self.gender)))
			end
			ui.addTextArea(38, t, self.name, 200, 22, 400, 0, 0x010101, 0x010101, 0.5, true)
			self:newDrawingTip()
		end
		
		self:playSound("deadmaze/journal_page.mp3", 67, nil, nil)
	else
		ui.removeTextArea(40, self.name)
		ui.removeTextArea(39, self.name)
		ui.removeTextArea(38, self.name)
		if self.drawing.interfaceId then
			self.drawing.interfaceId = tfm.exec.removeImage(self.drawing.interfaceId, true)
		end
		
		if self.drawing.coverId then
			self.drawing.coverId = tfm.exec.removeImage(self.drawing.coverId, true)
		end
		
		if self.drawing.canvasId then
			self.drawing.canvasId = tfm.exec.removeImage(self.drawing.canvasId, true)
		end
	end
end


function Player:initDrawing(xp, yp)
	self.drawing = {
		active = true,
		lines = {},
		points = {},
		consecutive_points = 0,
		keep_drawing = false,
		keepDrawingId = -1,
		finished = false,
		hanId = self:getData("hans") + 1,
		canvasId = -1,
		coverId = -1
	}
	
	do
		self:freeze(true)
		
		self:playBackgroundMusic(false)	
		self:showDrawingInterface(true)
	end
	
	self:previewLineToDraw()
end

function Player:setKeepDrawing(set)
	if set == nil then
		set = not self.drawing.keep_drawing
	else
		set = set
	end
	
	if self.drawing.keepDrawingId then
		self.drawing.keepDrawingId = tfm.exec.removeImage(self.drawing.keepDrawingId, false)
	end
	
	if set then
		self.drawing.keep_drawing = true
		
		if self.drawing.consecutive_points > 0 then
			local point = self.drawing.points[#self.drawing.points]
			if point then
				self.drawing.keepDrawingId = tfm.exec.addImage(
					"185cd3b62c5.png", "!100",
					point.x, point.y,
					self.name,
					1.0, 1.0,
					0, 0.25,
					0.5, 0.5,
					true
				)
			end
		end
	else
		if self.drawing.consecutive_points >= 2 then
			self:finishLine()
			if self.drawing.keepDrawingId then tfm.exec.removeImage(self.drawing.keepDrawingId) end
		else
			self:setKeepDrawing(true)
		end
	end
end

function Player:getUiCenterFromMap(x, y)
	x = x or self.x
	y = y or self.y
	
	local xc, yc
	
	if x <= 400 then
		xc = 400
	elseif x > (MAP_LENGTH - 400) then
		xc = MAP_LENGTH - 400
	else
		xc = x
	end
	
	if y <= 200 then
		yc = 200
	elseif y > (MAP_HEIGHT - 200) then
		yc = MAP_HEIGHT - 200
	else
		yc = y
	end
	
	yc = yc - 30
	
	return xc, yc
end

function Player:registerPoint(x, y)
	if self.drawing.finished then return end
	
	local drawing = self.drawing
	local count = drawing.consecutive_points
	local index = #drawing.points + 1
	
	if count == 0 then
		self:startLine()
	end
	
	if count < 10 then		
		drawing.points[index] = {
			x = x,
			y = y,
			id = count + 1,
			i1 = -1,
			i2 = -1,
		}
		
		drawing.consecutive_points = count + 1
		self:setKeepDrawing(true)
		
		local point = drawing.points[index]
		
		if point then
			point.i1 = tfm.exec.addImage(
				"185e1bf0bb4.png", "!100000", 
				point.x, point.y,
				self.name,
				0.25, 0.25,
				0, 1.0,
				0.5, 0.5,
				false
			)
		
			if drawing.consecutive_points >= 2 then
				local previous = drawing.points[index - 1]
				if previous then
					local sx = math.pythag(point.x, point.y, previous.x, previous.y) / 40
					local an = math.atan2(previous.y - point.y, previous.x - point.x)
					
					point.i2 = tfm.exec.addImage(
						"185e1bebf8a.png", "!100000",
						point.x, point.y,
						self.name,
						sx, 0.25,
						an, 1.0,
						0.0, 0.5,
						false
					)
				end
			end
		end
		
		self:playSound("cite18/bouton1.mp3", 100, nil, nil)
	else
		self:finishLine()
	end
end

function Player:previewLineToDraw(offset)
	offset = offset or 0
	local xc, yc = self:getUiCenterFromMap(self.x, self.y)
	HanPreview:show(self.name, self.drawing.hanId, xc, yc, {(#self.drawing.lines + 1) + offset})
end

function Player:startLine()
	self:setKeepDrawing(true)
	self:playSound("deadmaze/objectif2.mp3", 100, nil, nil)
end

function Player:undoDrawingAction()
	local drawing = self.drawing
	
	if drawing.consecutive_points > 0 then
		self:removePoint(-1)
	else
		local line = drawing.lines[#drawing.lines]
		if line then
			if #line == 0 then
				drawing.consecutive_points = 0
				self:removeLine(-1)
				self:undoDrawingAction()
				self:previewLineToDraw(-2)
			else
				drawing.consecutive_points = #line
				self:undoDrawingAction()
				self:previewLineToDraw(0)
			end
		else
			local manual_count = 0
			for k, v in next, drawing.lines do
				if type(v) == "number" then
					manual_count = manual_count + 1
				end
			end
			
			if #drawing.lines ~= manual_count then
				self:closeDrawing()
				tfm.exec.chatMessage("Canvas Error", self.name)
			else
				if #drawing.lines == 0 then
					for i=1, #drawing.points do
						self:removePoint(-1)
					end
				end
				self:previewLineToDraw()
			end
		end
	end
	
	self:playSound("deadmaze/whoosh.mp3", 67, nil, nil)
	
	self:setKeepDrawing(true)
end

function Player:removePoint(id)
	local drawing = self.drawing
	if id < 0 then id = (#drawing.points - (math.abs(id) - 1)) end
	

	local point = drawing.points[id]
	
	if point then
		tfm.exec.removeImage(point.i1 or -1, false)
		tfm.exec.removeImage(point.i2 or -1, false)
		
		local line = drawing.lines[point.lineId]
		if line then
			table.remove(line, #line)
			
			if #line == 0 then
				self:removeLine(point.lineId)
			end
		end
		
		table.remove(drawing.points, id)
		if drawing.consecutive_points > 0 then 
			drawing.consecutive_points = drawing.consecutive_points - 1
		end
	end
end

function Player:removeLine(id)
	local drawing = self.drawing
	if id < 0 then id = #drawing.lines - (math.abs(id) - 1) end
	
	
	if drawing.lines[id] then
		table.remove(drawing.lines, id)
	end
end

function Player:finishLine()
	local drawing = self.drawing
	
	if drawing.consecutive_points >= 2 then
		local line = {}
		local start = (#drawing.points - drawing.consecutive_points) + 1
		local point
		for i = start, #drawing.points do
			point = drawing.points[i]
			if point then
				point.lineId = #drawing.lines + 1
				line[#line + 1] = table.unreference(point)
			end
		end
		
		local angle = 0
		local angle_total = 0
		local large = 0
		local large_total = 0
		local a = line[1]
		local b = line[1]
		for i=2, #line do
			a = b
			b = line[i]
			
			angle = math.udist(angle, math.abs(math.atan2(a.y - b.y, a.x - b.x)))
			angle_total = angle_total + math.deg(angle)
			
			large = math.pythag(a.x, a.y, b.x, b.y)
			large_total = large_total + large
		end
		
		line.angle = angle_total
		line.large = large_total
		
		table.insert(drawing.lines, line)
		
		if drawing.keepSpriteId then
			tfm.exec.removeImage(drawing.keepSpriteId, false)
		end
		
		self:playSound("tfmadv/carte3.mp3", 100, nil, nil)
	end
	
	self:previewLineToDraw()
	
	drawing.consecutive_points = 0
end

function Player:correctDrawing(han) -- Regulate drawing: scale, pos
	local drawing = self.drawing
	local w_norm = han and han.width or 200
	local xMin, yMin = 9e9, 9e9
	local xMax, yMax = 0, 0
	
	local height, width
	for index, point in ipairs(drawing.points) do
		xMin = math.min(xMin, point.x)
		xMax = math.max(xMax, point.x)
		
		yMin = math.min(yMin, point.y)
		yMax = math.max(yMax, point.y)
	end
	
	height = yMax - yMin
	width = xMax - xMin
	
	local xFactor = w_norm / width
	local yFactor = 200 / height
	
	for index, point in ipairs(drawing.points) do
		point.x = (point.x - xMin) * xFactor
		point.y = (point.y - yMin) * yFactor
	end
	local large, large_total
	for index, line in ipairs(drawing.lines) do
		large = 0
		large_total = 0
		for index, point in ipairs(line) do
			point.x = (point.x - xMin) * xFactor
			point.y = (point.y - yMin) * yFactor
			if index >= 2 then
				large = math.pythag(point.x, point.y, line[index-1].x, line[index-1].y)
				large_total = large_total + large
			end
		end
		
		line.large = large_total
	end
end

function Player:drawingSuccess()
	if self.drawing.finished then return end
	if self.crafting.active and self.crafting.size == 3 and self.drawing.active then
		self:setData("hans", self.drawing.hanId, true)
		self:pushItem(4, false)
		system.giveAdventurePoint(self.name, "evt_hoppy_cny_drawn", "1")
		system.giveEventGift(self.name, "evt_hoppy_cny_golden_ticket_1")
		self:playSound("deadmaze/niveau/gain_niveau.mp3", 100, nil, nil)
	end
end

function Player:finishDrawing()
	if self.drawing.finished then return end
	local han = enum.han[self.drawing.hanId]
	
	self:finishLine()
	self:correctDrawing(han)
	
	local success = self:assertDrawing(han)
	if success then
		self:drawingSuccess()
		ui.addTextArea(49, "", self.name, 5, 5, 790, 390, 0x0000FF, 0x0000FF, 0.15, true)
	else
		ui.addTextArea(49, "", self.name, 5, 5, 790, 390, 0xFF0000, 0xFF0000, 0.15, true)
		self:playSound("deadmaze/combat/casse.mp3", 50, nil, nil)
	end
	
	self.drawing.finished = true
	
	HanPreview:hide(self.name)
	
	Timer.new(2000, false, function()
		self:closeDrawing(success)
		ui.removeTextArea(49, self.name)
	end)
end

function Player:assertDrawing(han)
	if not han then return false end
	local drawing = self.drawing
	
	if drawing.active then
		local l_han, l_draw
		local p_han, p_draw
		local pdist
		
		if #drawing.lines == #han.lines then
			for i = 1, #han.lines do
				l_han = han.lines[i]
				l_draw = drawing.lines[i]
				
				do
					p_han = l_han[1]
					p_draw = l_draw[1]
					
					pdist = math.pythag(p_han.x, p_han.y, p_draw.x, p_draw.y)
					if pdist > 50 then
						return false
					end
					
					p_han = l_han[#l_han]
					p_draw = l_draw[#l_draw]
					
					pdist = math.pythag(p_han.x, p_han.y, p_draw.x, p_draw.y)
					if pdist > 50 then
						return false
					end
				end
				pdist = math.udist(l_han.angle, l_draw.angle)
				if pdist > (45 * #l_han) then
					return false
				end
				
				pdist = math.udist(l_han.large, l_draw.large)
				if pdist > (65 * #l_han) then
					return false
				end
			end
		else
			return false
		end
	else
		return false
	end
	
	return true
end

function Player:closeDrawing(success)
	do
		self:freeze(false)
		if not self.playingMusic then
			self:playBackgroundMusic(true)
			self.playingMusic = true
		end
		
		self.drawing.active = false
		--self:placeMainNpc("village")
	end
	
	for index, point in next, self.drawing.points do
		if point.i1 then tfm.exec.removeImage(point.i1, false) end
		if point.i2 then tfm.exec.removeImage(point.i2, false) end
	end
	self:showDrawingInterface(false)
	
	self.drawing.lines = {}
	self.drawing.points = {}
	self.drawing.active = false
	
	HanPreview:hide(self.name)
	
	self:hideOffscreen(false)
	
	self:closeCrafting()
	if success then
		self:newDialog(self.drawing.hanId)
	elseif success == false then
		self:newDialog("careful_drawing")
	end
end

function Player:freeze(freeze)
	if freeze then
		tfm.exec.freezePlayer(self.name, true, false)
		tfm.exec.setPlayerGravityScale(self.name, 0, 0)
		tfm.exec.movePlayer(self.name, self.x, self.y, false, 0, 0, false)
	else
		tfm.exec.setPlayerGravityScale(self.name, 1.0, 0.0)
		tfm.exec.freezePlayer(self.name, false, false)
	end
end

function Player:psst(show, textName)
	if self.psstId1 then
		self.psstId1 = tfm.exec.removeImage(self.psstId1, true)
	end
	if self.psstId2 then
		self.psstId2 = tfm.exec.removeImage(self.psstId2, true)
	end
	
	ui.removeTextArea(10000, self.name)
	
	if show then
		self.psstId1 = tfm.exec.addImage("185d44bafbb.png", "~100", 785, 385, self.name, 0.5, 0.5, 0, 1.0, 1.0, 1.0, true) -- Dialogue Box
		self.psstId2 = tfm.exec.addImage("185d44a7bb2.png", "&100", 775, 382, self.name, 0.75, 0.75, 0, 1.0, 1.0, 1.0, true) -- Lil Truffle
		
		local psst_hi = styles.dialogue:format(Text:get("truffle " .. textName, self.language, self.gender))
		if textName == "retreat" then
			psst_hi = psst_hi:gsub("size='%d+'", "size='12'")
		end
		ui.addTextArea(10000, psst_hi, self.name, 545, 325, 150, 45, 0x0, 0x0, 1.0, true)
		
		Timer.new(7500, false, function()
			self:psst(false)
		end)
	
		self:playSound("tfmadv/sel.mp3", 100, nil, nil)
	end
end

function Player:truffleExclamation(show)
	ui.removeTextArea(6969, self.name)
	ui.removeTextArea(6970, self.name)
	
	if show then
		ui.addTextArea(6969, styles.BANG:format(0x000000), self.name, 3 + self.Npc.x - 50, 3 + self.Npc.y - 80, 100, 0, 0x0, 0x0, 1.0, false)
		ui.addTextArea(6970, styles.BANG:format(0xF7E5BA), self.name, self.Npc.x - 50, self.Npc.y - 80, 100, 0, 0x0, 0x0, 1.0, false)
	end
end

function Player:newDrawingTip()
	self.drawing.tipTimestamp = os.time() + 4000
	self.drawing.tipId = self.drawing.tipId + 1
	self.drawing.tipId = ((self.drawing.tipId-1)%5)+1
	ui.updateTextArea(39, styles.drawuitip:format("draw_tip", Text:get("draw instruct ".. self.drawing.tipId, self.language, self.gender)), self.name)
end

function Player:initInventory()
	local size = #enum.items
	local sqr = 40
	local sep = 23
	
	local width = (sqr * size) + (sep * (size - 1))
	local xo = 400 - (width / 2)
	
	local i, item
	for index = 1, size do
		i = index - 1
		item = enum.items[index]
		self.items[index] = {
			id = index,
			amount = self:getData("i" .. index),
			
			key = item.name,
			
			dx = xo + (sqr * i) + (sep * i),
			dy = 352,
			dscale = 0.5, -- 0.
			
			data = "i" .. index,
			
			sprite = item.sprite,
			spriteId = -1
		}
		
		tfm.exec.removeImage(tfm.exec.addImage(item.sprite, ":1", 400, 500, self.name, 0.1, 0.1, 0, 0.0, 0, 0, false), false)
	end
end

function Player:showCrafting(show)
	if not self.crafting.active then return end
	self:psst(false)
	if show then
		self:showLampInterface(false)
		self:showCrafting(false)
		if self.crafting.size == 3 then
			self.crafting.imageId = tfm.exec.addImage(
				"185da67352b.png", ":12",
				400, 180,
				self.name,
				self.crafting.dscale, self.crafting.dscale,
				0, 1.0,
				0.5, 0.5,
				true
			)
		elseif self.crafting.size == 5 then
			self.crafting.imageId = tfm.exec.addImage(
				"185dbe49fd1.png", ":12", 
				400, 190, 
				self.name, 
				self.crafting.dscale, self.crafting.dscale, 
				0, 1.0, 
				0.5, 0.5, 
				true
			)
		end
		
		for id, item in ipairs(self.crafting) do
			ui.addClickable(300 + id, item.dx, item.dy, 80 * item.dscale, 80 * item.dscale, self.name, "craft_action", true)
			
			if item.id ~= 0 then
				item.sprite = self.items[item.id].sprite
				item.spriteId = tfm.exec.addImage(
					item.sprite, ":1",
					item.dx, item.dy,
					self.name,
					item.dscale, item.dscale,
					0.0, 1.0,
					0.0, 0.0,
					false
				)
			end
		end
		
		self:showInventory(true)
		
		if not self.craftingTipShown then
			tfm.exec.chatMessage(styles.chat2:format(Text:get("craft instruct", self.language, self.gender)), self.name)
			self.craftingTipShown = true
		end
		
		self:playSound("tfmadv/carte1.mp3", 37, nil, nil)
		self:playSound("tfmadv/carte3.mp3", 37, nil, nil)
	else
		if self.crafting.imageId then
			self.crafting.imageId = tfm.exec.removeImage(self.crafting.imageId, true)
		end
		
		for i = 1, #self.crafting do
			ui.removeClickable(300 + i, self.name)
			
			if self.crafting[i].spriteId then
				self.crafting[i].spriteId = tfm.exec.removeImage(self.crafting[i].spriteId, false)
			end
		end
		
		self:showInventory(false)
	end
end

function Player:setCrafting(size)
	if self:getData("finished") then
		self:closeCrafting()
		return
	end
	local ms
	local slots = {}
	local xc, yc
	if size == 3 then
		ms = 1.0
		slots = {
			{x=412, y=103},
			{x=292, y=295},
			{x=537, y=301}
		}
		xc = 365
		yc = 180
		
	elseif size == 5 then
		ms = 0.85
		slots = {
			{x = 409, y = 79},
			{x = 276, y = 174},
			{x = 540, y = 174},
			{x = 338, y = 321},
			{x = 485, y= 321}
		}
		xc = 375
		yc = 180
	end
	
	for i=1, size do
		self.crafting[i] = {
			dx = slots[i].x - (20 * ms),
			dy = slots[i].y - (20 * ms),
			id = 0,
			amount = 0,
			dscale = 0.35 * ms^2,
			sprite = nil,
			spriteId = -1
		}
	end
	
	self.crafting.dscale = ms
	self.crafting[size + 1] = {
		dx = xc,
		dy = yc,
		id = 0,
		amount = 0,
		dscale = 0.9 * ms^2,
		sprite = nil,
		spriteId = -1
	}
	
	self.crafting.active = true
	self.crafting.size = size
	
	self:showCrafting(true)
	self:freeze(true)
end

function Player:closeCrafting()
	for i=1, #self.crafting do
		if i ~= #self.crafting then
			self:pushItem(i, false)
		end
	end
	
	self:showCrafting(false)
	self:freeze(false)
	self.crafting = {}
	
	self.crafting.active = false
	self.crafting.size = 0
end

function Player:showInventoryItem(id, show)
	local item = self.items[id]
	if show then
		if item.amount > 0 then
			item.spriteId = tfm.exec.addImage(
				item.sprite,
				"~10",
				item.dx, item.dy,
				self.name,
				item.dscale, item.dscale,
				0.0, 1.0,
				0.0, 0.0,
				true
			)
			
			if item.amount > 1 then
				ui.addTextArea(
					5010 + id,
					("<p align='right'><font size='18'><b>%s</b></font></p>"):format(styles.invqd:format(item.amount)),
					self.name,
					item.dx+2, item.dy + 22,
					35, 0,
					0x0, 0x0,
					1.0, true
				)
				ui.addTextArea(
					5000 + id,
					("<p align='right'><font size='18'>%s</font></p>"):format(styles.invq:format(item.amount)),
					self.name,
					item.dx, item.dy + 20,
					35, 0,
					0x0, 0x0,
					1.0, true
				)
			end
			
			ui.addClickable(100 + id, item.dx, item.dy, 40, 40, self.name, "inv", true)
		end
	else
		if item.spriteId then
			item.spriteId = tfm.exec.removeImage(item.spriteId, true)
		end
		
		ui.removeTextArea(5000 + id, self.name)
		ui.removeTextArea(5010 + id, self.name)
		ui.removeClickable(100 + id, self.name)
		
		if show == nil then
			self:showInventoryItem(id, true)
		end
	end
	
	if self.items.selected == id then
		self:setSelectedSlot(id)
	end
end

function Player:showInventory(show)
	if show and not self.drawing.active then
		self:psst(false)
		self.items.displaying = true
		
		if self.items.coverId then
			tfm.exec.removeImage(self.items.coverId)
		end
		
		self.items.coverId = tfm.exec.addImage(
			"185e53cdfa2.png", ":1",
			400, 320, -- X, Y
			self.name,
			1.0, 1.0,
			0, 1.0, 
			0.5, 0.0,
			true
		)
		
		for i, item in ipairs(self.items) do
			self:showInventoryItem(i, nil)
		end
		self:playSound("carte2.mp3", 35, nil, nil)
	else
		self.items.displaying = false
		
		for i, item in ipairs(self.items) do
			self:showInventoryItem(i, false)
		end
		
		if self.items.coverId then
			self.items.coverId = tfm.exec.removeImage(self.items.coverId, true)
		end
		
		if show == nil then
			self:showInventory(true)
		end
		
		ui.removeTextArea(369, self.name)
		ui.removeTextArea(370, self.name)
	end
	
	self:setSelectedSlot(nil)
end

function Player:pushItem(id, into)
	id = id or self.items.selected
	if into and self.crafting.active then
		local item = self.items[id]
		if self.crafting.size == 3 and id < 6 or id == 9 then
			return false
		elseif self.crafting.size == 5 and id > 5 then
			return false
		end
		if item.amount > 0 then
			local item
			for i = 1, #self.crafting - 1 do
				item = self.crafting[i]
				
				if item.id == 0 then
					item.amount = 1
					item.id = id
					item.sprite = self.items[id].sprite
					
					item.spriteId = tfm.exec.addImage(
						item.sprite, ":10000",
						item.dx, item.dy,
						self.name,
						item.dscale, item.dscale,
						0.0, 1.0,
						0.0, 0.0,
						false
					)
					
					self:extractItem(id, 1)
					local r = self:fetchRecipes(false, false)
					
					if #r > 0 then
						local result = r[1].recipe.result
						
						local rsl = self.crafting[#self.crafting]
						
						rsl.amount = 1
						rsl.id = result.id
						rsl.sprite = enum.items[rsl.id].sprite
						
						rsl.spriteId = tfm.exec.addImage(
							rsl.sprite, ":10000",
							rsl.dx, rsl.dy,
							self.name,
							rsl.dscale, rsl.dscale,
							0.0, 1.0,
							0.0, 0.0,
							false
						)
					end
					
					break
				end
			end
		end
	elseif (not into) and self.crafting.active then -- out of
		local item = self.crafting[id]
		
		if item then
			if item.id ~= 0 then
				if item.amount >= 1 then
					item.amount = 0
					item.sprite = nil
					if item.spriteId then
						item.spriteId = tfm.exec.removeImage(item.spriteId, false)
					end
					
					
					self:insertItem(item.id, 1)
					
					
					if id == #self.crafting and item.id == 8 then
						system.giveAdventurePoint(self.name, "evt_hoppy_cny_lamps", "1")
						system.giveEventGift(self.name, "evt_hoppy_cny_golden_ticket_1")
					end
					item.id = 0
				end
				
				if id == #self.crafting then
					local ax
					for i=1, #self.crafting do
						ax = self.crafting[i]
						ax.amount = 0
						ax.sprite = nil
						if ax.spriteId then
							ax.spriteId = tfm.exec.removeImage(ax.spriteId or -1, false)
						end
						ax.id = 0
					end
				else
					local rsl = self.crafting[#self.crafting]
					
					rsl.amount = 0
					rsl.id = 0
					rsl.amount = 0
					rsl.sprite = nil
					if rsl.spriteId then
						rsl.spriteId = tfm.exec.removeImage(rsl.spriteId, false)
					end
				end
			end
		end
	end
end

function Player:setSelectedSlot(id, push)
	local old = self.items.selected
	self.items.selected = (id or self.items.selected)
	
	if self.items.selected > 0 then
		local item = self.items[self.items.selected]
		if push then
			if self.crafting.active then
				self:pushItem(id, true)
			end
		end
		
		do
			if old ~= self.items.selected and self.items.displaying then
				if self.items.textDescTimer then
					Timer.remove(self.items.textDescTimer)
					self.items.textDescTimer = nil
				end
				
				local itemName = Text:get("items " .. enum.items[self.items.selected].name, self.language, self.gender)
				local x, y = 225, 305
				ui.addTextArea(369, styles.invshow:format(0x010101, itemName), self.name, x + 1, y + 1, 350, 0, 0x0, 0x0, 1.0, true)
				ui.addTextArea(370, styles.invshow:format(0xF2C868, itemName), self.name, x, y, 350, 0, 0x0, 0x0, 1.0, true)
				
				self.items.textDescTimer = Timer.new(2000, false, function()
					ui.removeTextArea(369, self.name)
					ui.removeTextArea(370, self.name)
				end)
			end
		end
		
		
		if self.items.selectedImgId then
			self.items.selectedImgId = tfm.exec.removeImage(self.items.selectedImgId, false)
		end
		
		if self.items.displaying then
			local scale = item.dscale * 1.2
			local x = item.dx - 7
			local y = item.dy - 7
			self.items.selectedImgId = tfm.exec.addImage(
				"185cb8722a8.png", ":100",
				x, y,
				self.name,
				scale, scale,
				0.0, 1.0,
				0.0, 0.0,
				false
			)
		end
		self:playSound("cite18/bouton1.mp3", 100, nil, nil)
	else
		if self.items.selectedImgId then
			self.items.selectedImgId = tfm.exec.removeImage(self.items.selectedImgId, false)
		end
	end
	
	self:setHoldingItem(true)
end

function Player:setHoldingItem(show)
	local valid = (self.items.selected ~= 0)

	if self.items.selectedHoldingId then
		tfm.exec.removeImage(self.items.selectedHoldingId, false)
		self.items.selectedHoldingId = nil
	end
	
	if self.drawing.active or self.crafting.active or self.interface then return end

	if show and valid then
		local item = self.items[self.items.selected]
		
		if item and item.amount > 0 then
			local xf = self.isFacingRight and 1 or -1
			local rot = math.rad(self.isMoving and 20 or 0)
			local scale = 0.25
			local xpos = self.isMoving and 14 or 11
			local ypos = self.isMoving and 12 or 7
			self.items.selectedHoldingId = tfm.exec.addImage(
				item.sprite,
				"$" .. self.name,
				xpos * xf, ypos,
				nil,
				scale * xf, scale,
				rot * xf, 1.0,
				0.5 * xf, 0.5,
				false
			)
		end
	end
end

function Player:insertItem(itemId, amount)
	local item = self.items[itemId]	
	
	if item then
		amount = amount or 1
		item.amount = math.min(item.amount + amount, 24)
		
		self:setData(item.data, item.amount, true)
		
		if self.items.displaying then
			self:showInventoryItem(itemId, nil)
		end
		
		if item.id == 9 then
			tfm.exec.chatMessage(styles.chat2:format(Text:get("install", self.language, self.gender)), self.name)
			self:showLampInstallPlace(true)
		end
		
		return true
	end
	
	return false
end

function Player:extractItem(itemId, amount)
	local item = self.items[itemId]
	
	if item then
		amount = amount or 1
		
		if item.amount >= amount then
			item.amount = math.max(0, item.amount - amount)
			
			self:setData(item.data, item.amount, true)
			
			if self.items.displaying then
				self:showInventoryItem(itemId, nil)
			end
		end
	end
	
	return false
end

function Player:convertRecipe(recipe)
	if type(recipe) ~= "table" then
		return enum.recipes[recipe]
	else
		return recipe
	end

	return nil
end

function Player:assertRecipe(recipe, onInv)
	recipe = self:convertRecipe(recipe)
		
	if not recipe then return false, 0 end
	local stack = onInv and self.items or self.crafting
	if not onInv and not self.crafting.active then return false, 0 end
	
	local isAvailable = true
	local hasMatch
	
	for _, item in next, recipe.craft do
		hasMatch = false
		for i = 1, #stack - (onInv and 0 or 1) do
			if item.id == stack[i].id then
				
				if stack[i].amount < item.amount then
					isAvailable = false
					break
				end
				
				hasMatch = true
			end
		end
		
		if not hasMatch then
			isAvailable = false
		end
	end
	
	return isAvailable, recipe.result
end

function Player:fetchRecipes(returnAll, onInv)
	local recipes = {}
	
	local isAvailable
	local item
	
	for index, recipe in next, enum.recipes do
		isAvailable = self:assertRecipe(recipe, onInv)
		
		if isAvailable or returnAll then
			recipes[#recipes + 1] = {
				recipe = recipe,
				available = isAvailable
			}
		end
	end
	
	return recipes
end

function Player:newDialog(dialogId, noDist)
	if self.onDialog then
		self:closeDialog()
	end
	
	self:psst(false)
	self:showInventory(false)
	
	local text, bunny
	local hype = {
		[3] = {sprite="185d44b62bb.png", alignX=0, alignY=0},
		[2] = {sprite="185d44ac8b5.png", alignX=-20, alignY=10},
		[1] = {sprite="185d44b15b4.png", alignX=5, alignY=10},
	}
	
	if type(dialogId) == "number" then
		bunny = hype[enum.han[dialogId].hype]
		local t = ("han %d desc"):format(dialogId)
		text = Text:get(t, self.language, self.gender)
	else
		text = Text:get("truffle " .. dialogId, self.language, self.gender)
		bunny = hype[3]
	end
	
    self.onDialog = {
		oldCursor = 1,
		cursor = 1,
		Text = text,
		pInf = {},
		currentText = "",
		displayText = "",
		directAccess = 0,
		windowId = 0,
		displayInfo = {},
		finished = false,
		completed = false,
		pointer = 0,
		sprite = "185d44bafbb.png",
		bunny = bunny.sprite,
		bunnyAlignX = bunny.alignX,
		bunnyAlignY = bunny.alignY,
		distHide = not noDist
    }

	self:setDialogDisplay("new")
end

function Player:setDialogDisplay(instruction)
	local Dialog = self.onDialog

	if Dialog then
		if instruction == "new" then
			local x = 100
			local yt = 340
			local id = tfm.exec.addImage(Dialog.sprite, ":1", x+300, yt, self.name, 1.0, 0.75, 0, 1.0, 0.5, 0.5, true)
			local id2 = tfm.exec.addImage(Dialog.bunny, ":10", x + Dialog.bunnyAlignX, (yt-70)+Dialog.bunnyAlignY, self.name, 1.0, 1.0, 0, 1.0, 0.5, 0.5, true)
			Dialog.bunnyId = id2
			Dialog.directAccess = 2000 + (id or 0)
			ui.addTextArea(Dialog.directAccess, "", self.name, x+100, yt-35, 420, 131, 0x0, 0x0, 1.0, true)

			self:setDialogDisplay("next")
		elseif instruction == "update" then
			local text
			if self.language == "ar" or self.language == "he" then
				text = styles.dialogue:format(("<p align='right'>%s"):format(Dialog.displayText or Dialog.currentText))
			else
				text = styles.dialogue:format(Dialog.displayText or Dialog.currentText)
			end

			ui.updateTextArea(
				Dialog.directAccess,
				text,
				self.name
			) -- Update text

			self:playSound("cite18/sel.mp3", 80)

			if Dialog.finished then
				self:onDialogFinished()
			end
		elseif instruction == "next" then
			if Dialog.timerId then
				Timer.remove(Dialog.timerId)
				Dialog.timerId = nil
			end

			local Text = Dialog.Text
			Dialog.pointer = Dialog.pointer + 1
			if Dialog.pointer <= #Text then
				Dialog.currentText = Text[Dialog.pointer] or "..."
				Dialog.displayText = "..."
				Dialog.lenght = Dialog.currentText:len()
				Dialog.cursor = 1
				Dialog.oldCursor = 1

				Dialog.finished = false
			else
				Dialog.completed = true
				self:closeDialog()
			end
		end
	end
end

function Player:updateDialog(increment)
	increment = increment or 0

	local Dialog = self.onDialog
    if Dialog then
		if not Dialog.completed then
			if increment == 0 then
				if Dialog.finished then
					return self:setDialogDisplay("next")
				else
					Dialog.oldCursor = Dialog.cursor
					Dialog.cursor = Dialog.currentText:len()
					Dialog.displayText = Dialog.currentText


					Dialog.finished = true

					return self:setDialogDisplay("update")
				end
			elseif not Dialog.finished then
				Dialog.lenght = Dialog.currentText:len()
				Dialog.oldCursor = Dialog.cursor
				Dialog.cursor = math.min(Dialog.cursor + increment, Dialog.lenght)

				if Dialog.cursor >= Dialog.lenght then
					Dialog.displayText = Dialog.currentText
					Dialog.finished = true

					self:onDialogFinished()
				else
					Dialog.displayText = Dialog.currentText:sub(1, Dialog.cursor)
				end

				return self:setDialogDisplay("update")
			end
		else
			if increment == 0 then
				self:closeDialog()
			end
		end
    end
end

function Player:onDialogFinished()
	local Dialog = self.onDialog

	if Dialog then
		Dialog.finished = true
		do
			if Dialog.timerId then
				Timer.remove(Dialog.timerId)
			end
			Dialog.timerId = Timer.new(4000, false, function()
				self:setDialogDisplay("next")
			end)
		end
	end
end

function Player:closeDialog()
	local Dialog = self.onDialog
    if Dialog then
		for i=0, 2 do
			ui.removeTextArea(Dialog.directAccess + i, self.name)
        end
		tfm.exec.removeImage(Dialog.directAccess - 2000, true)
		if Dialog.bunnyId then
			tfm.exec.removeImage(Dialog.bunnyId, true)
		end

		self:onDialogClosed(Dialog.pInf)
    end

	self.onDialog = false
end

function Player:onDialogClosed(pid)
	if self.Npc.place == "entrance" then
		if self:getData("started") == false then
			self:placeMainNpc("village")
			self:setData("started", true, true)
		end
	end
end

--[[
tfm.exec.playMusic(music, Channel, volume, loop, fade, targetPlayer)
Play a music. A music can be stopped. Musics list can be found here : http://audio.atelier801.com/sounds.html
  music (String) URL of the music.
  Channel (String) Channel of the music. Only one music can be played per channel. If a music is playing, it will be stopped.
  volume (Int) Volume of the sound (0-100). (default 70)
  loop (Boolean) If the music should be looping. (default false)
  fade (Boolean) If the music should start with a fading. (default true)
  targetPlayer (Int) Send only to this specific player (if nil, applies to all players). (default nil)

tfm.exec.stopMusic(Channel, targetPlayer)
Stop a playing music.
  Channel (String) Music channel to stop.
  targetPlayer (Int) Send only to this specific player (if nil, applies to all players). (default nil)
]]

function Player:playMusic(music, channel, volume, loop, fade)
	channel = channel .. "-" .. self.name
    tfm.exec.stopMusic('musique', self.name)
	
    tfm.exec.playMusic(music, channel, volume, loop, fade, self.name)
end

function Player:playMusicDelay(delay,music,channel,volume,loop,fade)
    system.newTimer(function()
		self:playMusic(music,channel,volume,loop,fade)
	end,delay)
end

function Player:stopMusic(channel,fadeOut)
	channel = channel .. "-" .. self.name
    fadeOut=(not not fadeOut)
    if fadeOut then
        tfm.exec.stopMusic(channel, self.name)
    else
        self:playMusic('', channel, 0, false, false)
    end
    --print('Stopped sound '..tostring(channel),self.name)
end
function Player:stopMusicDelay(delay,channel)
    system.newTimer(function()
        self:stopMusic(channel)
    end,delay)
end

function Player:playMusicLength(length,music,channel,volume,loop,fade)
    self:playMusic(music,channel,volume,loop,fade)
    self:stopMusicDelay(length,channel)
end


function Player:playSound(sound,volume,soundPosX,soundPosY)
    tfm.exec.playSound(sound,volume,soundPosX,soundPosY,self.name)
end
function Player:playSoundDelay(delay,sound,volume,soundPosX,soundPosY)
    system.newTimer(function()
        self:playSound(sound,volume,soundPosX,soundPosY)
    end,delay)
end

function Player:playSoundLength(length,sound,volume,soundPosX,soundPosY)
    self:playSound(sound,volume,soundPosX,soundPosY)
    self:stopSoundDelay(length,sound)
end



local loopLength=23275
--local overlap=100

function Player:addSoundLoop(soundName,volume) -- Add an instrument to the loop
    volume=volume or 100
	printfd("Adding sound %s (volume: %d)", soundName, volume)
    table.insert(self.loopSounds,{sound=soundName,volume=volume})
    self.loopSoundsChanged=true
end

function Player:removeSoundLoop(soundName,stop) -- Remove an instrument from the loop
    printfd("Removing sound %s", soundName)
    local removeKeys={}
    for i,v in pairs(self.loopSounds) do
        if v.sound==soundName then
            table.insert(removeKeys,i)
        end
    end
    for i,v in ipairs(removeKeys) do
        if stop then
            self:stopMusic(v)
        end
        --table.remove(self.loopSounds,v)
        self.loopSounds[v]=nil
    end
    self.loopSoundsChanged=true
end

function Player:soundLoop() -- Loop of instrument sounds
    --self:updatePing()
    --local ping=self.currentPing
    --local ping=tfm.get.room.playerList[self.name].averageLatency
    local startTime = os.time()
	local sound
	if self.loopSoundsChanged then
		for i,v in pairs(self.loopSounds) do
			system.newTimer(function()
				self:stopMusic(i)
				self:playMusic(v.sound,i,(v.volume or 100),true,false)
				printfd('Playing sound %s', i)
			end,1000-(os.time()-startTime))
		end
		self.loopSoundsChanged=false
	end
end
function Player:playSoundLoop(play) -- Play or stop the loop of instrument sounds
    play=(not not play)

    if self.loopTimer then
        system.removeTimer(self.loopTimer)
        self.loopTimer=nil

        for i,v in pairs(self.loopSounds) do
			self:stopMusic(i)
			--print('Stopping sound '..('lua/music_event/individual/%s.mp3'):format(i))
		end
    end

    if play then
        --self:updatePing()
        self:soundLoop()
        local ping=tfm.get.room.playerList[self.name].averageLatency
        local loopTime=(loopLength-math.min(ping,5000)) -- Only use ping if it's less than 5s
        self.loopTimer=system.newTimer(function() self:soundLoop() end,loopTime,true)
    end

    --print(self.name..': '..(play and 'play' or 'pause'))
end

--[[
function Player:pauseMusic(paused,displayOnly)
    --print(('pauseMusic(%s,%s)'):format(tostring(paused),tostring(displayOnly)))
    if self.pauseImg then
       -- ui.removeTextArea(-1,self.name)
        --tfm.exec.removeImage(self.pauseImg,true)
        ui.removeClickableImage(self.pauseImg,true)
        self.pauseImg=nil
    end

    if paused~=nil then
		local sprite = (paused and '184360be1e4.png' or '1843612f382.png')
		--self.pauseButtonID = tfm.exec.addImage(sprite,'~1',0,25,self.name,1,1,0,1,0,0,true)
		--ui.addTextArea(-1,'<a href="event:toggle_pause">    \n    </a>',self.name,0,25,35,35,nil,nil,0.5,true)
		self.pauseImg=ui.addClickableImage(sprite,'~1',self.name,35,35,'toggle_pause',0,25,1,1,1,true)
	end


    if not displayOnly then
		if paused then
		    self.loopSoundsChanged=true
		end
		self.loopPaused=paused
		self:playSoundLoop(not paused)
		self:playSound('tfmadv/click.mp3',20)
	end
end
]]

function Player:isPlayingSound(soundName)
    for i,v in pairs(self.loopSounds) do
        if v.sound==soundName then
            return true
        end
    end
    return false
end

--[[
function soundLoop()
    for playerName,player in pairs(playerList) do
        for i,v in pairs(player.loopSounds) do
            tfm.exec.playSound(('lua/music_event/individual/%s.mp3'):format(i:lower()),(v.volume or 100))
            print('Playing sound '..('lua/music_event/individual/%s.mp3'):format(i:lower()))
        end
    end
end

system.newTimer(soundLoop,loopLength,true)
]]
