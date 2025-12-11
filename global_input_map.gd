extends Node

var ControllerIds: Array[int] = [0, 1, 2, 3]
var player_colors : Array[Color] = [Color.WHITE, Color("ffe0ab"), Color.GOLD, Color("e8c5b8"),Color.INDIAN_RED,Color("d9965aff"),Color("a97d59ff"), Color.SADDLE_BROWN, Color.BROWN,Color("ba93a2ff"), Color.VIOLET,Color.AQUA, Color.AQUAMARINE, Color.OLIVE];
var Player_Color_Selected : Dictionary[int, int] = {}
var Player_Hats_Selected : Dictionary[int, int] = {}
var Player_Controls_Selected : Dictionary[int, bool] = {}
var Player_Lives: Dictionary[int,int] = {}
var Player_Score: Dictionary[int,int] = {}
var Player_Placement: Dictionary[int,int] = {}
# Color.BEIGE,  
#  Color("f0c68a"),
#  Color("f0b28bff"),
#  Color("99482eff"),
#  Color("6c5a4fff"),
#  Color("654652ff"),
#  Color("d9965aff"),
