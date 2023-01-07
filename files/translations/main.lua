local Text = {}

do
	local concat = table.concat
	
	function Text:reverseWords(str, punctuation)
		local aux = {}
		local this = {}
		
		for word in str:gmatch("%S+") do
			if punctuation then
				word = word:gsub("(%P+)(%p+)", "%2%1")
			end
			
			aux[#aux + 1] = word
		end
		
		for i = #aux, 1, -1 do
			str[#str + 1] = aux[i]
		end
		
		return concat(this, " ")
	end
end

function Text:get(resource, language, gender, format)
    language = self[language] and language or "xx"

    local obj = table.unreference(self[language])
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
					
					if language == "ar" or language == "he" then
						t[index] = self:reverseWords(t[index], true)
					end
				end
				
				obj = t
			end
		else
			if gender and obj:find("%(.-%)") then
				obj = utils.getGendered(obj, gender)
			end
			
			if type(format) == "table" then
				for key, value in next, format do
					obj = obj:gsub("%$"..key.."%$", tostring(value))
				end
			else
				obj = tostring(obj)
			end
			
			if language == "ar" or language == "he" then
				obj = self:reverseWords(obj, true)
			end
		end
    else
        if language ~= "xx" then
            obj = self:get(resource, "xx", gender, format)
        else
            obj = resource:gsub(" ", "%.")
        end
    end

    return obj or resource:gsub(" ", "%.")
end