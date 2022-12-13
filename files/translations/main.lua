local reverseWords = function(text, reversePunctuation)
	local aux = {}
	local str = {}

	for word in text:gmatch("%S+") do
		if reversePunctuation then
			word = word:gsub("(%P+)(%p+)", "%2%1")
		end
		aux[#aux + 1] = word
	end

	for i=#aux, 1, -1 do
		str[#str + 1] = aux[i]
	end

	return table.concat(str, " ")
end


local Text = {}
local translate
translate = function(resource, language, gender, _format)
    language = Text[language] and language or "xx"

    local obj = table.unreference(Text[language])
    for key in resource:gmatch("%S+") do
        if type(obj) == "table" then
            obj = obj[tonumber(key) or key]
            if not obj then
                break
            end
        else
            break
        end
    end

    if obj then
		if type(obj) == "table" then
			if gender then
				local t = {}
				
				for index, val in next, obj do
					t[index] = (type(val) == "string" and utils.getGendered(val, gender) or val)
				end
				
				return t
			end
		else
			if gender and obj:find("%(.-%)") then
				obj = utils.getGendered(obj, gender)
			end
			
			if type(_format) == "table" then
				for key, value in next, _format do
					obj = obj:gsub("%$"..key.."%$", tostring(value))
				end
			else
				return tostring(obj)
			end
		end
    else
        if language ~= "xx" then
            translate(resource, "xx", gender, _format)
        else
            obj = resource:gsub(" ", "%.")
        end
    end

    return obj or resource:gsub(" ", "%.")
end