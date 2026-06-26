extends Node

##in single player, player 1 will always be 0 (I hope) (i mean i think ive hardcoded it like that but deviceID is absolutely not always 0...)
var ControllerIds: Array[int] = [0, 1, 2, 3]

var hats_selected : Dictionary[int, String] = {0:"NONE"}
var skins_selected : Dictionary[int, String] = {0:"DEFAULT"}
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
var hats: Dictionary = {
	"NONE": {
		player_hat = null,
		texture = null,
		unlocked = true,
		offset = Vector2(0, 0),
	},
	"SANTA": {
		player_hat = load("uid://ctddhm73vg7xu"),
		texture = load("uid://cxm52e0c581yk"),
		unlocked = false,
		offset = Vector2(1, -17),
	},
	"COWBOY": {
		player_hat = load("uid://bto27x7qmr5d"),
		texture = load("uid://baisbs5c35f4g"),
		unlocked = false,
		offset = Vector2(0, -11),
	},
	"TEST": {
		player_hat = load("uid://b3wm7tpo1omk6"),
		texture = load("uid://dvj0pjlmvqwve"),
		unlocked = true,
		offset = Vector2(-5.0, -6),
	},
	"HELMET": {
		player_hat = load("uid://bcsu113pmwt3r"),
		texture = load("uid://bmdnyc2fq6qg7"),
		unlocked = false,
		offset = Vector2(0.0, -3.5),
	},
	"FISHING": {
		player_hat = load("uid://bctym2dlb5l23"),
		texture = load("uid://bctym2dlb5l23"),
		unlocked = false,
		offset = Vector2(0, -10.5),
		price = 50
	},
	"CAPS_FORWARD": {
		player_hat = load("uid://4jl31gekp3me"),
		texture = load("uid://4jl31gekp3me"),
		unlocked = false,
		offset = Vector2(0, -11),
		price = 100,
	},
	"CAPS_SIDE": {
		player_hat = preload("uid://bxkrsvbjj0p5v"),
		texture = preload("uid://bxkrsvbjj0p5v"),
		unlocked = false,
		offset = Vector2(-3.5, -11),
		price = 100,
	},
	"CROWN": {
		player_hat = load("uid://espi8xvrclq6"),
		texture = load("uid://espi8xvrclq6"),
		unlocked = false,
		offset = Vector2(0, -12.5),
		price = 1000,
	},
}
var skins : Dictionary = {
	"DEFAULT" = preload("uid://b7af0yq15vqtw"),
	"DEFAULT_V_2" = preload("uid://b4aj3wr1celdq"),
	"OUTLINED" = preload("uid://cax0llp5vepyb"),
	"BROWN" = preload("uid://ctck1prc87wmx"),
	"GOLD" = preload("uid://ddnwrn4ojw666"),
	"LABRADOR" = preload("uid://d1r7ugtokkbku"),
	"ORANGE" = preload("uid://cco5f6wqi6oi"),
	"SADDLE_BROWN" = preload("uid://cp00enlx3liny"),
	"BASSET" = preload("uid://dma1wttfl715"),
	#"TINY" = preload("uid://dm3iaacejmpe0"),
	#"DACHS" = preload("uid://bhv5fouypr0i8"),
}
