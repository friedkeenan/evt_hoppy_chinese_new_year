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
		
		items = {}
	}, self)
	
	this.__index = self
	
	do
		tfm.exec.lowerSyncDelay(this.name)
		
		for keyId, _ in next, keys do
			system.bindKeyboard(this.name, keyId, true, true)
			system.bindKeyboard(this.name, keyId, false, true)
			this.keys[keyId] = false
		end
		
	end

	return this
end

function Player:init(rawdata, reset)
    reset = reset or false
	if rawdata then
		local moduleData = data.getFromModule(rawdata, "HCNY")
		self.progress = data.decode(moduleData)
		self.dataFile = rawdata
	end
	
	tfm.exec.addNPC("Mirko", {
		title = 468,--228,
		look = "210;23_FFFFFF+FFFFFF+FFFFFF,0,11_FFFFFF+FFFFFF,45,69_10101+F9FFFF+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+C7BFB9+FFEFD8+FFEFD8,49_FFFFFF+FFFFFF+FFFFFF+FFFFFF,0,23,0",
		x = 90, -- 745
		y = 337, -- 196
		female = true,
		lookAtPlayer = true,
		interactive = true
	}, self.name)
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
end

function Player:handleNear(x, y, vx, vy)
	if x > 700 and x < 1000 then
		ui.addClickable(1, 700, 150, 300, 50, self.name, "craftable", false)
	else
		ui.removeClickable(1, self.name)
	end
	
	if (x > 0 and x < 175) and y < 150 then
		ui.addClickable(2, 25, 50, 150, 50, self.name, "items", false)
	else
		ui.removeClickable(2, self.name)
	end
end

function Player:insertItem(itemId, amount)
	local item = self.items[itemId]	
	
	if item then
		amount = amount or 1
		item.amount = math.min(item.amount + amount, 99)
		
		
		self:setData(item.keyPos, item.amount, true)
		
		-- If displaying inventory, then reload display.
		
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
			
			self:setData(item.keyPos, item.amount, true)
			
			-- If displaying inventory, then reload display.
		else
			return false
		end
	end
end

function Player:convertRecipe(recipe)
	if type(recipe) == "number" then
		return enum.recipes[recipe]
	elseif type(recipe) == "table" then
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
	
	local isAvailable = true
	
	for _, item in next, recipe.craft do
		if item.q > self.items[item.i].amount then
			isAvailable = false
			break
		end
	end
	
	return isAvailable, recipe.result
end

function Player:fetchRecipes(returnAll)
	local recipes = {}
	
	local isAvailable
	local item
	
	for index, recipe in ipairs(enum.recipes) do
		isAvailable = self:assertRecipe(recipe)
		
		if isAvailable or returnAll then
			recipes[#recipes + 1] = {
				recipe = recipe,
				available = isAvailable
			}
		end
	end
end