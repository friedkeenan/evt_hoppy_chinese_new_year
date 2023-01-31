local eventName = "evt_hoppy_cny"

local fileList = {
    [1] = "xml",
    [2] = "init",
    [3] = "utils",
    [4] = "data",
    [5] = "interface",
    [6] = {
        path = "translations",
        files = {
            "main",
            "en", "es", "br", "fr", "pl",
            "he", "it", "ro", "ru", "ar",
            "cn", "nl", "tr", "lt", "hu",
            "tl", "fi"
        }
    },
    [7] = "player",
    [8] = "sound",
    [9] = "character",
    [10] = "definitions",
    [11] = {
        path = "events",
        files = {
            "newGame",
            "time",
            "presence",
            "input"
        }
    },
    [12] = "start"
}

local releaseMode = false

local fileTable = {}
local File

local readPath
readPath = function(pathName, subPath)
    subPath = subPath or "./files"
    local ft = {}
    if type(pathName) == "table" then
        subPath = pathName.path and ("./files/%s"):format(pathName.path) or "./files"
        for fileIndex, fileName in ipairs(pathName.files) do
            ft[#ft + 1] = readPath(fileName, subPath)
        end

        return table.concat(ft, '\n')
    else
        local p = ("%s/%s.lua"):format(subPath, pathName)
        print(p)
        local File = io.open(p, "r")
        if File then
            local f = File:read("*all")
            File:close()
            print((">>> [success] %s.lua"):format(pathName))
            return ("-- >> %s.lua\n%s\n-- %s.lua << --"):format(pathName, f, pathName)
        else
            print(("/!\\ [failure] %s.lua"):format(pathName))
        end
    end
end

local luaEvent = readPath({files=fileList})

if releaseMode then
    luaEvent = luaEvent:gsub("%-%-%[%[.-%]%]", "")
    luaEvent = luaEvent:gsub("%-%-.-\n", "\n")
    --  evt_music = evt_music:gsub("\n\n", "\n")
    luaEvent = luaEvent:gsub("print[^=]-%b()", "")
end

File = io.open(eventName .. ".lua", "w+")
File:write(luaEvent)
File:close()
print(("\nFile written on %s.lua"):format(eventName))

do
    print("\n[TEST] Asserting build...")
    local ok, result
    local Test
    Test, result = loadstring(("-- %s%s\n%s%s"):format(eventName, (' '):rep(20), 'require("tfmenv")\n', luaEvent))

    if Test then
        ok, result = pcall(Test)
        if ok then
            print("[TEST] Event executes correctly!")
        else
            print("[TEST]" .. result)
        end
    else
        print(result)
    end
end