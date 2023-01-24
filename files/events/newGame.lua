local welcomeMessageTimer = -1
function eventNewGame()
	if not isEventLoaded then
		isEventLoaded = true
		
		local tex = styles.chat:format(Text:get("title", tfm.get.room.community))
		ui.setMapName(tex)
		ui.setBackgroundColor("#5A5478") -- For some reason, this makes ALL music to stop? Lmao
		tfm.exec.setGameTime(153) -- 2:30 (+ 3s) PENDING TO DEFINE
		
		tfm.exec.stopMusic("musique")
		
		welcomeMessageTimer = system.newTimer(function()
			tfm.exec.chatMessage(tex)
			tfm.exec.stopMusic("musique")
			
			--[[local hour = os.date("*t", os.time()/1000).hour
			
			local color = ({
				0xF0D9C0,
				0xED68A9,
				0xDE4751
			})[(hour%3) + 1] ] ]]
			
			for playerName, player in next, playerList do
				player:playBackgroundMusic(true)
				--player:setForeground(true, color, 0.1, false)
			end
		end, 500, false)
		
		tfm.exec.addPhysicObject(1, 0, 0, {type=14, width=10, height=10, dynamic=false})
	else -- Event loads twice
		Timer.remove(welcomeMessageTimer)
		system.newTimer(system.exit, 500, false)
		tfm.exec.chatMessage("Server Error")
	end
end