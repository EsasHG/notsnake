extends Control
class_name  AdManager

signal on_admob_initialized

@onready var admob: Admob = $Admob
@onready var interstitial_ad_timer: Timer = $"Interstitial Ad Timer"
@onready var banner_background: Panel = $BannerBackground

var interstitial_ad_loaded : bool = false
var admob_initialized:bool = false
var _can_show_interstitial_ad : bool = false
var rounds_between_ad:int = 1
var rounds_played:int = 0
var banner_ad_showing : bool = false
var banner_ad_loading : bool = false

var interstitial_ads_shown = 0
var ad_points = 0
var banner_ad_size = Vector2.ZERO
enum AGE_GROUP {UNSPECIFIED,UNDER_13, UNDER_16, UNDER_18, ADULT}
var user_age_group : AGE_GROUP
var _current_size_y : float
@onready var orientation_change_timer :Timer = $OrientationChangeTimer

var wait_consent: bool = true


func _ready() -> void:
	GameSettings.on_viewportChanged.connect(_on_viewport_size_changed)
	orientation_change_timer.timeout.connect(setup_banner_ad)
	banner_background.visible = false

func _on_viewport_size_changed() -> void:
	#_current_size_y = get_viewport_rect().size.y
	if admob_initialized and !banner_ad_loading:
		remove_banner_ad()
		#if !orientation_change_timer.is_stopped():
			#orientation_change_timer.stop()
		orientation_change_timer.start(0.5)
	

func set_age_group(age_group : AGE_GROUP) -> void:
	#Logging.error("WARNING: Resetting consent info! Should never be done outside of testing.")
	#admob.reset_consent_info()
	user_age_group = age_group
	match age_group:
		AGE_GROUP.UNSPECIFIED: 
			admob.max_ad_content_rating = AdmobConfig.ContentRating.G
			admob.under_age_of_consent = AdmobConfig.TagForUnderAgeOfConsent.TRUE
			admob.personalization_state = AdmobConfig.PersonalizationState.DISABLED
		AGE_GROUP.UNDER_13:
			admob.max_ad_content_rating = AdmobConfig.ContentRating.G
			admob.under_age_of_consent = AdmobConfig.TagForUnderAgeOfConsent.TRUE
			admob.personalization_state = AdmobConfig.PersonalizationState.DISABLED
		AGE_GROUP.UNDER_16:
			admob.max_ad_content_rating = AdmobConfig.ContentRating.T
			admob.under_age_of_consent = AdmobConfig.TagForUnderAgeOfConsent.TRUE
			admob.personalization_state = AdmobConfig.PersonalizationState.DISABLED
		AGE_GROUP.UNDER_18:
			admob.max_ad_content_rating = AdmobConfig.ContentRating.T
			admob.under_age_of_consent = AdmobConfig.TagForUnderAgeOfConsent.FALSE
		AGE_GROUP.ADULT:
			admob.max_ad_content_rating = AdmobConfig.ContentRating.MA
			admob.under_age_of_consent = AdmobConfig.TagForUnderAgeOfConsent.FALSE
	check_consent_status()
			
	

func initialize() -> void:
	if !admob_initialized:
		Logging.logMessage("Initializing admob")
		
		#admob.get_consent_status()
		admob.initialize()
		interstitial_ad_timer.timeout.connect(func(): 
			Logging.logMessage("Can show ad!")
			_can_show_interstitial_ad = true
			)
		interstitial_ad_timer.start()
		if !GameSettings.game_running:
			interstitial_ad_timer.paused = true
		GameSettings.on_gameBegin.connect(func(): 
			Logging.logMessage("Unpausing ad timer")
			interstitial_ad_timer.paused = false)
		GameSettings.on_gameOver.connect(func(): 
			Logging.logMessage("Pausing ad timer")
			
			interstitial_ad_timer.paused = true)


func _on_admob_initialization_completed(_status_data: InitializationStatus) -> void:
	Logging.logMessage("Admob initialized")
	admob_initialized = true
	#check_consent_status()
	on_admob_initialized.emit()
	setup_ads()

	#Logging.logMessage("Loading consent form")
	
func check_consent_status() -> void:
	var user_consent : UserConsent = admob.get_consent_status()
	var consentStatus : UserConsent.Status
	if user_consent:
		consentStatus = user_consent.status
	else:
		consentStatus = UserConsent.Status.UNKNOWN
	Logging.logMessage("Consent status: " + UserConsent.status_to_string(consentStatus))
	
	match consentStatus:
		UserConsent.Status.UNKNOWN:
			Logging.warn("Unknown consent status!")
			if OS.has_feature("mobile"):
				admob.update_consent_info()
			else:
				Logging.warn("Admob only works on mobile devices. Setting to initialized")
				on_admob_initialized.emit()
				
			#admob.load_consent_form()
		UserConsent.Status.REQUIRED:
			Logging.warn("Consent required!")
			wait_consent = true
			if admob.is_consent_form_available():
				
				Logging.logMessage("Consent form is already avaliable. Showing..")
				#admob.show_consent_form()
				admob.load_consent_form()
			else:
				Logging.logMessage("Consent form not avaliable. Loading..")
				admob.load_consent_form()
		UserConsent.Status.OBTAINED:
			Logging.logMessage("Consent obtained. Setting up ads.")
			#setup_ads()
			initialize()
		UserConsent.Status.NOT_REQUIRED:
			Logging.logMessage("Consent not required. Setting up ads.")
			#setup_ads()
			initialize()
			

