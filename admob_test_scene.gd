extends Node2D

@onready var admob: Admob = $Admob
var admob_initialized:bool = false
var i:int = 0
var amount : float = 0 :
	set(value):
		amount = value
		%amount.text = str(value)	

func _ready() -> void:
	admob.initialize()

func _on_banner_pressed() -> void:
	if admob_initialized:
		match i %8:
			0:
				admob.set_banner_position(LoadAdRequest.AdPosition.BOTTOM)
			1:
				admob.set_banner_position(LoadAdRequest.AdPosition.BOTTOM_RIGHT)
			2:
				admob.set_banner_position(LoadAdRequest.AdPosition.RIGHT)
			3:
				admob.set_banner_position(LoadAdRequest.AdPosition.TOP_RIGHT)
			4:
				admob.set_banner_position(LoadAdRequest.AdPosition.TOP)
			5:
				admob.set_banner_position(LoadAdRequest.AdPosition.TOP_LEFT)
			6:
				admob.set_banner_position(LoadAdRequest.AdPosition.LEFT)
			7:
				admob.set_banner_position(LoadAdRequest.AdPosition.BOTTOM_LEFT)
				
		match i % 7:
			0:
				admob.set_banner_size(LoadAdRequest.AdSize.BANNER)
			1:
				admob.set_banner_size(LoadAdRequest.AdSize.LARGE_BANNER)
			2:
				admob.set_banner_size(LoadAdRequest.AdSize.MEDIUM_RECTANGLE)
			3:
				admob.set_banner_size(LoadAdRequest.AdSize.FULL_BANNER)
			4:
				admob.set_banner_size(LoadAdRequest.AdSize.LEADERBOARD)
			5:
				admob.set_banner_size(LoadAdRequest.AdSize.SKYSCRAPER)
			6:
				admob.set_banner_size(LoadAdRequest.AdSize.FLUID)
				
		print_debug("i: " + str(i))
		i+=1
		
		admob.load_banner_ad()
		await admob.banner_ad_loaded
		admob.show_banner_ad()


func _on_interstitial_pressed() -> void:
	if admob_initialized:
		admob.load_interstitial_ad()
		await admob.interstitial_ad_loaded
		admob.show_interstitial_ad()

func _on_rewards_pressed() -> void:
	if admob_initialized:
		admob.load_rewarded_ad()
		await admob.rewarded_ad_loaded
		admob.show_rewarded_ad()


func _on_admob_initialization_completed(status_data: InitializationStatus) -> void:
	admob_initialized = true


func _on_admob_rewarded_ad_user_earned_reward(ad_id: String, reward_data: RewardItem) -> void:
	amount += 200
