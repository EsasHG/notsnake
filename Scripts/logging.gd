extends Node

var _logWindow: Control
var _logLabel: RichTextLabel
var missedLogs:Array[String]
var missedTypes:Array[int]


func _ready() -> void:
	call_deferred("_findLogWindow")
	

func _findLogWindow():
	_logWindow = get_tree().root.find_child("LogWindow",true,false)
	if !_logWindow:
		error("Log window not found!")
		return
	_logLabel = _logWindow.find_child("LogLabel",true,false)
	_logLabel.get_v_scroll_bar().custom_minimum_size = Vector2(40,40)
	_logLabel.process_mode = Node.PROCESS_MODE_ALWAYS
	_logLabel.newline()
	_logLabel.newline()
	for i in range(missedLogs.size()):
		match missedTypes[i]:
			0:
				_add_error_to_log_window(missedLogs[i])
			1:
				_add_warning_to_log_window(missedLogs[i])
			2:
				_add_log_to_log_window(missedLogs[i])
		

func error(s:String):
	printerr(s)
	if _logLabel:
		_add_error_to_log_window(s)
	else:
		missedLogs.append(s)
		missedTypes.append(0)
	
	
func warn(s:String):
	print(s)
	if _logLabel:
		_add_warning_to_log_window(s)
	else:
		missedLogs.append(s)
		missedTypes.append(1)
	
	
func logMessage(s:String):
	print(s)
	if _logLabel:
		_add_log_to_log_window(s)
	else:
		missedLogs.append(s)
		missedTypes.append(2)
	

func showLogWindow(show:bool):
	_logWindow.visible = show
	

func isLogWindowVisible() -> bool:
	return _logWindow.visible
	
	
func _add_error_to_log_window(s:String) -> void:
	_logLabel.push_color(Color.FIREBRICK)
	_logLabel.add_text(s)
	_logLabel.newline()
	
	
func _add_warning_to_log_window(s:String) -> void:
	_logLabel.push_color(Color.DARK_GOLDENROD)
	_logLabel.add_text(s)
	_logLabel.newline()


func _add_log_to_log_window(s:String) -> void:
	_logLabel.push_color(Color.WHITE)
	_logLabel.add_text(s)
	_logLabel.newline()
