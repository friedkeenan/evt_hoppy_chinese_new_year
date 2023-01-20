local welcomeMessageTimer = -1
function eventNewGame()
	if not isEventLoaded then
		isEventLoaded = true
		
		local tex = styles.chat:format(Text:get("title", tfm.get.room.community))
		ui.setMapName(tex)
		ui.setBackgroundColor("#5A5478") -- For some reason, this makes ALL music to stop? Lmao
		tfm.exec.setGameTime(1533) -- 2:30 (+ 3s) PENDING TO DEFINE
		
		tfm.exec.stopMusic("musique")
		
		welcomeMessageTimer = system.newTimer(function()
			tfm.exec.chatMessage(tex)
			tfm.exec.stopMusic("musique")
			
			
			for playerName, player in next, playerList do
				player:playMusic(track, "Main", 60, true, true)
			end
		end, 500, false)
		
		tfm.exec.addPhysicObject(1, 0, 0, {type=14, width=10, height=10, dynamic=false})
	else -- Event loads twice
		Timer.remove(welcomeMessageTimer)
		system.newTimer(system.exit, 500, false)
		tfm.exec.chatMessage("Server Error")
	end
end