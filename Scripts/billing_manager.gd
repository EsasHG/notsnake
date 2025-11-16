extends Node2D

class_name BillingManager


@onready var billing_client:BillingClient = BillingClient.new()
func _ready() -> void:
	billing_client.connected.connect(_on_connected)
	billing_client.disconnected.connect(_on_disconnected) # No params
	billing_client.connect_error.connect(_on_connect_error) # response_code: int, debug_message: String
	billing_client.query_product_details_response.connect(_on_query_product_details_response) # response: Dictionary
	billing_client.query_purchases_response.connect(_on_query_purchases_response) # response: Dictionary
	billing_client.on_purchase_updated.connect(_on_purchase_updated) # response: Dictionary
	billing_client.consume_purchase_response.connect(_on_consume_purchase_response) # response: Dictionary
	billing_client.acknowledge_purchase_response.connect(_on_acknowledge_purchase_response) # response: Dictionary
	billing_client.start_connection()

func query_product_details():
	billing_client.query_product_details(["temp_test_id"],BillingClient.ProductType.INAPP)

func query_purchases():
	billing_client.query_purchases(BillingClient.ProductType.INAPP) # Or BillingClient.ProductType.SUBS for subscriptions.

func _on_connected():
	query_product_details()
	
	
	
func _on_disconnected():
	pass
	
func _on_connect_error(response_code: int, debug_message: String):
	pass

func _on_query_product_details_response(query_result: Dictionary):
	if query_result.response_code == billing_client.BillingResponseCode.OK:
		for available_product in query_result.product_details:
			print(available_product)
	pass

func _on_query_purchases_response(query_result: Dictionary):
	if query_result.response_code == BillingClient.BillingResponseCode.OK:
		print("Purchase query success")
		for purchase in query_result.purchases:
			Logging.logMessage(purchase)
	else:
		print("Purchase query failed")
		print("response_code: ", query_result.response_code, "debug_message: ", query_result.debug_message)
		
func _on_purchase_updated(response: Dictionary):
	pass	
	
func _on_consume_purchase_response(response: Dictionary):
	pass
	
func _on_acknowledge_purchase_response(response: Dictionary):
	pass
