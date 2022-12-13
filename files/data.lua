local data = {}

do
	local xCHAR = string.char(17)
	data.getFromModule = function(str, MODULE)
		
		local rawdata = str:match(("%s (.-)%s"):format(MODULE or "", xCHAR))
		if rawdata and rawdata ~= ("") then
			return rawdata
		else
			print(("Could not find data for module '%s'"):format(MODULE))
		end
		
		return ""
	end

	data.setToModule = function(str, MODULE, rawdata)
		local pattern = ("%s (.-)%s"):format(MODULE or "", xCHAR)
		local oldModuleData = str:match(pattern)
		local newData
		
		local newstr = ("%s %s%s"):format(MODULE, rawdata, xCHAR)
		
		if oldModuleData then
			newData = str:gsub(pattern, newstr)
		else
			if MODULE then
				newData = ("%s%s"):format(str, newstr)
			end
		end
		
		return newData, rawdata, str, oldModuleData
	end
end

data.decode = function(str, depth)
	depth = depth or 1
	local this = {}
	local count = 1

	local pattern = "[^" .. string.char(17 + depth) .. "]+"
	
	local key, value
	for INFO in str:gmatch(pattern) do
		key, value = INFO:match("(%w+)=(.+)")
		if not key then
			key = count
			value = INFO
			count = count + 1
		end
		this[key] = data.parse(value or "", depth)
	end
	
	return this
end

data.parse = function(str, depth)
	local booleans = {
		["+"] = true,
		["-"] = false
	}
	if booleans[str] ~= nil then
		return booleans[str]
	end
	
	local value = str:match('^"(.-)"$')
	if value then
		return value
	else
		value = str:match("^{(.-)}$")
		if value then
			return data.decode(value, depth + 1)
		else
			return tonumber(str) or str
		end
	end
end

data.serialize = function(this, depth)
	local value = ""
	depth = depth or 0
	if type(this) == "table" then
		local concat = {}
		for k, v in next, this do
			concat[#concat + 1] = data.serialize(v, depth + 1)
		end
		value = ("{%s}"):format(table.concat(concat, string.char(17 + depth)))
	else
		if type(this) == "number" then
			value = tostring(this)
		elseif type(this) == "boolean" then
			value = this and "+" or "-"
		elseif type(this) == "string" then
			value = ('"%s"'):format(this)
		end
	end
	
	return value
end

data.encode = function(this, depth)
	depth = depth or 1
	local separator = string.char(17 + depth)
	local str = {}
	local k, v
	for key, value in next, this do
		k, v = key, data.serialize(value, depth + 1)
		str[#str + 1] = ("%s=%s"):format(k, v)
	end
	
	return table.concat(str, separator)
end
