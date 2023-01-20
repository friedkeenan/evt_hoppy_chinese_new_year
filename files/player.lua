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
		drawing = {
			active = false,
			lines = {},
			points = {},
			keepDrawingId = 0,
			finished = false,
			consecutive_points = 0,
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
			
		local track = music[math.random(#music)]
			
		self:playMusic(track, "Main", 60, true, true)
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
			self.progress["i"..i] =1-- self:getData("i" .. i) or 0
		end
		
		self.progress.hans = 1--self.progress.hans or 0
		self.progress.inst = 1--self.progress.inst or 0
	end
	
	self:initInventory()
	
	tfm.exec.addNPC("Mirko", {
		title = 468,--228,
		look = "210;23_FFFFFF+FFFFFF+FFFFFF,0,11_FFFFFF+FFFFFF,45,69_10101+F9FFFF+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+FFEFD8+FFEFD8,49_FFFFFF+FFFFFF+FFFFFF+FFFFFF,0,23,0",
		x = 90, -- 745
		y = 337, -- 196
		female = true,
		lookAtPlayer = true,
		interactive = true
	}, self.name)

	self:playBackgroundMusic(true)
end

function Player:saveData()
	local rawdata = data.encode(self.progress)
	self.dataFile = data.setToModule(self.dataFile, "HCNY", rawdata)

	system.savePlayerData(self.name, self.dataFile)
end

function Player:setData(key, value, write)
	self.progress[key] = value
	if write then
		self:saveData()
	end
end

function Player:getData(key)
	return self.progress[key] or 0
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

function Player:initDrawing()
	self.drawing = {
		active = true,
		lines = {},
		points = {},
		consecutive_points = 0,
		keep_drawing = false,
		keepDrawingId = -1,
		finished = false
	}
	do
		tfm.exec.freezePlayer(self.name, true, false)
		tfm.exec.setPlayerGravityScale(self.name, 0, 0)
		tfm.exec.movePlayer(self.name, 0, 0, true, 0, 0, false)
		
		self:playBackgroundMusic(false)
	end
	
	self:hideOffscreen(true, 0x010101)
	self:setForeground(false)
end

function Player:setKeepDrawing(set)
	if set == nil then
		set = not self.drawing.keep_drawing
	else
		set = self.drawing.keep_drawing
	end
	
	if set then
		self.drawing.keep_drawing = true
	else
		if self.drawing.consecutive_points >= 2 then
			self:finishLine()
		else
			self.drawing.keep_drawing = true
		end
	end
end

function Player:registerPoint(x, y)
	local drawing = self.drawing
	if drawing.finished then return end
	local count = drawing.consecutive_points
	local index = #drawing.points + 1
	
	print("register point")
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
		local point = drawing.points[index]
		
		if drawing.keepSpriteId then
			drawing.keepSpriteId = tfm.exec.removeImage(drawing.keepSpriteId, false)
		end
		
		drawing.keepSpriteId = tfm.exec.addImage(
			"185cd3b62c5.png", "!100",
			point.x, point.y,
			self.name,
			1.0, 1.0,
			0, 0.25,
			0.5, 0.5,
			true
		)
		
		point.i1 = tfm.exec.addImage(
			"185cd3b62c5.png", "!100", 
			point.x, point.y,
			self.name,
			0.25, 0.25,
			0, 1.0,
			0.5, 0.5,
			false
		)
		
		drawing.consecutive_points = count + 1
		if drawing.consecutive_points >= 2 then
			local previous = drawing.points[index - 1]
			
			local sx = math.pythag(point.x, point.y, previous.x, previous.y) / 40
			local an = math.atan2(previous.y - point.y, previous.x - point.x)
			
			point.i2 = tfm.exec.addImage(
				"185cd3b163f.png", "!100",
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

function Player:startLine()
	self:setKeepDrawing(true)
	self:playSound("deadmaze/objectif2.mp3", 100, nil, nil)
end

function Player:finishLine()
	local drawing = self.drawing
	
	if drawing.consecutive_points >= 2 then
		local line = {}
		local start = (#drawing.points - drawing.consecutive_points) + 1
		local point
		for i = start, #drawing.points do
			point = drawing.points[i]
			
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
			
			angle = math.abs(math.atan2(a.y - b.y, a.x - b.x))
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
	
	drawing.consecutive_points = 0
end

function Player:correctDrawing() -- Regulate drawing: scale, pos
	local drawing = self.drawing
	
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
	
	local xFactor = 200 / width
	local yFactor = 200 / height
	
	printf("Width: %d, Height: %d", width, height)
	printf("xFact: %f, yFact: %d", xFactor, yFactor)
	printf("xMin: %d, yMinf: %d", xMin, yMin)
	
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

function Player:finishDrawing()
	self:finishLine()
	self:correctDrawing()
	
	local symbols_done = self:getData("hans")
	
	if self:assertDrawing(enum.han[symbols_done + 1]) then
		printf("Your drawing is correct for this Han")
		self:setData("hans", symbols_done + 1, true)
		self:insertItem(9, 1)
	else
		printf("Your drawing is bad.")
	end
	
	self.drawing.finished = true
	
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
		printf("drawing: %d, han: %d", #drawing.lines, #han.lines)
		if #drawing.lines == #han.lines then
			for i = 1, #han.lines do
				l_han = han.lines[i]
				l_draw = drawing.lines[i]
				
				do
					p_han = l_han[1]
					p_draw = l_draw[1]
					
					pdist = math.pythag(p_han.x, p_han.y, p_draw.x, p_draw.y)
					printf("hx: %d, hy: %d, px: %d, py: %d", p_han.x, p_han.y, p_draw.x, p_draw.y)
					printf("Distance 1: %f", pdist)
					if pdist > 30 then
						return false
					end
					
					p_han = l_han[#l_han]
					p_draw = l_draw[#l_draw]
					
					pdist = math.pythag(p_han.x, p_han.y, p_draw.x, p_draw.y)
					printf("hx: %d, hy: %d, px: %d, py: %d", p_han.x, p_han.y, p_draw.x, p_draw.y)
					printf("Distance 2: %f", pdist)
					if pdist > 30 then
						return false
					end
				end
				pdist = math.udist(l_han.angle, l_draw.angle)
				printf("A1: %f, A2: %f, Angle dif: %f", l_han.angle, l_draw.angle, pdist)
				if pdist > 34 then
					return false
				end
				
				pdist = math.udist(l_han.large, l_draw.large)
				printf("Lenght dif: %f", pdist)
				if pdist > (40 * #han.lines) then
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
	
	self:hideOffscreen(false)
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

function Player:setCrafting(size)	
	local slots = {}
	if size == 3 then
		slots = {
			{x=400, y=100},
			{x=250, y=300},
			{x=550, y=300}
		}
	elseif size == 5 then
		slots = {
			{x = 400, y = 75},
			{x = 225, y = 200},
			{x = 575, y = 200},
			{x = 315, y = 325},
			{x = 485, y= 325}
		}
	end
	
	for i=1, size do
		self.crafting[i] = {
			dx = slots[i].x - 20,
			dy = slots[i].y - 20,
			id = 0,
			amount = 0,
			dscale = 0.5,
			sprite = nil,
			spriteId = -1
		}
	end
	
	self.crafting[size + 1] = {
		dx = 360,
		dy = 160,
		id = 0,
		amount = 0,
		dscale = 1.0,
		sprite = nil,
		spriteId = -1
	}
	
	for i = 1, #self.crafting do
		local slot = self.crafting[i]
		ui.addClickable(300 + i, slot.dx, slot.dy, 80 * slot.dscale, 80 * slot.dscale, self.name, "craft_action", true)
	end
	self.crafting.active = true
	self.crafting.size = size
end

function Player:closeCrafting()
	for i = 1, #self.crafting do
		ui.removeClickable(300 + i, self.name)
		if i ~= #self.crafting then
			self:pushItem(i, false)
		else
			if self.crafting[#self.crafting].spriteId then
				tfm.exec.removeImage(self.crafting[#self.crafting].spriteId, false)
			end
		end
	end
	
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
		
		self.items.coverId = tfm.exec.addImage(
			"TO DEFINE", ":1",
			"TO DEFINE", "TO DEFINE", -- X, Y
			self.name,
			"TO DEFINE", "TO DEFINE",
			0, 1.0, 
			0.0, 0.0,
			true
		)
		
		for i, item in ipairs(self.items) do
			self:showInventoryItem(i, nil)
		end
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
		Text = textInfo,
		pInf = dialog,
		Npc = {},
		currentText = "",
		displayText = "",
		directAccess = 0,
		windowId = 0,
		displayInfo = {},
		finished = false,
		completed = false,
		pointer = 0,
		sprite = Npc.dialogSprite,
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
    tfm.exec.stopMusic('musique')
    tfm.exec.playMusic(music, channel, volume, loop, fade, self.name)
end

function Player:playMusicDelay(delay,music,channel,volume,loop,fade)
    system.newTimer(function()
		self:playMusic(music,channel,volume,loop,fade)
	end,delay)
end

function Player:stopMusic(channel,fadeOut)
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