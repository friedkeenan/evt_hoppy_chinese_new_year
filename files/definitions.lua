styles = {}

styles.regular = "<font face='Century Schoolbook,Baskerville,Baskerville Old Face,Hoefler Text,Garamond,Times New Roman,serif'>%s</font>"
styles.chat = "<font color='#FE5148'>%s</font>"
styles.invq = styles.regular:format("<D>%s</D>")
styles.invqd = styles.regular:format("<font color='#3F0000'><b>%s</b></font>")
styles.ititle = styles.invq:format("<font size='28'><p align='center'>%s</p></font>")
styles.drawui = styles.invq:format("<font size='14.5'><p align='center'><a href='event:%s'>%s</a></p></font>")
styles.drawuitip = styles.drawui:format("%s", "<D>%s</D>")
styles.ilist = styles.regular:format("<font color='#FFFFFF' size='20'><b>%s</b></font>")
styles.dialogue = styles.regular:format("<font color='#3F0000' size='15'><b>%s</b></font>")

enum.items = {
	[1] = {
		name = "rope",
		sprite = "185cb482627.png",
		pos = {}
	},
	[2] = {
		name = "wood",
		sprite = "185e397feb5.png",
		pos = {}
	},
	[3] = {
		name = "scissors",
		sprite = "185cb86d5af.png",
		pos = {}
	},
	[4] = {
		name = "glue",
		sprite = "185cbb6a564.png",
		pos = {}
	},
	[5] = {
		name = "paper",
		sprite = "185e397b1b5.png",
		pos = {}
	},
	[6] = {
		name = "paint",
		sprite = "185cb487320.png",
		pos = {}
	},
	[7] = {
		name = "paint_brush",
		sprite = "185d2163227.png",
		pos = {}
	},
	[8] = {
		name = "lamp",
		sprite = "185d0ae4dd6.png",
	},
	[9] = {
		name = "lamp_final",
		sprite = "185e1b6a2b9.png"
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
			name = "兔",
			hype = 1,
			sprite = "185e1af0068.png",
			lines = {
				[1] = { -- Line
					{x=54, y=0},
					{x=38, y=27},
					{x=5, y=56}
				},
				[2] = {
					{x=52, y=27},
					{x=98, y=20},
					{x=70, y=59}
				},
				[3] = {
					{x=18, y=72},
					{x=24, y=120}
				},
				[4] = {
					{x=16, y=71},
					{x=133, y=56},
					{x=129, y=111}
				},
				[5] = {
					{x=23, y=116},
					{x=138, y=102}
				},
				[6] = {
					{x=73, y=73},
					{x=49, y=145},
					{x=0, y=200}
				},
				[7] = {
					{x=92, y=117},
					{x=98, y=176},
					{x=113, y=193},
					{x=141, y=200},
					{x=200, y=174}
				},
				[8] = {
					{x=132, y=139},
					{x=173, y=172},
				}
			}
		},
		[2] = {
			name = "生肖",
			hype = 3,
			sprite = "185e1af4cbd.png",
			lines = {
				[1] = {
					{x=44, y=38},
					{x=0, y=114},
				},
				[2] = {
					{x=43, y=66},
					{x=143, y=48},
				},
				[3] = {
					{x=47, y=119},
					{x=144, y=104},
				},
				[4] = {
					{x=90, y=18},
					{x=92, y=172},
				},
				[5] = {
					{x=23, y=187},
					{x=173, y=162},
				},
				[6] = {
					{x=264, y=0},
					{x=261, y=61},
				},
				[7] = {
					{x=219, y=20},
					{x=240, y=45},
				},
				[8] = {
					{x=320, y=5},
					{x=288, y=38},
				},
				[9] = {
					{x=232, y=69},
					{x=232, y=180},
				},
				[10] = {
					{x=232, y=69},
					{x=305, y=52},
					{x=312, y=188},
				},
				[11] = {
					{x=248, y=106},
					{x=286, y=95},
				},
				[12] = {
					{x=248, y=142},
					{x=286, y=133},
				},
			}
		},
		[3] = {
			name = "鞭炮",
			sprite = "185e1af99be.png",
			hype = 2,
			lines = {
				[1] = {
					{x=18, y=48},
					{x=82, y=33},
				},
				[2] = {
					{x=32, y=22},
					{x=38, y=70},
				},
				[3] = {
					{x=72, y=0},
					{x=60, y=63},
				},
				[4] = {
					{x=38, y=71},
					{x=60, y=65},
				},
				[5] = {
					{x=18, y=98},
					{x=27, y=127},
				},
				[6] = {
					{x=18, y=98},
					{x=71, y=85},
					{x=68, y=110},
				},
				[7] = {
					{x=28, y=120},
					{x=66, y=109},
				},
				[8] = {
					{x=0, y=150},
					{x=78, y=133},
				},
				[9] = {
					{x=46, y=79},
					{x=47, y=200},
				},
				[10] = {
					{x=112, y=13},
					{x=80, y=70},
				},
				[11] = {
					{x=94, y=56},
					{x=96, y=185},
				},
				[12] = {
					{x=134, y=40},
					{x=170, y=27},
				},
				[13] = {
					{x=116, y=72},
					{x=125, y=118},
				},
				[14] = {
					{x=116, y=72},
					{x=182, y=55},
					{x=172, y=110},
				},
				[15] = {
					{x=136, y=89},
					{x=161, y=82},
				},
				[16] = {
					{x=126, y=116},
					{x=170, y=108},
				},
				[17] = {
					{x=146, y=44},
					{x=144, y=134},
					{x=130, y=166},
					{x=112, y=179},
				},
				[18] = {
					{x=109, y=125},
					{x=185, y=176},
				},
				-- 2nd char
				[19] = {
					{x=220, y=80},
					{x=232, y=105},
				},
				[20] = {
					{x=287, y=46},
					{x=260, y=78},
				},
				[21] = {
					{x=258, y=12},
					{x=260, y=78},
					{x=253, y=136},
					{x=211, y=197}
				},
				[22] = {
					{x=260, y=140},
					{x=275, y=164},
				},
				[23] = {
					{x=331, y=10},
					{x=311, y=56},
					{x=293, y=84},
				},
				[24] = {
					{x=317, y=61},
					{x=373, y=47},
					{x=361, y=134}
				},
				[25] = {
					{x=296, y=98},
					{x=331, y=90},
					{x=325, y=123},
				},
				[26] = {
					{x=299, y=131},
					{x=331, y=122},
				},
				[27] = {
					{x=296, y=98},
					{x=301, y=168},
					{x=333, y=190},
					{x=400, y=175},
				},
			}
		},
		[4] = {
			name = "烟花",
			sprite = "185e1afe6bd.png",
			hype = 2,
			lines = {
				[1] = {
					{x=10, y=78},
					{x=22, y=100},
				},
				[2] = {
					{x=72, y=56},
					{x=51, y=79},
				},
				[3] = {
					{x=47, y=18},
					{x=48, y=82},
					{x=42, y=125},
					{x=25, y=170},
					{x=0, y=192},
				},
				[4] = {
					{x=42, y=125},
					{x=69, y=146},
				},
				[5] = {
					{x=90, y=45},
					{x=91, y=179},
				},
				[6] = {
					{x=90, y=45},
					{x=171, y=36},
					{x=172, y=187},
				},
				[7] = {
					{x=111, y=95},
					{x=151, y=85},
				},
				[8] = {
					{x=130, y=62},
					{x=127, y=111},
					{x=104, y=145},
				},
				[9] = {
					{x=136, y=112},
					{x=154, y=129},
				},
				[10] = {
					{x=96, y=170},
					{x=171, y=165},
				},
				-- 2nd char
				[11] = {
					{x=228, y=51},
					{x=372, y=35},
				},
				[12] = {
					{x=269, y=10},
					{x=279, y=67},
				},
				[13] = {
					{x=330, y=0},
					{x=317, y=66},
				},
				[14] = {
					{x=268, y=84},
					{x=244, y=130},
					{x=204, y=169},
				},
				[15] = {
					{x=253, y=132},
					{x=250, y=200},
				},
				[16] = {
					{x=358, y=85},
					{x=322, y=125},
					{x=273, y=153},
				},
				[17] = {
					{x=308, y=80},
					{x=309, y=173},
					{x=326, y=192},
					{x=393, y=183}
				},
			}
		},
		[5] = {
			name = "唐装",
			sprite = "185e1b033bb.png",
			hype = 3,
			lines = {
				[1] = {
					{x=102, y=0},
					{x=120, y=13},
				},
				[2] = {
					{x=59, y=41},
					{x=155, y=25},
				},
				[3] = {
					{x=59, y=41},
					{x=50, y=95},
					{x=28, y=153},
					{x=0, y=187},
				},
				[4] = {
					{x=88, y=73},
					{x=156, y=63},
					{x=146, y=111},
				},
				[5] = {
					{x=64, y=99},
					{x=188, y=83},
				},
				[6] = {
					{x=80, y=123},
					{x=188, y=111},
				},
				[7] = {
					{x=112, y=43},
					{x=112, y=139},
				},
				[8] = {
					{x=74, y=154},
					{x=84, y=197},
				},
				[9] = {
					{x=74, y=154},
					{x=151, y=146},
					{x=144, y=181},
				},
				[10] = {
					{x=82, y=189},
					{x=148, y=181},
				},
				
				-- 2nd char
				[11] = {
					{x=243, y=25},
					{x=260, y=41},
				},
				[12] = {
					{x=232, y=76},
					{x=278, y=58},
				},
				[13] = {
					{x=284, y=4},
					{x=283, y=83},
				},
				[14] = {
					{x=307, y=39},
					{x=383, y=28},
				},
				[15] = {
					{x=336, y=3},
					{x=340, y=64},
				},
				[16] = {
					{x=316, y=67},
					{x=370, y=61},
				},
				[17] = {
					{x=299, y=76},
					{x=314, y=93},
				},
				[18] = {
					{x=250, y=109},
					{x=374, y=92},
				},
				[19] = {
					{x=299, y=108},
					{x=263, y=145},
					{x=215, y=170},
				},
				[20] = {
					{x=286, y=137},
					{x=281, y=200},
					{x=322, y=158},
				},
				[21] = {
					{x=362, y=110},
					{x=334, y=135},
				},
				[22] = {
					{x=298, y=116},
					{x=359, y=160},
					{x=407, y=175},
				}
			}
		},
		[6] = {
			name = "舞狮",
			sprite = "185e1b080c1.png",
			hype = 3,
			lines = {
				[1] = {
					{x=86, y=0},
					{x=60, y=32},
				},
				[2] = {
					{x=92, y=16},
					{x=140, y=11},
				},
				[3] = {
					{x=42, y=62},
					{x=160, y=45},
				},
				[4] = {
					{x=56, y=45},
					{x=63, y=84},
				},
				[5] = {
					{x=80, y=39},
					{x=84, y=83},
				},
				[6] = {
					{x=104, y=35},
					{x=104, y=81},
				},
				[7] = {
					{x=138, y=31},
					{x=128, y=79},
				},
				[8] = {
					{x=0, y=94},
					{x=191, y=79},
				},
				[9] = {
					{x=60, y=102},
					{x=46, y=121},
					{x=28, y=138},
				},
				[10] = {
					{x=60, y=114},
					{x=80, y=109},
					{x=63, y=149},
					{x=16, y=190},
				},
				[11] = {
					{x=42, y=134},
					{x=51, y=151},
				},
				[12] = {
					{x=101, y=119},
					{x=153, y=111},
				},
				[13] = {
					{x=95, y=129},
					{x=92, y=148},
					{x=168, y=140},
				},
				[14] = {
					{x=126, y=91},
					{x=126, y=200},
				},
				-- 2nd char
				[15] = {
					{x=284, y=13},
					{x=262, y=47},
					{x=231, y=75},
				},
				[16] = {
					{x=263, y=23},
					{x=262, y=45},
					{x=271, y=100},
					{x=268, y=132},
					{x=256, y=168},
				},
				[17] = {
					{x=265, y=80},
					{x=220, y=132},
				},
				[18] = {
					{x=294, y=54},
					{x=293, y=100},
				},
				[19] = {
					{x=319, y=23},
					{x=319, y=99},
					{x=306, y=134},
					{x=279, y=160},
				},
				[20] = {
					{x=344, y=41},
					{x=395, y=32},
				},
				[21] = {
					{x=338, y=77},
					{x=339, y=121},
				},
				[22] = {
					{x=338, y=77},
					{x=392, y=67},
					{x=390, y=121},
				},
				[23] = {
					{x=360, y=45},
					{x=361, y=195},
				},
			}
		},
		[7] = {
			name = "春节",
			sprite = "185e1b0cdbb.png",
			hype = 1,
			lines = {
				[1] = {
					{x=61, y=32},
					{x=140, y=18},
				},
				[2] = {
					{x=56, y=59},
					{x=129, y=48},
				},
				[3] = {
					{x=34, y=90},
					{x=151, y=74},
				},
				[4] = {
					{x=89, y=0},
					{x=85, y=55},
					{x=70, y=98},
					{x=33, y=144},
					{x=0, y=164},
				},
				[5] = {
					{x=103, y=82},
					{x=158, y=129},
					{x=189, y=144},
				},
				[6] = {
					{x=70, y=124},
					{x=69, y=196},
				},
				[7] = {
					{x=70, y=124},
					{x=125, y=118},
					{x=126, y=200},
				},
				[8] = {
					{x=76, y=152},
					{x=119, y=146},
				},
				[9] = {
					{x=71, y=183},
					{x=118, y=178},
				},
				-- 2nd char
				[10] = {
					{x=241, y=42},
					{x=400, y=25},
				},
				[11] = {
					{x=287, y=9},
					{x=294, y=57},
				},
				[12] = {
					{x=352, y=0},
					{x=336, y=55},
				},
				[13] = {
					{x=252, y=87},
					{x=373, y=71},
					{x=366, y=158},
					{x=331, y=151},
				},
				[14] = {
					{x=306, y=84},
					{x=307, y=200},
				},
			}
		},
		[8] = {
			name = "灯笼",
			sprite = "185e1b11abb.png",
			hype = 3,
			lines = {
				[1] = {
					{x=12, y=66},
					{x=31, y=90},
				},
				[2] = {
					{x=92, y=37},
					{x=51, y=62},
				},
				[3] = {
					{x=59, y=0},
					{x=56, y=64},
					{x=50, y=118},
					{x=0, y=187},
				},
				[4] = {
					{x=59, y=124},
					{x=87, y=151},
				},
				[5] = {
					{x=102, y=64},
					{x=204, y=48},
				},
				[6] = {
					{x=146, y=56},
					{x=153, y=122},
					{x=147, y=196},
					{x=122, y=200},
				},
				-- 2nd char
				[7] = {
					{x=286, y=9},
					{x=250, y=68},
				},
				[8] = {
					{x=285, y=34},
					{x=323, y=27},
				},
				[9] = {
					{x=283, y=52},
					{x=297, y=60},
				},
				[10] = {
					{x=359, y=0},
					{x=328, y=53},
				},
				[11] = {
					{x=359, y=25},
					{x=400, y=15},
				},
				[12] = {
					{x=357, y=42},
					{x=374, y=54},
				},
				[13] = {
					{x=266, y=109},
					{x=362, y=96},
				},
				[14] = {
					{x=312, y=74},
					{x=298, y=135},
					{x=272, y=173},
					{x=232, y=200},
				},
				[15] = {
					{x=370, y=124},
					{x=339, y=157},
					{x=290, y=180},
				},
				[16] = {
					{x=330, y=112},
					{x=326, y=178},
					{x=346, y=200},
					{x=416, y=192},
				},
				[17] = {
					{x=354, y=73},
					{x=372, y=84},
				}
			}
		},
		[9] = {
			name = "玉兔",
			sprite = "185e1b167bd.png",
			hype = 2,
			lines = {
				[1] = {
					{x=51, y=39},
					{x=127, y=26},
				},
				[2] = {
					{x=47, y=103},
					{x=118, y=89},
				},
				[3] = {
					{x=82, y=32},
					{x=83, y=162},
				},
				[4] = {
					{x=0, y=175},
					{x=174, y=173},
				},
				[5] = {
					{x=131, y=108},
					{x=153, y=133},
				},
				-- 2nd char
				[6] = {
					{x=281, y=0},
					{x=266, y=32},
					{x=241, y=57},
				},
				[7] = {
					{x=278, y=31},
					{x=315, y=23},
					{x=293, y=61},
				},
				[8] = {
					{x=239, y=76},
					{x=252, y=121},
				},
				[9] = {
					{x=239, y=76},
					{x=328, y=67},
					{x=321, y=103},
				},
				[10] = {
					{x=254, y=110},
					{x=323, y=103},
				},
				[11] = {
					{x=286, y=73},
					{x=278, y=128},
					{x=249, y=172},
					{x=212, y=200},
				},
				[12] = {
					{x=300, y=121},
					{x=296, y=171},
					{x=318, y=195},
					{x=378, y=185},
				},
				[13] = {
					{x=322, y=130},
					{x=342, y=151},
				},
			}
		},
		[10] = {
			name = "对联",
			sprite = "185e1b1b4c0.png",
			hype = 3,
			lines = {
				[1] = {
					{x=14, y=54},
					{x=68, y=39},
					{x=62, y=93},
					{x=30, y=149},
					{x=0, y=174},
				},
				[2] = {
					{x=14, y=74},
					{x=78, y=152},
				},
				[3] = {
					{x=90, y=78},
					{x=186, y=61},
				},
				[4] = {
					{x=142, y=0},
					{x=147, y=185},
					{x=112, y=189},
				},
				[5] = {
					{x=91, y=101},
					{x=112, y=123},
				},
				
				-- 2nd char
				[6] = {
					{x=232, y=32},
					{x=304, y=19},
				},
				[7] = {
					{x=247, y=40},
					{x=247, y=137},
				},
				[8] = {
					{x=283, y=30},
					{x=238, y=200},
				},
				[9] = {
					{x=249, y=67},
					{x=270, y=62},
				},
				[10] = {
					{x=252, y=98},
					{x=272, y=92},
				},
				[11] = {
					{x=223, y=147},
					{x=297, y=118},
				},
				[12] = {
					{x=325, y=18},
					{x=337, y=35},
				},
				[13] = {
					{x=385, y=3},
					{x=359, y=42},
				},
				[14] = {
					{x=317, y=69},
					{x=382, y=55},
				},
				[15] = {
					{x=312, y=111},
					{x=400, y=98},
				},
				[16] = {
					{x=344, y=76},
					{x=341, y=122},
					{x=327, y=156},
					{x=294, y=177},
				},
				[17] = {
					{x=347, y=115},
					{x=377, y=162},
					{x=403, y=175},
				},
			}
		},
		[11] = {
			name = "福",
			sprite = "185e1b2dd0a.png",
			hype = 3,
			lines = {
				[1] = {
					{x=60, y=0},
					{x=90, y=20},
				},
				[2] = {
					{x=8, y=75},
					{x=83, y=56},
					{x=51, y=144},
					{x=0, y=161},
				},
				[3] = {
					{x=70, y=111},
					{x=65, y=200},
				},
				[4] = {
					{x=71, y=104},
					{x=98, y=122},
				},
				[5] = {
					{x=147, y=18},
					{x=216, y=5},
				},
				[6] = {
					{x=139, y=52},
					{x=148, y=87},
				},
				[7] = {
					{x=139, y=52},
					{x=207, y=42},
					{x=205, y=73},
				},
				[8] = {
					{x=148, y=81},
					{x=206, y=74},
				},
				[9] = {
					{x=121, y=116},
					{x=131, y=195},
				},
				[10] = {
					{x=121, y=116},
					{x=242, y=101},
					{x=234, y=195},
				},
				[11] = {
					{x=150, y=145},
					{x=209, y=138},
				},
				[12] = {
					{x=175, y=116},
					{x=174, y=172},
				},
				[13] = {
					{x=133, y=184},
					{x=214, y=180},
				},
			}
		},
		[12] = {
			name = "桔子",
			sprite = "185e1b329cb.png",
			hype = 1,
			lines = {
				[1] = {
					{x=10, y=76},
					{x=78, y=58},
				},
				[2] = {
					{x=54, y=0},
					{x=55, y=200},
				},
				[3] = {
					{x=53, y=75},
					{x=27, y=129},
					{x=0, y=156},
				},
				[4] = {
					{x=61, y=100},
					{x=81, y=117},
				},
				[5] = {
					{x=91, y=70},
					{x=189, y=52},
				},
				[6] = {
					{x=140, y=0},
					{x=140, y=101},
				},
				[7] = {
					{x=99, y=114},
					{x=174, y=104},
				},
				[8] = {
					{x=101, y=142},
					{x=111, y=189},
				},
				[9] = {
					{x=101, y=142},
					{x=169, y=133},
					{x=167, y=174},
				},
				[10] = {
					{x=111, y=181},
					{x=163, y=175},
				},
				-- 2nd char
				[11] = {
					{x=274, y=17},
					{x=358, y=0},
					{x=318, y=50},
				},
				[12] = {
					{x=310, y=53},
					{x=326, y=120},
					{x=314, y=191},
					{x=276, y=179},
				},
				[13] = {
					{x=227, y=91},
					{x=339, y=68},
				},
			}
		},
		[13] = {
			name = "饺子",
			sprite = "185e1b376c4.png",
			hype = 1,
			lines = {
				[1] = {
					{x=44, y=11},
					{x=28, y=59},
					{x=0, y=106},
				},
				[2] = {
					{x=29, y=61},
					{x=75, y=53},
					{x=63, y=85},
				},
				[3] = {
					{x=42, y=93},
					{x=31, y=189},
					{x=69, y=149},
				},
				[4] = {
					{x=127, y=0},
					{x=147, y=15},
				},
				[5] = {
					{x=106, y=57},
					{x=170, y=40},
				},
				[6] = {
					{x=115, y=81},
					{x=86, y=116},
				},
				[7] = {
					{x=147, y=71},
					{x=171, y=86},
				},
				[8] = {
					{x=147, y=108},
					{x=135, y=152},
					{x=107, y=185},
					{x=78, y=200},
				},
				[9] = {
					{x=103, y=126},
					{x=152, y=178},
					{x=193, y=200},
				},
				-- 2nd char
				[10] = {
					{x=274, y=17},
					{x=358, y=0},
					{x=318, y=50},
				},
				[11] = {
					{x=310, y=53},
					{x=326, y=120},
					{x=314, y=191},
					{x=276, y=179},
				},
				[12] = {
					{x=227, y=91},
					{x=339, y=68},
				},
			}
		},
		[14] = {
			name = "元宝",
			sprite = "185e1b3c3c1.png",
			hype = 2,
			lines = {
				[1] = {
					{x=57, y=20},
					{x=117, y=9},
				},
				[2] = {
					{x=20, y=83},
					{x=138, y=57},
				},
				[3] = {
					{x=66, y=87},
					{x=52, y=120},
					{x=30, y=154},
					{x=0, y=184},
				},
				[4] = {
					{x=90, y=80},
					{x=88, y=168},
					{x=113, y=188},
					{x=175, y=178},
				},
				-- 2nd char
				[5] = {
					{x=290, y=0},
					{x=308, y=24},
				},
				[6] = {
					{x=242, y=32},
					{x=234, y=81},
				},
				[7] = {
					{x=252, y=49},
					{x=364, y=28},
					{x=352, y=62},
				},
				[8] = {
					{x=261, y=93},
					{x=333, y=81},
				},
				[9] = {
					{x=261, y=142},
					{x=330, y=130},
				},
				[10] = {
					{x=294, y=92},
					{x=296, y=195},
				},
				[11] = {
					{x=225, y=200},
					{x=375, y=189},
				},
				[12] = {
					{x=339, y=142},
					{x=362, y=170},
				},
			}
		},
		[15] = {
			name = "拜年",
			sprite = "185e1b410cb.png",
			hype = 3,
			lines = {
				[1] = {
					{x=71, y=8},
					{x=30, y=33},
				},
				[2] = {
					{x=30, y=70},
					{x=69, y=60},
				},
				[3] = {
					{x=0, y=111},
					{x=81, y=89},
				},
				[4] = {
					{x=47, y=53},
					{x=46, y=105},
					{x=32, y=151},
					{x=7, y=184},
				},
				[5] = {
					{x=106, y=22},
					{x=160, y=12},
				},
				[6] = {
					{x=104, y=54},
					{x=150, y=46},
				},
				[7] = {
					{x=103, y=83},
					{x=150, y=72},
				},
				[8] = {
					{x=70, y=119},
					{x=179, y=103},
				},
				[9] = {
					{x=126, y=19},
					{x=126, y=191},
				},
				-- 2nd char
				[10] = {
					{x=292, y=0},
					{x=274, y=33},
					{x=249, y=63},
				},
				[11] = {
					{x=286, y=32},
					{x=353, y=18},
				},
				[12] = {
					{x=274, y=74},
					{x=354, y=60},
				},
				[13] = {
					{x=274, y=74},
					{x=273, y=110},
				},
				[14] = {
					{x=219, y=121},
					{x=389, y=101},
				},
				[15] = {
					{x=317, y=40},
					{x=317, y=200},
				},
			}
		},
		[16] = {
			name = "除夕",
			sprite = "185e1b45dce.png",
			hype = 1,
			lines = {
				[1] = {
					{x=5 , y=40},
					{x=50, y=28},
					{x=37, y=66},
					{x=46, y=99},
					{x=26, y=96},
				},
				[2] = {
					{x=5, y=40},
					{x=9, y=105},
					{x=0, y=181},
				},
				[3] = {
					{x=114, y=0},
					{x=102, y=37},
					{x=88, y=66},
					{x=63, y=94},
				},
				[4] = {
					{x=112, y=19},
					{x=156, y=62},
					{x=190, y=76},
				},
				[5] = {
					{x=93, y=91},
					{x=140, y=82},
				},
				[6] = {
					{x=70, y=125},
					{x=163, y=114},
				},
				[7] = {
					{x=114, y=94},
					{x=118, y=145},
					{x=115, y=188},
					{x=90, y=184},
				},
				[8] = {
					{x=71, y=151},
					{x=58, y=178},
				},
				[9] = {
					{x=145, y=144},
					{x=176, y=173},
				},
				
				-- 2nd char
				[10] = {
					{x=334, y=5},
					{x=301, y=59},
					{x=252, y=104},
				},
				[11] = {
					{x=317, y=59},
					{x=375, y=49},
					{x=352, y=111},
					{x=313, y=160},
					{x=244, y=200},
				},
				[12] = {
					{x=289, y=85},
					{x=320, y=116},
				},
			}
		},
		[17] = {
			name = "祭祖",
			sprite = "185e1b4aabb.png",
			hype = 3,
			lines = {
				[1] = {
					{x=59, y=5},
					{x=42, y=35},
					{x=18, y=61},
				},
				[2] = {
					{x=57, y=25},
					{x=84, y=19},
					{x=68, y=56},
					{x=39, y=100},
					{x=0, y=135},
				},
				[3] = {
					{x=40, y=55},
					{x=54, y=70},
				},
				[4] = {
					{x=22, y=76},
					{x=38, y=94},
				},
				[5] = {
					{x=108, y=20},
					{x=151, y=10},
					{x=127, y=52},
				},
				[6] = {
					{x=97, y=30},
					{x=145, y=83},
					{x=193, y=108},
				},
				[7] = {
					{x=69, y=91},
					{x=115, y=82},
				},
				[8] = {
					{x=44, y=129},
					{x=139, y=112},
				},
				[9] = {
					{x=93, y=126},
					{x=96, y=162},
					{x=92, y=191},
					{x=68, y=188},
				},
				[10] = {
					{x=50, y=154},
					{x=34, y=189},
				},
				[11] = {
					{x=121, y=149},
					{x=154, y=174},
				},
				
				-- 2nd char
				[12] = {
					{x=274, y=0},
					{x=297, y=21},
				},
				[13] = {
					{x=222, y=75},
					{x=287, y=57},
					{x=261, y=109},
					{x=219, y=160},
				},
				[14] = {
					{x=274, y=95},
					{x=273, y=200},
				},
				[15] = {
					{x=277, y=105},
					{x=304, y=119},
				},
				[16] = {
					{x=331, y=39},
					{x=333, y=161},
				},
				[17] = {
					{x=331, y=39},
					{x=384, y=32},
					{x=385, y=54},
				},
				[18] = {
					{x=332, y=79},
					{x=362, y=74},
				},
				[19] = {
					{x=332, y=117},
					{x=362, y=113},
				},
				[20] = {
					{x=295, y=170},
					{x=423, y=155},
				},
			}
		},
		[18] = {
			name = "剪纸",
			sprite = "185e1b4f7bc.png",
			hype = 2,
			lines = {
				[1] = {
					{x=54, y=3},
					{x=73, y=19},
				},
				[2] = {
					{x=126, y=0},
					{x=107, y=25},
				},
				[3] = {
					{x=0, y=39},
					{x=191, y=25},
				},
				[4] = {
					{x=37, y=59},
					{x=36, y=117},
				},
				[5] = {
					{x=37, y=59},
					{x=82, y=53},
					{x=78, y=112},
				},
				[6] = {
					{x=37, y=78},
					{x=64, y=75},
				},
				[7] = {
					{x=37, y=95},
					{x=64, y=92},
				},
				[8] = {
					{x=110, y=59},
					{x=110, y=99},
				},
				[9] = {
					{x=144, y=49},
					{x=145, y=105},
					{x=129, y=104},
				},
				[10] = {
					{x=28, y=140},
					{x=139, y=129},
					{x=126, y=193},
					{x=96, y=91},
				},
				[11] = {
					{x=82, y=142},
					{x=53, y=176},
					{x=10, y=200},
				},
				-- 2nd char
				[12] = {
					{x=278, y=21},
					{x=235, y=90},
					{x=270, y=81},
				},
				[13] = {
					{x=300, y=59},
					{x=247, y=128},
					{x=296, y=111},
				},
				[14] = {
					{x=234, y=173},
					{x=303, y=141},
				},
				[15] = {
					{x=378, y=25},
					{x=332, y=53},
				},
				[16] = {
					{x=320, y=57},
					{x=320, y=176},
					{x=361, y=143},
				},
				[17] = {
					{x=337, y=101},
					{x=403, y=81},
				},
				[18] = {
					{x=354, y=51},
					{x=366, y=98},
					{x=386, y=140},
					{x=432, y=180},
					{x=432, y=149},
				},
			}
		},
		[19] = {
			name = "年",
			sprite = "185e1b544c0.png",
			hype = 1,
			lines = {
				[1] = {
					{x=85, y=0},
					{x=66, y=32},
					{x=34, y=63},
				},
				[2] = {
					{x=75, y=35},
					{x=150, y=19},
				},
				[3] = {
					{x=61, y=76},
					{x=156, y=62},
				},
				[4] = {
					{x=61, y=76},
					{x=64, y=114},
				},
				[5] = {
					{x=0, y=125},
					{x=194, y=101},
				},
				[6] = {
					{x=111, y=38},
					{x=110, y=200},
				},
			}
		},
		[20] = {
			name = "火锅",
			sprite = "185e1b591bf.png",
			hype = 2,
			lines = {
				[1] = {
					{x=25, y=67},
					{x=51, y=98},
				},
				[2] = {
					{x=152, y=51},
					{x=103, y=93},
				},
				[3] = {
					{x=77, y=6},
					{x=75, y=100},
					{x=64, y=141},
					{x=37, y=181},
					{x=0, y=200},
				},
				[4] = {
					{x=75, y=101},
					{x=131, y=174},
					{x=186, y=198},
				},
				
				-- 2nd char
				[5] = {
					{x=284, y=0},
					{x=266, y=43},
					{x=245, y=78},
					{x=217, y=113},
				},
				[6] = {
					{x=265, y=45},
					{x=311, y=38},
				},
				[7] = {
					{x=257, y=78},
					{x=300, y=69},
				},
				[8] = {
					{x=242, y=114},
					{x=300, y=101},
				},
				[9] = {
					{x=272, y=72},
					{x=267, y=183},
					{x=299, y=147},
				},
				[10] = {
					{x=329, y=29},
					{x=337, y=78},
				},
				[11] = {
					{x=329, y=29},
					{x=391, y=15},
					{x=387, y=60},
				},
				[12] = {
					{x=340, y=71},
					{x=391, y=59},
				},
				[13] = {
					{x=314, y=113},
					{x=315, y=187},
				},
				[14] = {
					{x=314, y=113},
					{x=417, y=99},
					{x=415, y=195},
					{x=388, y=183},
				},
				[15] = {
					{x=362, y=77},
					{x=359, y=110},
					{x=349, y=141},
					{x=328, y=167},
				},
				[16] = {
					{x=358, y=124},
					{x=390, y=148},
				},
			}
		},
		[21] = {
			name = "龙",
			sprite = "185e1b60993.png",
			hype = 1,
			lines = {
				[1] = {
					{x=35, y=71},
					{x=153, y=48},
				},
				[2] = {
					{x=92, y=0},
					{x=77, y=78},
					{x=52, y=147},
					{x=0, y=200},
				},
				[3] = {
					{x=163, y=84},
					{x=125, y=140},
					{x=66, y=187},
				},
				[4] = {
					{x=108, y=63},
					{x=105, y=169},
					{x=122, y=200},
					{x=212, y=187},
					{x=217, y=157},
				},
				[5] = {
					{x=140, y=1},
					{x=169, y=18},
				},
			}
		},
		[22] = {
			name = "元宵节",
			sprite = "185e1b655ba.png",
			hype = 1,
			lines = {
				[1] = {
					{x=53, y=31},
					{x=111, y=21},
				},
				[2] = {
					{x=18, y=85},
					{x=131, y=64},
				},
				[3] = {
					{x=62, y=80},
					{x=41, y=132},
					{x=0, y=174},
				},
				[4] = {
					{x=86, y=76},
					{x=82, y=155},
					{x=101, y=176},
					{x=163, y=169},
					{x=163, y=141},
				},
				
				-- 2nd char
				[5] = {
					{x=248, y=0},
					{x=260, y=17},
				},
				[6] = {
					{x=200, y=37},
					{x=193, y=174},
				},
				[7] = {
					{x=200, y=37},
					{x=327, y=20},
					{x=317, y=50},
				},
				[8] = {
					{x=253, y=52},
					{x=253, y=92},
				},
				[9] = {
					{x=210, y=64},
					{x=228, y=82},
				},
				[10] = {
					{x=296, y=53},
					{x=270, y=77},
				},
				[11] = {
					{x=227, y=99},
					{x=226, y=189},
				},
				[12] = {
					{x=227, y=99},
					{x=286, y=90},
					{x=290, y=190},
					{x=265, y=184},
				},
				[13] = {
					{x=229, y=122},
					{x=264, y=118},
				},
				[14] = {
					{x=229, y=148},
					{x=264, y=142},
				},
				
				-- 3rd char *-*
				[15] = {
					{x=363, y=42},
					{x=510, y=28},
				},
				[16] = {
					{x=409, y=13},
					{x=414, y=59},
				},
				[17] = {
					{x=466, y=2},
					{x=453, y=57},
				},
				[18] = {
					{x=378, y=89},
					{x=484, y=73},
					{x=480, y=154},
					{x=450, y=148},
				},
				[19] = {
					{x=426, y=84},
					{x=426, y=200},
				}
			}
		},
		[23] = {
			name = "季节",
			sprite = "185e1b6a2b9.png",
			hype = 3,
			lines = {
				[1] = {
					{x=129, y=0},
					{x=53, y=22},
				},
				[2] = {
					{x=22, y=52},
					{x=161, y=35},
				},
				[3] = {
					{x=95, y=16},
					{x=95, y=87},
				},
				[4] = {
					{x=89, y=47},
					{x=62, y=74},
					{x=27, y=96},
				},
				[5] = {
					{x=101, y=47},
					{x=137, y=74},
					{x=177, y=83},
				},
				[6] = {
					{x=56, y=104},
					{x=129, y=94},
					{x=104, y=123},
				},
				[7] = {
					{x=84, y=118},
					{x=109, y=137},
					{x=104, y=194},
					{x=67, y=187},
				},
				[8] = {
					{x=0, y=145},
					{x=200, y=125},
				},
				-- 2nd char
				[9] = {
					{x=241, y=42},
					{x=400, y=25},
				},
				[10] = {
					{x=287, y=9},
					{x=294, y=57},
				},
				[11] = {
					{x=352, y=0},
					{x=336, y=55},
				},
				[12] = {
					{x=252, y=87},
					{x=373, y=71},
					{x=366, y=158},
					{x=331, y=151},
				},
				[13] = {
					{x=306, y=84},
					{x=307, y=200},
				},
			}
		},
		[24] = {
			name = "节日",
			sprite = "185e1b6efbf.png",
			hype = 1,
			lines = {
				[1] = {
					{x=0, y=40},
					{x=158, y=22},
				},
				[2] = {
					{x=46, y=6},
					{x=52, y=58},
				},
				[3] = {
					{x=110, y=0},
					{x=94, y=53},
				},
				[4] = {
					{x=10, y=86},
					{x=132, y=68},
					{x=124, y=154},
					{x=90, y=147},
				},
				[5] = {
					{x=65, y=82},
					{x=65, y=200},
				},
				-- 2nd char
				[6] = {
					{x=233, y=21},
					{x=233, y=178},
				},
				[7] = {
					{x=233, y=21},
					{x=336, y=7},
					{x=334, y=194},
				},
				[8] = {
					{x=241, y=89},
					{x=330, y=77},
				},
				[9] = {
					{x=240, y=160},
					{x=326, y=150},
				},
			}
		}, --]]
	}
	
	local angle, angle_total, large, large_total, a, b
	
	for i, han in ipairs(enum.han) do
		local xmax = 0
		for j, line in ipairs(han.lines) do
			angle = 0
			angle_total = 0
			large = 0
			large_total = 0
		
			a = line[1]
			b = line[1]
			for i=1, #line do
				xmax = math.max(line[i].x, xmax)
				if i > 1 then
					a = b
					b = line[i]
					
					angle = math.udist(angle, math.abs(math.atan2(a.y - b.y, a.x - b.x)))
					angle_total = angle_total + math.deg(angle)
					
					large = math.pythag(a.x, a.y, b.x, b.y)
					large_total = large_total + large
				end
			end
			
			line.angle = angle_total
			line.large = large_total
		end
		
		han.width = xmax
	end
