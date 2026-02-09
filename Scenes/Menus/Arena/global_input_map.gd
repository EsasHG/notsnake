extends Node

##in single player, player 1 will always be 0 (I hope) (i mean i thing ive hardcoded it like that but deviceID is deffo not always 0 lmaooo)
var ControllerIds: Array[int] = [0, 1, 2, 3]
var player_colors : Array[Color] = [Color.WHITE, Color("ffe0ab"), Color.GOLD, Color("e8c5b8"),Color.INDIAN_RED,Color("d9965aff"),Color("a97d59ff"), Color.SADDLE_BROWN, Color.BROWN,Color("ba93a2ff"), Color.VIOLET,Color.AQUA, Color.AQUAMARINE, Color.OLIVE];
var Player_Color_Selected : Dictionary[int, int] = {}
var Player_Hats_Selected : Dictionary[int, String] = {0:"NONE"}
var Player_Controls_Selected : Dictionary[int, bool] = {0:true}
var Player_Lives: Dictionary[int,int] = {}
var Player_Score: Dictionary[int,int] = {}
var Player_Placement: Dictionary[int,int] = {}
var Maps: Dictionary = {
	"FIELD": {
		unlocked = true,
	},
	"PARK": {
		unlocked = false,
	},	
	"WINTER": {
		unlocked = false,
	},
	"SQUARE": {
		unlocked = false,
	},
	"SMALL": {
		unlocked = false,
	},
	"FOREST": {
		unlocked = false,
	},
}
var Player_Hats: Dictionary = {
	"NONE": {
		player_hat = null,
		icon_hat = null,
		unlocked = true,
	},
	"SANTA": {
		player_hat = preload("uid://ctddhm73vg7xu"),
		icon_hat = preload("uid://cxm52e0c581yk"),
		unlocked = false,
	},
	"COWBOY": {
		player_hat = preload("uid://bto27x7qmr5d"),
		icon_hat = preload("uid://baisbs5c35f4g"),
		unlocked = false,
	},
	"TEST": {
		player_hat = preload("uid://b3wm7tpo1omk6"),
		icon_hat = preload("uid://dvj0pjlmvqwve"),
		unlocked = true,
	},
	"HELMET": {
		player_hat = preload("uid://bcsu113pmwt3r"),
		icon_hat = preload("uid://bmdnyc2fq6qg7"),
		unlocked = false,
	},
}
# Color.BEIGE,  
#  Color("f0c68a"),
#  Color("f0b28bff"),
#  Color("99482eff"),
#  Color("6c5a4fff"),
#  Color("654652ff"),
#  Color("d9965aff"),
