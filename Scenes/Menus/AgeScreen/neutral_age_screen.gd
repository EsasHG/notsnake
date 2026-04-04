extends VBoxContainer
@onready var year_dropdown: OptionButton = $DropdownBoxContainer/AgeDrowpdownBoxContainer/YearDropdown
@onready var month_dropdown: OptionButton = $DropdownBoxContainer/AgeDrowpdownBoxContainer/MonthDropdown
@onready var day_dropdown: OptionButton = $DropdownBoxContainer/AgeDrowpdownBoxContainer/DayDropdown
@onready var error_label: Label = $ErrorLabel

var days_in_month :Array[int] = [31,28,31,30,31,30,31,31,30,31,30,31]
var _selected_year:int = -1
var _selected_month:int = -1
var _selected_day:int = -1
var _current_date : Dictionary


func _ready() -> void:
	_current_date = Time.get_date_dict_from_system()
	_create_year_dropdown()
	_create_month_dropdown()
	_create_day_dropdown()
	year_dropdown.select(-1)
	month_dropdown.select(-1)
	day_dropdown.select(-1)
	error_label.visible = false


func _create_year_dropdown() -> void:
	year_dropdown.clear()
	for year in range(_current_date.year,1899,-1):
		year_dropdown.add_item(str(year))


func _create_month_dropdown() -> void:
	month_dropdown.clear()
	var end_month= 12 
	if _selected_year == _current_date.year:
		end_month = _current_date.month
	for month in end_month:
		var opt_zero: String = "0" if month < 9 else ""
		month_dropdown.add_item(opt_zero + str(month+1))
	if _selected_month >= month_dropdown.item_count:
		_selected_month = -1
	month_dropdown.select(_selected_month)
	
	
func _create_day_dropdown() -> void:
	day_dropdown.clear()
	var days = 31
	if _selected_year == _current_date.year and _selected_month+1 == _current_date.month:
		days = _current_date.day
	elif _selected_month >= 0:
		days = days_in_month[_selected_month]
		
	for day in days:
		var opt_zero: String = "0" if day < 9 else ""
		day_dropdown.add_item(opt_zero + str(day+1))
		##handle leap years
	if _selected_month == 1 && _is_leap_year(_selected_year):
		day_dropdown.add_item(str(29)) 
		
	if _selected_day >= day_dropdown.item_count:
		_selected_day = -1
	day_dropdown.select(_selected_day)
		

func _is_leap_year(year:int) -> bool:
	return ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)
	
func _check_hide_error_label() -> void:
	if _selected_year >= 0 and _selected_month >= 0 and _selected_day >= 0:
		error_label.visible = false  

func _check_date_valid() -> bool:
	if 1900 > _selected_year or _selected_year > _current_date.year:
		return false
		
	var max_month:int = 12 if _selected_year != _current_date.year else _current_date.month
	if _selected_month < 1 or _selected_month > max_month:	
		return false
		
	var max_day: int = days_in_month[_selected_month-1]
	if _is_leap_year(_selected_year) and _selected_month == 2:
		max_day+=1
	if _selected_year == _current_date.year and _selected_month == _current_date.month:
		max_day = _current_date.day
	if _selected_day < 1 or _selected_day > max_day:
		return false
		
	return true
	
	
func _on_confirm_pressed() -> void:
	
	if !_check_date_valid():
		error_label.visible = true
	else:
		var year = _selected_year
		var month = _selected_month+1
		var day = _selected_day+1
		var age = _current_date.year - year
		if month > _current_date.month:
			age-=1
		elif month == _current_date.month and day > _current_date.day:
			age-=1
		
		var age_group : AdManager.AGE_GROUP
		if age < 13:
			age_group = AdManager.AGE_GROUP.UNDER_13
		elif age < 16:
			age_group = AdManager.AGE_GROUP.UNDER_16
		elif age < 18:
			age_group = AdManager.AGE_GROUP.UNDER_18
		else:
			age_group = AdManager.AGE_GROUP.ADULT
		GameSettings.set_age_group(age_group)
		SaveManager._save_age_group()
		UINavigator.force_back()
		

func _on_year_dropdown_item_selected(index: int) -> void:
	var year_text = year_dropdown.get_item_text(index)
	_selected_year = int(year_text)
	_create_month_dropdown()
	_create_day_dropdown()
	_check_hide_error_label()


func _on_month_dropdown_item_selected(index: int) -> void:
	Logging.logMessage("Month selected! Index: " + str(index))
	_selected_month = index
	_create_day_dropdown()
	_check_hide_error_label()


func _on_day_dropdown_item_selected(index: int) -> void:
	_selected_day = index
	_check_hide_error_label()


func _on_year_line_edit_text_changed(new_text: String) -> void:
	
	if new_text.is_valid_int() and new_text.length() == 4:
		_selected_year = int(new_text)
	else:
		_selected_year = 0


func _on_month_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int() and new_text.length() == 2:
		_selected_month = int(new_text)
	else:
		_selected_month = 0


func _on_day_line_edit_text_changed(new_text: String) -> void:
	if new_text.is_valid_int() and new_text.length() == 2:
		_selected_day = int(new_text)
	else:
		_selected_day = 0
