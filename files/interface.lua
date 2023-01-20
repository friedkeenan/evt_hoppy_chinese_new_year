ui.addClickableImage = function(imageId, imgTarget, targetPlayer, height, width, event, x, y, xScale, yScale, alpha, fadeIn)
	imgTarget = imgtarget or "~1"
	local tHeight = height * yScale
	local tWidth = width * xScale
	local id = tfm.exec.addImage(imageId, imgTarget, x, y, targetPlayer, xScale, yScale, 0.0, alpha, 0, 0, fadeIn)

	ui.addClickable(10000 + id, x, y, tWidth, tHeight, targetPlayer, event, true)

	return id
end

ui.removeClickable = function(id, targetPlayer)
	ui.removeTextArea(id + 25000, targetPlayer)
end

ui.addClickable = function(id, xPosition, yPosition, width, height, targetPlayer, event, fixedPos)
	id = (id or 0) + 25000
	ui.addTextArea(
		id,
		("<textformat leftmargin='1' rightmargin='1'><a href='event:%s'>%s</a></textformat>"):format(event or "clickable", ("\n"):rep(20)),
		targetPlayer,
		xPosition, yPosition,
		width, height,
		0xFF00FF, 0xFF00FF,--0x0, 0x0,
		0.33, fixedPos
	)

	return id
end

ui.removeClickableImage = function(id, fadeOut)
	tfm.exec.removeImage(id, fadeOut)
	ui.removeClickable(10000 + id)
end
