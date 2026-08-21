class_name LoadotLogger extends Node

var mod_name : String

func _init(_mod_name) -> void:
	self.mod_name = _mod_name

func fatal(message : String) -> void:
	push_error(_format_log(message, "FATAL"))

func error(message : String) -> void:
	push_error(_format_log(message, "ERROR"))

func warning(message : String) -> void:
	push_warning(_format_log(message, "WARNING"))

func info(message : String) -> void:
	print(_format_log(message, "INFO"))

func debug(message : String) -> void:
	# This function does not use print_debug because it doesn't work in non-debug projects
	print_rich("[color=gray]%s[/color]" % _format_log(message, "DEBUG"))

func _format_log(message : String, log_type : String) -> String:
	match log_type:
		"FATAL", "ERROR", "WARNING":
			return "<%s> %s" % [mod_name, message]
		_:
			return "%s: <%s> %s" % [log_type, mod_name, message]
	
