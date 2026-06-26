extends Control

class_name BillingManager
const AD_REMOVAL_POPUP = preload("uid://o1ojbpayppki")
const POPUP_MENU = preload("uid://chupiwnqy5234")

@onready var billing_client:BillingClient = BillingClient.new()

@export var enable = true

signal loading_finished

var remove_ads_id : String = "loopdog_remove_ads"
var products_loaded : bool = false
var purchases_checked : bool = false
var no_ads_purchased: bool = false

var ad_removal_popup : PopupContainer
var remove_ads_product
var _ad_removal_purchase
var max_retries = 3
var consecutive_exceptions = 0


func _ready() -> void:
	Logging.logMessage("Billing manager getting ready")
	if enable:
		billing_client.connected.connect(_on_connected)
		billing_client.disconnected.connect(_on_disconnected) # No params
		billing_client.connect_error.connect(_on_connect_error) # response_code: int, debug_message: String
		billing_client.query_product_details_response.connect(_on_query_product_details_response) # response: Dictionary
		billing_client.query_purchases_response.connect(_on_query_purchases_response) # response: Dictionary
		billing_client.on_purchase_updated.connect(_on_purchase_updated) # response: Dictionary
		billing_client.acknowledge_purchase_response.connect(_on_acknowledge_purchase_response) # response: Dictionary
		billing_client.start_connection()
		Firebase.Functions.task_error.connect(_on_fb_task_error)
		#ad_removal_popup.visible = false
	else:
		loading_finished.emit()
	

func query_product_details():
	Logging.logMessage("Querying product details!")
	
	billing_client.query_product_details([remove_ads_id],BillingClient.ProductType.INAPP)


func query_purchases():
	Logging.logMessage("Querying purchases!")
	billing_client.query_purchases(BillingClient.ProductType.INAPP) # Or BillingClient.ProductType.SUBS for subscriptions.


func send_verification_request(purchase:Dictionary) -> void:
	var strPurchase:String = str(purchase)
	var task = Firebase.Functions.execute("verifyPurchase", HTTPClient.METHOD_POST,{}, {"data":strPurchase})
	task.function_executed.connect(_on_fb_verification_finished)
	

func update_popup():
	if products_loaded and purchases_checked and !no_ads_purchased and is_instance_valid(ad_removal_popup):
		ad_removal_popup.button_yes.pressed.connect.call_deferred(_on_button_yes_pressed)
		ad_removal_popup.button_no.pressed.connect.call_deferred(_on_button_no_pressed)
		var currency = remove_ads_product.one_time_purchase_offer_details.price_currency_code
		var price : String = remove_ads_product.one_time_purchase_offer_details.formatted_price
		ad_removal_popup.title.text = remove_ads_product.name
		ad_removal_popup.description.text = remove_ads_product.description
		ad_removal_popup.price_label.text = currency + " " + price


func show_ad_removal_popup() -> void:
	ad_removal_popup = UINavigator.open_from_scene(AD_REMOVAL_POPUP)
	update_popup()
#	UINavigator.open(ad_removal_popup)


func _on_connected():
	Logging.logMessage("Connected to billing!")
	consecutive_exceptions = 0
	query_product_details()
	query_purchases()
	

func _on_disconnected():
	pass
	
	
func _on_connect_error(response_code: int, debug_message: String):
	Logging.error("Error connecting to billing! Status: " + str(response_code) + " Message: " + debug_message)
	consecutive_exceptions+=1
	Logging.logMessage("Consecutive exceptions: " + str(consecutive_exceptions))
	if consecutive_exceptions <= max_retries:
		Logging.logMessage("Retrying connection to billing manager.")
		billing_client.start_connection()
	else:
		Logging.warn("Maximum number of retries has been reached! Could not connect to billing manager...")


func _on_query_product_details_response(query_result: Dictionary):
	Logging.logMessage("Product details query success")
	
	if query_result.response_code == billing_client.BillingResponseCode.OK:
		for available_product in query_result.product_details:
			if available_product.product_id == remove_ads_id:
				remove_ads_product = available_product
				products_loaded = true
				update_popup()
		checkLoadingFinished()
			
			
func _on_query_purchases_response(query_result: Dictionary):
	if query_result.response_code == BillingClient.BillingResponseCode.OK:
		Logging.logMessage("Purchase query success")
		for purchase in query_result.purchases:
			if purchase.purchase_state == billing_client.PurchaseState.PURCHASED:
				for id in purchase.product_ids:
					if id == remove_ads_id:
						_ad_removal_purchase = purchase
						if not purchase.is_acknowledged:
							Logging.logMessage("Unacknowledged purchase found. Verifying purchase...")
							if Firebase.Auth and not Firebase.Auth.auth.is_empty():
								send_verification_request(purchase)
							else: 
								await Firebase.ready
								send_verification_request(purchase)
						else:
							no_ads_purchased = true
							GameSettings.remove_all_ads()
		purchases_checked = true
		update_popup()	
		checkLoadingFinished()
	else:
		Logging.error("Purchase query failed")
		Logging.error("response_code: "+ query_result.response_code + " debug_message: " + query_result.debug_message)


