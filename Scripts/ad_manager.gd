extends Node2D

class_name  AdManager
@onready var admob: Admob = $Admob
@onready var interstitial_ad_timer: Timer = $"Interstitial Ad Timer"

var interstitial_ad_loaded : bool = false
var admob_initialized:bool = false
var _can_show_interstitial_ad : bool = false
var rounds_between_ad:int = 3
var rounds_played:int = 0

func _ready() -> void:
	pass
	

func initialize() -> void:
	admob.initialize()
	interstitial_ad_timer.timeout.connect(func(): 
		Logging.logMessage("Can show ad!")
		_can_show_interstitial_ad = true
		)
	interstitial_ad_timer.start()
	
func setup_banner_ad() -> void:
	if admob_initialized:
		Logging.logMessage("Loading banner ad")
		admob.set_banner_position(LoadAdRequest.AdPosition.TOP)
		#admob.set_banner_size(LoadAdRequest.AdSize.BANNER)
		admob.set_banner_size(LoadAdRequest.AdSize.FULL_BANNER)
		admob.load_banner_ad()

func remove_banner_ad() -> void:
	if admob_initialized:
		admob.hide_banner_ad()
		admob.remove_banner_ad()

func _on_admob_initialization_completed(_status_data: InitializationStatus) -> void:
	admob_initialized = true
	setup_banner_ad()
	setup_interstitial_ad()
	#Logging.logMessage("Loading consent form")
	#admob.load_consent_form()
	
func _on_admob_banner_ad_failed_to_load(_ad_id: String, error_data: LoadAdError) -> void:
	Logging.error("Banner ad failed to load! " + error_data.get_response_info())
	

func _on_admob_banner_ad_loaded(ad_id: String) -> void:
	Logging.logMessage("Banner ad loaded! Showing ad")
	admob.show_banner_ad(ad_id)
	
func setup_interstitial_ad() -> void:
	Logging.logMessage("Loading interstitial ad")
	if admob_initialized and !interstitial_ad_loaded:
		admob.load_interstitial_ad()

func _on_admob_interstitial_ad_loaded(_ad_id: String) -> void:
	Logging.logMessage("Interstitial ad loaded!")
	interstitial_ad_loaded = true

## returns false if interstitial ad can't be shown
func show_interstitial_ad() -> bool:
	if rounds_played < rounds_between_ad:
		Logging.logMessage("Too few rounds played to show an interstitial ad!")
		return false

	if not _can_show_interstitial_ad:
		Logging.logMessage("It is too early to show an interstitial ad!")
		return false
	if admob_initialized and interstitial_ad_loaded and admob.is_interstitial_ad_loaded(): #not sure i really need both of these
		Logging.logMessage("Showing interstitial ad!")
		interstitial_ad_loaded = false
		_can_show_interstitial_ad = false
		interstitial_ad_timer.start()
		admob.show_interstitial_ad()
		return true
	else:
		return false
func _on_admob_consent_form_loaded() -> void:
	Logging.logMessage("Consent form loaded! Showing...")
	admob.show_consent_form()


func _on_admob_consent_form_failed_to_load(error_data: FormError) -> void:
	Logging.error("Consent form failed to load! Status Code: " + str(error_data.get_code()) + ". Message: " + error_data.get_message())
	pass # Replace with function body.
