local welcomeMessageTimer = -1
function eventNewGame()
	if not isEventLoaded then
		isEventLoaded = true
		
		ui.setMapName("Hoppy Chinese New Year !") -- Move to translations
		-- ui.setBackgroundColor()
		tfm.exec.setGameTime(153) -- 2:30 (+ 3s) PENDING TO DEFINE
		
		tfm.exec.stopMusic("musique")
		
	else -- Event loads twice
		Timer.remove(welcomeMessageTimer)
		system.newTimer(system.exit, 500, false)
		error("Illegal Event Load")
	end
end