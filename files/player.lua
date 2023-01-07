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

function Player:setDrawing(set)
	if set then
		tfm.exec.freezePlayer(self.name, true)
		tfm.exec.setGravityScale(self.name, 0, 0)
		
		local drawing_area = 800 + ((self.uniquePlayerId - 1) * 400) -- To do: adjust
		tfm.exec.movePlayer(self.name, 100, drawing_area, false, 0, 0, false)
		
		-- ADD UI
	else
		tfm.exec.movePlayer(self.name, 150, 300, false, 0, 0, false) -- To do: Put better coordinates
		tfm.exec.setPlayerGravityScale(self.name, 1, 0)
		tfm.exec.freezePlayer(self.name, false, false)
		
		-- REMOVE UI
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