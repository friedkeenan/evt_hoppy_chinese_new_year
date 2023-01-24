function Player:new(playerName)
	local info = tfm.get.room.playerList[playerName]
    local this = setmetatable({
		name = playerName,
		
		x = 0,
		y = 0,
		vx = 0,
		vy = 0,
		
		progress = {},
		
		language = info.language,
		gender = info.gender,
		
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
		crafting = {
			active = false
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
		
		local track
		if self:getData("finished") then
			track = music[1]
		else
			track = music[math.random(#music)]
		end
			
		self:playMusic(track, "Main", 50, true, true)
	else
		self:stopMusic("Main", true)
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
			self.progress["i"..i] = self:getData("i" .. i) or 0
		end
		
		self.progress.hans = self.progress.hans or 0
		self.progress.inst = self.progress.inst or 0
		self.progress.finished = self:getData("finished") or false
	end
	
	--if self:getData("finished") then
	--	self:resetDefaultData()
	--end
	
	self:initInventory()
	
	tfm.exec.addNPC("Mirko", {
		title = 468,--228,
		look = "210;23_FFFFFF+FFFFFF+FFFFFF,0,11_FFFFFF+FFFFFF,45,69_10101+F9FFFF+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+FFEFD8+FFEFD8,49_FFFFFF+FFFFFF+FFFFFF+FFFFFF,0,23,0",
		x = 311,
		y = 844,
		female = true,
		lookAtPlayer = true,
		interactive = true
	}, self.name)

	self:setLampsDisplay(true)
	
	if not self:getData("finished") then
		self:setMapItems(true)
		self:showLampInstallPlace(true)
	end
	
	self:playBackgroundMusic(true)
	
	system.giveAdventurePoint(self.name, "evt_hoppy_cny_rounds", "1")
end

function Player:saveData()
	local rawdata = data.encode(self.progress)
	self.dataFile = data.setToModule(self.dataFile, "HCNY", rawdata)

	system.savePlayerData(self.name, self.dataFile)
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
		--self:setMute(self.ambienceMuted,true)
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
	if x > 700 and x < 1000 then -- To do: change
		ui.addClickable(1, 700, 150, 300, 50, self.name, "craftable", false)
	else
		ui.removeClickable(1, self.name)
	end
	
	if (x > 0 and x < 175) and y < 150 then -- To do: change
		ui.addClickable(2, 25, 50, 150, 50, self.name, "items", false)
	else
		ui.removeClickable(2, self.name)
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
		
		
		tfm.exec.removeBonus(100 + itemId, self.name)
		tfm.exec.removeImage(mi.imageId, false)
		
		
		for i=1, math.random(4, 6) do
			tfm.exec.displayParticle(tfm.enum.particle.cloud, mi.x, mi.y, math.random(-10, 10)/10, math.random(-10,10)/10, 0, 0, self.name)
		end
		self:playSound("cite18/lance.mp3", 40, nil, nil)
		
		local item = enum.items[itemId]
		
		tfm.exec.addImage(item.sprite, "_50", mi.x, mi.y, self.name, 0.375, 0.375, 0, 0.33, 0.5, 0.5, false)
		
		self:setHoldingItem(true)
		
		mi.active = false
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
			self.lampsIds[i] = tfm.exec.removeImage(self.lampsIds[i], false)
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
			
			if lampId % 4 == 0 then
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

function Player:initDrawing(xp, yp)
	self.drawing = {
		active = true,
		lines = {},
		points = {},
		consecutive_points = 0,
		keep_drawing = false,
		keepDrawingId = -1,
		finished = false,
		hanId = self:getData("hans") + 1
	}
	
	do
		tfm.exec.freezePlayer(self.name, true, false)
		tfm.exec.setPlayerGravityScale(self.name, 0, 0)
		tfm.exec.movePlayer(self.name, self.x, self.y, false, 0, 0, false)
		
		self:playBackgroundMusic(false)
	end
	
	self:showCrafting(false)
	self:hideOffscreen(true, 0x010101)
	self:previewLineToDraw()
end

function Player:setKeepDrawing(set)
	if set == nil then
		set = not self.drawing.keep_drawing
	else
		set = set--self.drawing.keep_drawing
	end
	
	if self.drawing.keepDrawingId then
		self.drawing.keepDrawingId = tfm.exec.removeImage(self.drawing.keepDrawingId, false)
	end
	
	if set then
		self.drawing.keep_drawing = true
		
		if self.drawing.consecutive_points > 0 then
			local point = self.drawing.points[#self.drawing.points]
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
	
	return xc, yc
end

function Player:registerPoint(x, y)
	local drawing = self.drawing
	if drawing.finished then return end
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
		
		point.i1 = tfm.exec.addImage(
			"185e1bf0bb4.png", "!100", 
			point.x, point.y,
			self.name,
			0.25, 0.25,
			0, 1.0,
			0.5, 0.5,
			false
		)
	
		if drawing.consecutive_points >= 2 then
			local previous = drawing.points[index - 1]
			
			local sx = math.pythag(point.x, point.y, previous.x, previous.y) / 40
			local an = math.atan2(previous.y - point.y, previous.x - point.x)
			
			point.i2 = tfm.exec.addImage(
				"185e1bebf8a.png", "!100",
				point.x, point.y,
				self.name,
				sx, 0.25,
				an, 1.0,
				0.0, 0.5,
				false
			)
		end
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
	--self:previewLineToDraw()
end

function Player:undoDrawingAction()
	local drawing = self.drawing
	
	if drawing.consecutive_points > 0 then
		self:removePoint(-1)
		--[[if drawing.consecutive_points == 1 then
			self:registerPoint(0, 0)
			self:finishLine()
		end]]
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
				tfm.exec.chatMessage("Canvas Error")
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
	
	printt(drawing)
	
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
			table.remove(line, #line - offset)
			
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
			point.lineId = #drawing.lines + 1
			line[#line + 1] = table.unreference(point)
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
	if self.crafting.active and self.crafting.size == 3 and self.drawing.active then
		self:setData("hans", self.drawing.hanId, true)
		self:pushItem(4, false) -- self:insertItem(9, 1)
		system.giveAdventurePoint(self.name, "evt_hoppy_cny_drawn", "1")
		system.giveEventGift(self.name, "evt_hoppy_cny_golden_ticket_1")
		self:playSound("deadmaze/niveau/gain_niveau.mp3", 100, nil, nil)
	end
end

function Player:finishDrawing()
	local han = enum.han[self.drawing.hanId]
	
	self:finishLine()
	self:correctDrawing(han)
	
	if self:assertDrawing(han) then
		self:drawingSuccess()
	else
		printf("Your drawing is bad.")
	end
	
	self.drawing.finished = true
	
	HanPreview:hide(self.name)
	
	Timer.new(1000, false, function()
		self:closeDrawing()
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
					if pdist > 40 then
						return false
					end
					
					p_han = l_han[#l_han]
					p_draw = l_draw[#l_draw]
					
					pdist = math.pythag(p_han.x, p_han.y, p_draw.x, p_draw.y)
					if pdist > 40 then
						return false
					end
				end
				pdist = math.udist(l_han.angle, l_draw.angle)
				if pdist > (22.5 * #l_han) then
					return false
				end
				
				pdist = math.udist(l_han.large, l_draw.large)
				if pdist > (40 * #l_han) then
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

function Player:closeDrawing()
	do
		self:playBackgroundMusic(true)
		tfm.exec.setPlayerGravityScale(self.name, 1.0, 0.0)
		tfm.exec.freezePlayer(self.name, false, false)
		
		self.drawing.active = false
	end
	
	-- Remove line images, to do
	
	for index, point in next, self.drawing.points do
		if point.i1 then tfm.exec.removeImage(point.i1, false) end
		if point.i2 then tfm.exec.removeImage(point.i2, false) end
	end
	if self.drawing.keepDrawingId then tfm.exec.removeImage(self.drawing.keepDrawingId) end
	self.drawing.lines = {}
	self.drawing.points = {}
	self.drawing.active = false
	
	HanPreview:hide(playerName)
	
	self:hideOffscreen(false)
	--self:showCrafting(true)
end

function Player:initInventory()
	local size = #enum.items
	local sqr = 40
	local sep = 10
	
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
			dy = 350,
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
	
	if show then
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
	end
end

function Player:setCrafting(size)
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
end

function Player:closeCrafting()
	for i=1, #self.crafting do
		if i ~= #self.crafting then
			self:pushItem(i, false)
		end
	end
	
	self:showCrafting(false)
	
	self.crafting = {}
	
	self.crafting.active = false
end

function Player:showInventoryItem(id, show)
	local item = self.items[id]
	if show then
		if item.amount > 0 then
			item.spriteId = tfm.exec.addImage(
				item.sprite,
				":10",
				item.dx, item.dy,
				self.name,
				item.dscale, item.dscale,
				0.0, 1.0,
				0.0, 0.0,
				true
			)
			
			if item.amount > 1 then
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
	if show then
		self.items.displaying = true
		
		self.items.coverId = 800
		ui.addTextArea(800, "", self.name, 125, 350, 550, 55, 0x7d4f4f, 0xb57474, 1.0, true)
		--[[self.items.coverId = tfm.exec.addImage(
			"TO DEFINE", ":1",
			"TO DEFINE", "TO DEFINE", -- X, Y
			self.name,
			"TO DEFINE", "TO DEFINE",
			0, 1.0, 
			0.0, 0.0,
			true
		)]]
		
		for i, item in ipairs(self.items) do
			self:showInventoryItem(i, nil)
		end
	else
		self.items.displaying = false
		
		for i, item in ipairs(self.items) do
			self:showInventoryItem(i, false)
		end
		
		if self.items.coverId then
			self.items.coverId = ui.removeTextArea(800, self.name)
			--self.items.coverId = tfm.exec.removeImage(self.items.coverId, true)
		end
		
		if show == nil then
			self:showInventory(true)
		end
	end
	
	self:setSelectedSlot(nil)
end

function Player:pushItem(id, into)
	id = id or self.items.selected
	if into then
		local item = self.items[id]
		if self.crafting.size == 3 and id < 6 or id == 9 then
			return false
		elseif self.crafting.size == 5 and id > 6 then
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
						item.sprite, ":1",
						item.dx, item.dy,
						self.name,
						item.dscale, item.dscale,
						0.0, 1.0,
						0.0, 0.0,
						false
					)
					
					self:extractItem(id, 1)
					local r = self:fetchRecipes(false)
					
					if #r > 0 then
						local result = r[1].recipe.result
						
						local rsl = self.crafting[#self.crafting]
						
						rsl.amount = 1
						rsl.id = result.id
						rsl.sprite = enum.items[rsl.id].sprite
						
						rsl.spriteId = tfm.exec.addImage(
							rsl.sprite, ":1",
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
	else -- out of
		local item = self.crafting[id]
		
		if item then
			if item.id ~= 0 then
				if item.amount >= 1 then
					item.amount = 0
					item.sprite = nil
					item.spriteId = tfm.exec.removeImage(item.spriteId, false)
					
					
					self:insertItem(item.id, 1)
					item.id = 0
				end
				
				if id == #self.crafting then
					local ax
					for i=1, #self.crafting do
						ax = self.crafting[i]
						ax.amount = 0
						ax.sprite = nil
						ax.spriteId = tfm.exec.removeImage(ax.spriteId or -1, false)
						ax.id = 0
					end
				end
			end
		end
	end
end

function Player:setSelectedSlot(id, push)
	self.items.selected = (id or self.items.selected)
	
	if self.items.selected > 0 then
		if push then
			if self.crafting.active then
				self:pushItem(id, true)
			end
		end
		
		local item = self.items[self.items.selected]
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
	
	if self.drawing.active then return end

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
		
		if item.id == 8 then
			system.giveAdventurePoint(self.name, "evt_hoppy_cny_lamps", "1")
			system.giveEventGift(self.name, "evt_hoppy_cny_golden_ticket_1")
		elseif item.id == 9 then
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

function Player:displayRecipe(r, display, callback)
	r = self:convertRecipe(r)
	
	-- ...
end

function Player:hideRecipe(r)
	-- ...
end

function Player:assertRecipe(recipe)
	recipe = self:convertRecipe(recipe)
		
	if not recipe then return false, 0 end
	if not self.crafting.active then return false, 0 end
	
	local isAvailable = true
	local hasMatch
	for _, item in next, recipe.craft do
		hasMatch = false
		for i = 1, #self.crafting - 1 do
			if item.id == self.crafting[i].id then
				
				if item.amount > self.crafting[i].amount then
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

function Player:fetchRecipes(returnAll)
	local recipes = {}
	
	local isAvailable
	local item
	
	for index, recipe in next, enum.recipes do
		isAvailable = self:assertRecipe(recipe)
		
		if isAvailable or returnAll then
			recipes[#recipes + 1] = {
				recipe = recipe,
				available = isAvailable
			}
		end
	end
	
	return recipes
end

function Player:newDialog(npcName, dialogId, noDist)
	if self.onDialog then
		self:closeDialog()
	end

    local Npc = npcList[npcName]
	if not Npc then return end
	
	
    self.onDialog = {
		oldCursor = 1,
		cursor = 1,
		Text = "",
		pInf = {},
		Npc = {},
		currentText = "",
		displayText = "",
		directAccess = 0,
		windowId = 0,
		displayInfo = {},
		finished = false,
		completed = false,
		pointer = 0,
		sprite = "185d44bafbb.png",
		distHide = not noDist
    }

	self:setDialogDisplay("new")
end

function Player:setDialogDisplay(instruction)
	local Dialog = self.onDialog

	if Dialog then
		if instruction == "new" then
			local id = tfm.exec.addImage(Dialog.sprite, ":1", 25, 394, self.name, 0.25, 0.25, 0, 1.0, 0, 1.0, true)
			Dialog.directAccess = 2000 + (id or 0)
			ui.addTextArea(Dialog.directAccess, "", self.name, 50, 335, 685, 38, 0x0, 0x0, 1.0, true)

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
				if (self.language == "ar") or (self.language == "he") then
					Dialog.currentText = reverseWords(Dialog.currentText, true)
				end
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
		local showOpts = false
		
		if showOpts then
			--[[
			if not self.seekingInstrument.onIt then
				ui.addTextArea(
					Dialog.directAccess + 1,
					styles.refdlg:format(Dialog.Npc.key .. "-" .. o1, translate("instruct " .. o1, self.language, self.gender)),
					self.name,
					x - 50, y,
					100, 0,
					ts, ts,
					0.4, true
				)


			end

			ui.addTextArea(
				Dialog.directAccess + 2,
				styles.refdlg:format(Dialog.Npc.key .. "-" .. o2, translate("instruct " .. o2, self.language, self.gender)),
				self.name,
				x + 50, y,
				100, 0,
				ts, ts,
				0.4, true
			)

			print("[Debug] Dialog Npc key: " .. Dialog.Npc.key)
			]]
		else
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

		self:onDialogClosed(Dialog.Npc.key, Dialog.pInf)
    end

	self.onDialog = false
end

function Player:onDialogClosed(npcName, pid)
	-- Placeholder
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