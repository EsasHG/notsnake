extends Control

class_name BillingManager
const AD_REMOVAL_POPUP = preload("uid://o1ojbpayppki")
const ERROR_POPUP = preload("uid://ttkw6vhl0p8c")
const PENDING_POPUP = preload("uid://cuvjnv1d6p5wc")
const PURCHASED_POPUP = preload("uid://b3m2an3pchd8w")

@onready var billing_client:BillingClient = BillingClient.new()

##For testing purposes only
@export var consume_ad_removal_purchase : bool = true
@export var enable = true

signal loading_finished

var remove_ads_id : String = "loopdog_remove_ads"
var products_loaded : bool = false
var purchases_checked : bool = false
var no_ads_purchased: bool = false

var ad_removal_popup : PopupContainer
var remove_ads_product
var _ad_removal_purchase
func _ready() -> void:
	Logging.logMessage("Billing manager getting ready")
	if enable:
		billing_client.connected.connect(_on_connected)
		billing_client.disconnected.connect(_on_disconnected) # No params
		billing_client.connect_error.connect(_on_connect_error) # response_code: int, debug_message: String
		billing_client.query_product_details_response.connect(_on_query_product_details_response) # response: Dictionary
		billing_client.query_purchases_response.connect(_on_query_purchases_response) # response: Dictionary
		billing_client.on_purchase_updated.connect(_on_purchase_updated) # response: Dictionary
		billing_client.consume_purchase_response.connect(_on_consume_purchase_response) # response: Dictionary
		billing_client.acknowledge_purchase_response.connect(_on_acknowledge_purchase_response) # response: Dictionary
		billing_client.start_connection()
		#ad_removal_popup.visible = false

	else:
		loading_finished.emit()
	

func query_product_details():
	Logging.logMessage("Querying product details!")
	
	billing_client.query_product_details([remove_ads_id],BillingClient.ProductType.INAPP)


func query_purchases():
	Logging.logMessage("Querying purchases!")
	billing_client.query_purchases(BillingClient.ProductType.INAPP) # Or BillingClient.ProductType.SUBS for subscriptions.


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
	query_product_details()
	query_purchases()
	
func _on_disconnected():
	pass
	
func _on_connect_error(response_code: int, debug_message: String):
	Logging.error("Error connecting to billing! Status: " + str(response_code) + " Message: " + debug_message)
	pass

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
				Logging.logMessage(str(purchase))
				for id in purchase.product_ids:
					if id == remove_ads_id:
						_ad_removal_purchase = purchase
						no_ads_purchased = true
						GameSettings.remove_all_ads()
						if not purchase.is_acknowledged:
							billing_client.acknowledge_purchase(purchase.purchase_token)

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
			for purchase in response.purchases:
				if purchase.package_name != "loopdog.loopdog":
					Logging.error("Purchase comes from a different package!")
				else:
					match purchase.purchase_state:
						billing_client.PurchaseState.PURCHASED:
							for id in purchase.product_ids:
								if id == remove_ads_id:
									GameSettings.remove_all_ads()
									billing_client.acknowledge_purchase(purchase.purchase_token)
									_ad_removal_purchase = purchase
						billing_client.PurchaseState.PENDING:
							UINavigator.open_from_scene(PENDING_POPUP)
								
	else:
		var error_popup : PopupContainer = UINavigator.open_from_scene(ERROR_POPUP)
		var error_description_label = error_popup.description
		match response.response_code:
			billing_client.BillingResponseCode.ITEM_ALREADY_OWNED:
				error_description_label.text = "You seem to already own this."
			billing_client.BillingResponseCode.USER_CANCELED:
				error_description_label.text = "The purchase was cancelled by the user."
			billing_client.BillingResponseCode.SERVICE_UNAVAILABLE:
				error_description_label.text = "The service is currently unavaliable. Try again later."
			billing_client.BillingResponseCode.BILLING_UNAVAILABLE:
				error_description_label.text = "The billing service is currently unavaliable. Try again later."
			billing_client.BillingResponseCode.ITEM_UNAVAILABLE:
				error_description_label.text = "The item is no longer avaliable."
			billing_client.BillingResponseCode.ITEM_NOT_OWNED:
				error_description_label.text = "An unknown error occurred!"
			billing_client.BillingResponseCode.NETWORK_ERROR:
				error_description_label.text = "An network error occurred!"
			billing_client.BillingResponseCode.SERVICE_DISCONNECTED:
				error_description_label.text = "The service disconnected."
			billing_client.BillingResponseCode.FEATURE_NOT_SUPPORTED:
				error_description_label.text = "This feature is not supported."
			billing_client.BillingResponseCode.SERVICE_TIMEOUT:
				error_description_label.text = "The service timed out."
			_: 
				error_description_label.text = "An unknown error occurred!"
			
	if not response_ok:
		Logging.error("Something went wrong with the purchase! Status: " + str(response.response_code) + ". Message: " + response.debug_message)
	
func _consume_purchase() -> void:
	Logging.logMessage("Trying to consume purchase")	
	if consume_ad_removal_purchase and _ad_removal_purchase:
		billing_client.consume_purchase(_ad_removal_purchase.purchase_token)
	elif !_ad_removal_purchase:
		Logging.error("No purchase to consume!")
		

func _on_consume_purchase_response(response: Dictionary):
	Logging.logMessage("Consume purchase response")
	if response.response_code == billing_client.BillingResponseCode.OK:
		Logging.logMessage("Purchase consumed!")
		no_ads_purchased = false
		_ad_removal_purchase = null
	else:
		Logging.error("Could not consume purchase! Status: " + str(response.response_code) + ". Message: " + response.debug_message)
		
	
func _on_acknowledge_purchase_response(response: Dictionary):
	Logging.logMessage("Acknowledge purchase response")
	match response.response_code:
		billing_client.BillingResponseCode.OK:
			UINavigator.open_from_scene(PURCHASED_POPUP)
			Logging.logMessage("Purchase acknowledged!")
		_:
			Logging.logMessage("Error acknowledging purchase! Status: " + str(response.response_code) + ". Message: " + response.debug_message)


func _on_button_yes_pressed() -> void:
	Logging.logMessage("Trying to purchase ad removal!")
	billing_client.purchase(remove_ads_id)


func _on_button_no_pressed() -> void:
	UINavigator.back()
