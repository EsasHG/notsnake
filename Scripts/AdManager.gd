extends Node2D

@onready var admob: Admob = $Admob

var admob_initialized:bool = false

func _ready() -> void:
	admob.initialize()

func setup_banner_ad() -> void:
	if admob_initialized:
		admob.set_banner_position(LoadAdRequest.AdPosition.BOTTOM)
		#admob.set_banner_size(LoadAdRequest.AdSize.BANNER)
		admob.set_banner_size(LoadAdRequest.AdSize.FULL_BANNER)
		admob.load_banner_ad()




func _on_admob_initialization_completed(_status_data: InitializationStatus) -> void:
	admob_initialized = true
	setup_banner_ad()
	

func _on_admob_banner_ad_failed_to_load(ad_id: String, error_data: LoadAdError) -> void:
	Logging.error("Banner ad failed to load!")
	

func _on_admob_banner_ad_loaded(ad_id: String) -> void:
	admob.show_banner_ad()
	