func setup_ads():
	setup_banner_ad()
	setup_interstitial_ad()
	
	
func setup_banner_ad() -> void:
	if admob_initialized:
		_current_size_y = get_viewport_rect().size.y
		Logging.logMessage("Loading banner ad")
		admob.set_banner_position(LoadAdRequest.AdPosition.BOTTOM)
		#admob.set_banner_size(LoadAdRequest.RequestedAdSize.BANNER)
		admob.set_banner_size(LoadAdRequest.RequestedAdSize.ADAPTIVE)
		
		#var req = admob.create_banner_ad_request()
		#req.set_anchor_to_safe_area(true)
		#req.set_ad_size(admob.get_portrait_adaptive_banner_size())
		#req.set_adaptive_width(get_viewport_rect().size.x)
		admob.load_banner_ad()
		banner_ad_loading = true


func show_banner_ad() -> void:
	admob.show_banner_ad()
	banner_ad_showing = true


func hide_banner_ad() -> void:
	admob.hide_banner_ad()
	banner_ad_showing = false


func remove_banner_ad() -> void:
	if admob_initialized:
		admob.hide_banner_ad()
		admob.remove_banner_ad()
		banner_ad_showing = false
		banner_background.visible =false
		banner_ad_size = Vector2.ZERO
		GameSettings.on_banner_ad_changed.emit()
		

func show_consent_form() -> void:
	if admob_initialized:
		if admob.is_consent_form_available():
			Logging.logMessage("Consent form is already avaliable. Showing..")
			admob.load_consent_form()
			#admob.show_consent_form()
		else:			
			Logging.logMessage("Loading consent form..")
			admob.load_consent_form()
	

func _on_admob_banner_ad_failed_to_load(ad_info: AdInfo, error_data: LoadAdError) -> void:
	var response_infos:Array[AdapterResponseInfo] = error_data.get_response_info().get_adapter_responses()
	Logging.error("Banner ad failed to load!")
	banner_ad_loading = false
	for response:AdapterResponseInfo in response_infos:
		var ad_error : AdError = response.get_ad_error()
		if ad_error:
			Logging.error("Banner ad error: " + str(ad_error.get_code()) + " " + ad_error.get_message())
	

func _on_admob_banner_ad_loaded(ad_info: AdInfo, _response_info: ResponseInfo) -> void:
	Logging.logMessage("Banner ad loaded!")
	if _current_size_y != get_viewport_rect().size.y:
		admob.remove_banner_ad(ad_info.get_ad_id())
		setup_banner_ad()
		return
	banner_ad_loading = false
	admob.show_banner_ad(ad_info.get_ad_id())
	banner_ad_showing = true

	var dim_pix = admob.get_banner_dimension_in_pixels(ad_info.get_ad_id())
	var ratio = get_viewport_rect().end.y/DisplayServer.screen_get_size().y
	banner_ad_size = dim_pix* ratio
	Logging.logMessage("Banner ad size: " + str(banner_ad_size))
	Logging.logMessage("Screen size: " + str(get_viewport_rect().size))
	banner_background.custom_minimum_size.y = banner_ad_size.y
	banner_background.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	banner_background.visible = true
	
	GameSettings.on_banner_ad_changed.emit()
	

func setup_interstitial_ad() -> void:
	Logging.logMessage("Loading interstitial ad")
	if admob_initialized and !interstitial_ad_loaded:
		var req = admob.create_interstitial_ad_request()
		admob.load_interstitial_ad(req)


func _on_admob_interstitial_ad_loaded(_ad_info: AdInfo, _response_info: ResponseInfo) -> void:
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
		interstitial_ads_shown +=1
		ad_points = 0
		setup_interstitial_ad()
		return true
	else:
		return false
		

func _on_admob_consent_form_failed_to_load(error_data: FormError) -> void:
	Logging.error("Consent form failed to load! Status Code: " + str(error_data.get_code()) + ". Message: " + error_data.get_message())
	admob.personalization_state = AdmobConfig.PersonalizationState.DISABLED
	pass # Replace with function body.


func _on_admob_consent_form_loaded() -> void:
	Logging.logMessage("Consent form loaded! Showing...")
	admob.show_consent_form()
	

func _on_admob_consent_info_update_failed(error_data: FormError) -> void:
	Logging.error("Error updating consent info! " + error_data.get_message())
	pass # Replace with function body.


func _on_admob_consent_info_updated() -> void:
	Logging.logMessage("Consent info updated!")
	check_consent_status()


func _on_admob_consent_form_dismissed(error_data: FormError) -> void:
	Logging.logMessage("Consent form dismissed!" )
	var error_message : String = error_data.get_message()
	if not error_message.is_empty():
		Logging.error(error_message)
	admob.update_consent_info()


func _on_admob_interstitial_ad_dismissed_full_screen_content(ad_info: AdInfo) -> void:
	Logging.logMessage("Interstitial Ad Dismissed")


func _on_admob_interstitial_ad_clicked(ad_info: AdInfo) -> void:
	Logging.logMessage("Interstitial Ad Clicked")


func _on_admob_banner_ad_refreshed(ad_info: AdInfo, response_info: ResponseInfo) -> void:
	Logging.logMessage("Banner Ad Refreshed")
	var new_size = admob.get_banner_dimension_in_pixels()
	DisplayServer.screen_get_scale()
	if banner_ad_size != new_size:
		banner_ad_size = new_size
		GameSettings.on_banner_ad_changed.emit()