func checkLoadingFinished() -> void:
	if(purchases_checked and products_loaded):
		loading_finished.emit()
		
		
func _on_purchase_updated(response: Dictionary):
	Logging.logMessage("Purchases updated")
	var response_ok:bool = false
	if response.response_code == billing_client.BillingResponseCode.OK:
		response_ok = true
		consecutive_exceptions = 0
		for purchase in response.purchases:
			if purchase.package_name != "loopdog.loopdog":
				Logging.error("Purchase comes from a different package!")
			else:
				match purchase.purchase_state:
					billing_client.PurchaseState.PURCHASED:
						for id in purchase.product_ids:
							if id == remove_ads_id:
								Logging.logMessage("Verifying purchase...")
								_ad_removal_purchase = purchase
								send_verification_request(purchase)
					billing_client.PurchaseState.PENDING:
						var pending_popup : PopupContainer = UINavigator.open_from_scene(POPUP_MENU)
						pending_popup.title.text = tr("BILLING_PENDING_TITLE")
						pending_popup.description.text = tr("BILLING_PENDING_DESCRIPTION")
					_:
						Logging.error("Unknown purchase state: " + str(purchase.PurchaseState))
						_show_error_popup("Unable to verify that the purchase went through correctly.")
	else:
		match response.response_code:	#TODO: translate these
			billing_client.BillingResponseCode.FEATURE_NOT_SUPPORTED:
				_show_error_popup("This feature is not supported.")
			billing_client.BillingResponseCode.USER_CANCELED:
				_show_error_popup("The purchase was cancelled by the user.")
				UINavigator.back()
				UINavigator.back()
			billing_client.BillingResponseCode.ITEM_UNAVAILABLE:
				_show_error_popup("The item is no longer avaliable.")
			billing_client.BillingResponseCode.DEVELOPER_ERROR:
				_show_error_popup(tr("UNKNOWN_ERROR"))
			billing_client.BillingResponseCode.ITEM_ALREADY_OWNED: ##TODO Could retry this too sometimes?
				_show_error_popup("You seem to already own this.")
			_: 
				_check_retry_purchase()
			
	if not response_ok:
		Logging.error("Something went wrong with the purchase! Status: " + str(response.response_code) + ". Message: " + response.debug_message)
	

func _check_retry_purchase() -> void:
	consecutive_exceptions+=1
	Logging.logMessage("Consecutive exceptions: " + str(consecutive_exceptions))
	if consecutive_exceptions <= max_retries:
		Logging.logMessage("Retrying purchase.")
		billing_client.purchase(remove_ads_id)
	else:
		Logging.warn("Maximum number of retries has been reached!")
		_show_error_popup(tr("UNKNOWN_ERROR"))
		consecutive_exceptions = 0


func _on_fb_verification_finished(status, response) -> void:
	if response.has("error"):
		Logging.error("Firebase Function returned an error: " + response["error"])
		# Example: Handle specific error states
		#_handle_function_error(response["error"])
	elif response["result"]["result"] == "SUCCESS":
		Logging.logMessage("Function succeeded!")
		billing_client.acknowledge_purchase(_ad_removal_purchase.purchase_token)
	else:
		Logging.warn("Function succeeded, but purchase is invalid! Reason: " + response["result"]["result"])
		_show_error_popup("The purchase could not be validated...") #TODO: translate these
	

func _on_fb_task_error(code, status, message) -> void:
	Logging.error("Purchase verification failed! Status code: " + str(code))
	Logging.error("Status: " +  str(status))
	Logging.error("Message: " +  str(message))
	_show_error_popup("An unknown error occurred") #TODO: translate these
	#TODO: Something 


func _on_acknowledge_purchase_response(response: Dictionary):
	Logging.logMessage("Acknowledge purchase response")
	match response.response_code:
		billing_client.BillingResponseCode.OK:
			UINavigator.back()
			var popup : PopupContainer = UINavigator.open_from_scene(POPUP_MENU)
			popup.title.text = tr("AD_REMOVAL_PURCHASED_TITLE")
			popup.description.text = tr("AD_REMOVAL_PURCHASED_DESCRIPTION")
			Logging.logMessage("Purchase acknowledged!")
			no_ads_purchased = true
			GameSettings.remove_all_ads()
		_:
			Logging.logMessage("Error acknowledging purchase! Status: " + str(response.response_code) + ". Message: " + response.debug_message)


func _show_error_popup(description:String) -> void:
	var error_popup : PopupContainer = UINavigator.open_from_scene(POPUP_MENU)
	error_popup.title.text = tr("ERROR")
	error_popup.description.text = description


func _on_button_yes_pressed() -> void:
	Logging.logMessage("Trying to purchase ad removal!")
	billing_client.purchase(remove_ads_id)
	

func _on_button_no_pressed() -> void:
	UINavigator.back()
