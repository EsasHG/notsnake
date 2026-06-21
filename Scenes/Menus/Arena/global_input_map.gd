extends Node

##in single player, player 1 will always be 0 (I hope) (i mean i think ive hardcoded it like that but deviceID is absolutely not always 0...)
var ControllerIds: Array[int] = [0, 1, 2, 3]
var player_colors : Array[Color] = [Color.WHITE, 
	Color("ffe0ab"), 
	Color.GOLD,
	Color("e8c5b8"),
	Color.INDIAN_RED,
	Color("d9965aff"),
	Color("a97d59ff"), 
	Color.SADDLE_BROWN, 
	Color.BROWN,
	Color("ba93a2ff"), 
	Color.VIOLET,
	Color.AQUA, 
	Color.AQUAMARINE, 
	Color.OLIVE];
var player_skins : Dictionary = {
	"BROWN" = preload("uid://ctck1prc87wmx"),
	"DACHS" = preload("uid://bhv5fouypr0i8"),
	"DEFAULT" = preload("uid://b7af0yq15vqtw"),
	"DEFAULT_V_2" = preload("uid://b4aj3wr1celdq"),
	"GOLD" = preload("uid://ddnwrn4ojw666"),
	"LABRADOR" = preload("uid://d1r7ugtokkbku"),
	"ORANGE" = preload("uid://cco5f6wqi6oi"),
	"SADDLE_BROWN" = preload("uid://cp00enlx3liny"),
	"TINY" = preload("uid://dm3iaacejmpe0"),
	#"DEFAULT": {
		#color = Color.WHITE,
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = true,
	#},
	#"LAB": {
		#color = Color("ffe0ab"),
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = true,
	#},
	#"GOLD": {
		#color = Color.WHITE,
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"OFF_YELLOW": {
		#color = Color("e8c5b8"),
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"INDIAN_RED": {
		#color = Color.INDIAN_RED,
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"ORANGE": {
		#color = Color("d9965aff"),
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"OFF_BROWN": {
		#color = Color("a97d59ff"), 
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"SADDLE_BROWN": {
		#color = Color.SADDLE_BROWN, 
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"BROWN": {
		#color = Color.BROWN,
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"PURPLE": {
		#color = Color("ba93a2ff"), 
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"VIOLET": {
		#color = Color.VIOLET,
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"AQUA": {
		#color = Color.AQUA, 
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},	
	#"AQUAMARINE": {
		#color = Color.AQUAMARINE, 
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
	#"OLIVE": {
		#color =Color.OLIVE,
		#skin = preload("uid://b7af0yq15vqtw"),
		#unlocked = false,
	#},
}
var Player_Color_Selected : Dictionary[int, int] = {}

var Player_Hats_Selected : Dictionary[int, String] = {0:"NONE"}
var Player_Skins_Selected : Dictionary[int, String] = {0:"DEFAULT"}
var Player_Controls_Selected : Dictionary[int, bool] = {0:true}
var Player_Lives: Dictionary[int,int] = {}
var Player_Score: Dictionary[int,int] = {}
var Player_Placement: Dictionary[int,int] = {}
var Maps: Dictionary = {
	"FIELD": {
		unlocked = true,
		scene = load("uid://bmtfcin4sha1p"),
		icon = load("uid://doqp1jkdlm1dk"),
		high_score = 0,
	},
	"PARK": {
		unlocked = false,
		scene = load("uid://tcsre6epm8ss"),
		icon = load("uid://csxqseoegqggj"),
		high_score = 0,
	},	
	"WINTER": {
		unlocked = false,
		scene = load("uid://c614biqieqsc1"),
		icon = load("uid://cacud1mwfip70"),
		high_score = 0,
	},
	"SQUARE": {
		unlocked = false,
		scene = load("uid://d0lv3j2ywaltm"),
		icon = load("uid://slufqb1sxm5c"),
		high_score = 0,
	},
	"SMALL": {
		unlocked = false,
		scene = load("uid://dw8vjc4lovnfv"),
		icon = load("uid://8hode20lka2d"),
		high_score = 0,
	},
	"FOREST": {
		unlocked = false,
		scene = load("uid://dxkydv08bbemt"),
		icon = load("uid://bhh584wkrqnpi"),
		high_score = 0,
	},
}
var Player_Hats: Dictionary = {
	"NONE": {
		player_hat = null,
		icon_hat = null,
		unlocked = true,
	},
	"SANTA": {
		player_hat = load("uid://ctddhm73vg7xu"),
		icon_hat = load("uid://cxm52e0c581yk"),
		unlocked = false,
	},
	"COWBOY": {
		player_hat = load("uid://bto27x7qmr5d"),
		icon_hat = load("uid://baisbs5c35f4g"),
		unlocked = false,
	},
	"TEST": {
		player_hat = load("uid://b3wm7tpo1omk6"),
		icon_hat = load("uid://dvj0pjlmvqwve"),
		unlocked = true,
	},
	"HELMET": {
		player_hat = load("uid://bcsu113pmwt3r"),
		icon_hat = load("uid://bmdnyc2fq6qg7"),
		unlocked = false,
	},
}

#func _ready() -> void:
	#_load_skins()
	#
#func _load_skins() -> void:
	#Logging.logMessage("Loading skins...")
	#var path = "res://Assets/Dogs/Skins/"
	#player_skins.clear()
	#for file in DirAccess.get_files_at(path):
		#if file.get_extension() == "tres":
			#Logging.logMessage(file)
			#player_skins[file.split(".",false)[0].to_upper()] = ResourceLoader.load(path+file, "DogSkin")
#
	#
# Color.BEIGE,  
#  Color("f0c68a"),
#  Color("f0b28bff"),
#  Color("99482eff"),
#  Color("6c5a4fff"),
#  Color("654652ff"),
#  Color("d9965aff"),
