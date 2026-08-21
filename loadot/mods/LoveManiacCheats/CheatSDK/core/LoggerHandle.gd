extends Node

var base_class_name: String
enum LogType { INFO, SUCCESS, WARN, ERROR, CRITICAL }

func _init(_class_name: String):
	base_class_name = _class_name

func get_class_name_clean(target: Variant) -> String:
	if typeof(target) != TYPE_OBJECT or target == null:
		return "System"
	var script_resource: Script = target.get_script()
	if script_resource == null:
		return target.get_class()
	var global_name: String = script_resource.get_global_name()
	if global_name.is_empty():
		return target.get_class()
	return global_name

func log_msg(sender: Variant, message: String, type: LogType = LogType.INFO) -> void:
	var sender_class: String = get_class_name_clean(sender)
	
	var type_name: String = ""
	var color_hex: String = ""
	
	match type:
		LogType.INFO:
			type_name = "INFO"
			color_hex = "#F7F7F8"
		LogType.SUCCESS:
			type_name = "OK"
			color_hex = "#34FE7B"
		LogType.WARN:
			type_name = "WARNING"
			color_hex = "#FDD212"
		LogType.ERROR:
			type_name = "ERROR"
			color_hex = "#FE395D"
		LogType.CRITICAL:
			type_name = "CRITICAL ERROR"
			color_hex = "#750401"
	
	var final_log = "[color=#01D0DF][b][{class} // {script}][/b][/color] [color={color}][b][{type}][/b][/color]: {msg}".format({
		"class": base_class_name.capitalize(),
		"script": sender_class,
		"type": type_name,
		"color": color_hex,
		"msg": message
	})
	
	print_rich(final_log)
