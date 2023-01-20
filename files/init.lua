if (tfm.get.room.uniquePlayers < 5 or tfm.get.room.uniquePlayers > 75) and not (tfm.get.room.playerList["Indexinel#5948"] or tfm.get.room.playerList["Drgenius#0000"]) then
	return system.exit()
end

local debugMode = true
local printToChat = true
local isEventLoaded = false

local noTimeLeft = false

local system = system
local tfm = tfm
local ui = ui

local debug = debug
local math = math
local os = os
local table = table
local string = string

system.disableChatCommandDisplay(nil)

math.randomseed(os.time())
--system.luaEventLaunchInterval(math.random(40, 55), math.random(10)) !! PENDING TO DEFINE !!

local admins = {
	["Indexinel#5948"] = true,
	["Drgenius#0000"] = true,
	["Chibi#0095"] = true
}

local styles = {}
local enum = {}

local IRL_CHINESE_FESTIVAL = false

local href = "<a href='event:%s'>%s</a>"

do	
	local p = (printToChat and (function(a) tfm.exec.chatMessage(a, nil) end) or print)
	local tc = table.concat
	local ts = tostring
	print = function(...)
		if debugMode then
			local args = {...}
			for i=1, #args do
				args[i] = ts(args[i])
			end
			p(tc(args, " "))
		end
	end

	if debugMode then
		printf = function(str, ...)
			print(("[Debug] %s"):format(str:format(...)))
		end
		
		system.giveEventGift = function(playerName, giftCode)
			tfm.exec.chatMessage(("%s has received '%s'"):format(playerName, giftCode))
		end
	else
		printf = function(str, ...)
			print(str:format(...))
		end
	end
	
	local date = os.date("*t", os.time() / 1000)
	
	print(date.month, date.day)
	if (date.month == 1 and date.day >= 22) or (date.month == 2 and date.day <= 5) then
		IRL_CHINESE_FESTIVAL = true
	end
	
end

tfm.exec.disableAfkDeath(true)
tfm.exec.disableAutoShaman(true)
tfm.exec.disableAutoTimeLeft(true)
tfm.exec.disableDebugCommand(not debugMode)
tfm.exec.disableMinimalistMode(true)
tfm.exec.disableMortCommand(true)
tfm.exec.disableAutoNewGame(true)
tfm.exec.disablePhysicalConsumables(true)

local currentTime = os.time

local keys = {0, 1, 2, 3, 13, 32, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 69} -- Remember to delete 48

local playerList = {}

local Player = {}
Player.__index = Player