end

HanPreview = {}

function HanPreview:hide(playerName)
	if not self[playerName] then return end
	for i = 1, #self[playerName] do
		tfm.exec.removeImage(self[playerName][i], false)
	end
	
	for i=1, 50 do
		ui.removeTextArea(15000 + i, playerName)
	end
	
	self[playerName] = nil
end

function HanPreview:show(playerName, hanId, xc, yc, lines)
	if self[playerName] then self:hide(playerName) end
	local han = enum.han[hanId]
	if not han then return end
	xc = (xc or 400) - (han.width or 200) / 2
	yc = (yc or 200) - 100
	
	self[playerName] = {}
	
	
	if not lines then
		lines = {}
		for i=1, #han.lines do
			lines[i] = i
		end
	end
	
	local tc = 0
	local x, y
	local line, previous
	local id1, id2, sx, an
	for _, lineId in next, lines do
		line = han.lines[lineId]
		
		if line then
			for pointId, point in ipairs(line) do
				tc = tc + 1
				x = xc + point.x
				y = yc + point.y
				
				id1 = tfm.exec.addImage(
					"185cd3b62c5.png", "!2000", 
					x, y,
					playerName,
					0.25, 0.25,
					0, 0.5,
					0.5, 0.5,
					false
				)
				
				ui.addTextArea(
					15000 + tc, 
					styles.regular:format(("<font color='#FFFFFF'>%d</font>"):format(pointId)),
					playerName,
					x+5, y+5,
					0, 0,
					0x0, 0x0,
					1.0, false
				)
				table.insert(self[playerName], id1)
				if pointId >= 2 then
					previous = line[pointId - 1]
					
					sx = math.pythag(point.x, point.y, previous.x, previous.y) / 40
					an = math.atan2(previous.y - point.y, previous.x - point.x)
					
					id2 = tfm.exec.addImage(
						"185cd3b163f.png", "!100",
						x, y,
						playerName,
						sx, 0.25,
						an, 0.5,
						0.0, 0.5,
						false
					)
					
					table.insert(self[playerName], id2)
				end
			end
		end
	end
end

enum.lamp = {}

do
	local ic = {}
	local c
	local lc = 0
	for item_anchor in xml:gmatch("<O (.-)/>") do
		c = item_anchor:match('C="(%d+)"')
		if c == "14" then -- BLue
			table.insert(enum.items[tonumber(item_anchor:match('I="(%d+)"'))].pos, {
				x = tonumber(item_anchor:match('X="(%d+)"')),
				y = tonumber(item_anchor:match('Y="(%d+)"'))
			})
		elseif c == "22" then -- Yellow
			lc = lc + 1
			enum.lamp[lc] = {
				id = lc,
				sprite = enum.han[lc] and enum.han[lc].sprite,
				x = tonumber(item_anchor:match('X="(%d+)"')),
				y = tonumber(item_anchor:match('Y="(%d+)"')),
				foreground = tonumber(item_anchor:match('f="(%d)"')) == 1
			}
		end
	end
end