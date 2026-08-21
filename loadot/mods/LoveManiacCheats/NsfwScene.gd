class_name NsfwScene

var clothes_to_destroy: Array[StringName] = []
var arousal_level: int = 0
var to_execute: Callable

func _init(_clothes_to_destroy: Array[StringName], _arousal_level: int, _execute: Callable):
	clothes_to_destroy = _clothes_to_destroy
	arousal_level = _arousal_level
	to_execute = _execute
