extends Node2D
class_name  AdManager

signal on_admob_initialized

@onready var admob: Admob = $Admob
@onready var interstitial_ad_timer: Timer = $"Interstitial Ad Timer"

var interstitial_ad_loaded : bool = false
var admob_initialized:bool = false
var _can_show_interstitial_ad : bool = false
var rounds_between_ad:int = 3
var rounds_played:int = 0
var banner_ad_showing : bool = false

enum AGE_GROUP {UNSPECIFIED,UNDER_13, UNDER_16, UNDER_18, ADULT}
var user_age_group : AGE_GROUP

var wait_consent: bool = true


func _ready() -> void:
	pass
	
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
	

func _on_admob_initialization_completed(status_data: InitializationStatus) -> void:
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
			admob.update_consent_info()
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
		Logging.logMessage("Loading banner ad")
		admob.set_banner_position(LoadAdRequest.AdPosition.BOTTOM)
		#admob.set_banner_size(LoadAdRequest.AdSize.BANNER)
		admob.set_banner_size(LoadAdRequest.RequestedAdSize.FULL_BANNER)
		admob.load_banner_ad()


func remove_banner_ad() -> void:
	if admob_initialized:
		admob.hide_banner_ad()
		admob.remove_banner_ad()
		banner_ad_showing = false
		

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
	for response:AdapterResponseInfo in response_infos:
		var ad_error : AdError = response.get_ad_error()
		if ad_error:
			Logging.error("Banner ad error: " + str(ad_error.get_code()) + " " + ad_error.get_message())
	

func _on_admob_banner_ad_loaded(ad_info: AdInfo, _response_info: ResponseInfo) -> void:
	Logging.logMessage("Banner ad loaded! Showing ad")
	admob.show_banner_ad(ad_info.get_ad_id())
	banner_ad_showing = true
	

func setup_interstitial_ad() -> void:
	Logging.logMessage("Loading interstitial ad")
	if admob_initialized and !interstitial_ad_loaded:
		admob.load_interstitial_ad()


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
