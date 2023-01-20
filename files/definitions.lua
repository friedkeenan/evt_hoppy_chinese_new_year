styles = {}

styles.regular = "<font face='Century Schoolbook,Baskerville,Baskerville Old Face,Hoefler Text,Garamond,Times New Roman,serif'>%s</font>"
styles.chat = "<font color='#FE5148'>%s</font>"
styles.invq = styles.regular:format("<D>%d</D>")


enum.items = {
	[1] = {
		name = "rope",
		sprite = "185cb482627.png"
	},
	[2] = {
		name = "wood",
		sprite = "185cb47d130.png"
	},
	[3] = {
		name = "scissors",
		sprite = "185cb86d5af.png"
	},
	[4] = {
		name = "glue",
		sprite = "185cbb6a564.png"
	},
	[5] = {
		name = "paper",
		sprite = "185cb47d130.png"
	},
	[6] = {
		name = "paint",
		sprite = "185cb487320.png"
	},
	[7] = {
		name = "paint_brush",
		sprite = "185cb47d130.png"
	},
	[8] = {
		name = "lamp",
		sprite = "185cb47d130.png",
	},
	[9] = {
		name = "lamp_final",
		sprite = "185cb47d130.png"
	}
}

for i = 1, 9 do
	local e = enum.items[i]
	enum.items[e.name] = e
end

enum.recipes = {
	lamp = {
		craft = {
			{id=1, amount=1},
			{id=2, amount=1},
			{id=3, amount=1},
			{id=4, amount=1},
			{id=5, amount=1}
		},
		result = {id=8, amount = 1}
	},
	lamp_final = {
		craft = {
			{id=8, amount=1},
			{id=6, amount=1},
			{id=7, amount=1}
		},
		result = {id=9, amount=1}
	}
}

enum.recipes[8] = enum.recipes.lamp
enum.recipes[9] = enum.recipes.lamp_final

do
	enum.han = {
		[1] = {
			name = "",
			lines = {
				[1] = { -- Line
					{x=0, y=0},
					{x=200, y=0},
					{x=200, y=200},
					{x=0, y=200},
					{x=0, y=0}
				},
				[2] = { -- Line
					{x=100, y=0},
					{x=200, y=200},
					{x=0, y=200},
					{x=100, y=0}
				}
			}
		},
		[2] = {
			name = "",
			lines = {
				[1] = { -- Line
					{x=0, y=0},
					{x=200, y=0},
					{x=200, y=200},
					{x=0, y=200},
					{x=0, y=0}
				},
				[2] = { -- Line
					{x=100, y=0},
					{x=200, y=200},
					{x=0, y=200},
					{x=100, y=0}
				}
			}
		}
	}
	
	local angle, angle_total, large, large_total, a, b
	
	for i, han in ipairs(enum.han) do
		for j, line in ipairs(han.lines) do
			angle = 0
			angle_total = 0
			large = 0
			large_total = 0
			a = line[1]
			b = line[1]
			for i=2, #line do
				a = b
				b = line[i]
				
				angle = math.abs(math.atan2(a.y - b.y, a.x - b.x))
				angle_total = angle_total + math.deg(angle)
				
				large = math.pythag(a.x, a.y, b.x, b.y)
				large_total = large_total + large
			end
			
			line.angle = angle_total
			line.large = large_total
		end
	end
end

enum.lamp = {
	[1] = {
		id = 1,
		x = 0,
		y = 0,
		sprite = "",
		rotation = 0
	}
}