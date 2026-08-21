extends Control

var target_window: Control = null
var is_dragging: bool = false
var drag_start_position: Vector2

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	target_window = get_parent().get_parent() as Control

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start_position = get_local_mouse_position()
			accept_event()
		else:
			is_dragging = false

func _process(_delta: float) -> void:
	if is_dragging and target_window:
		target_window.global_position = get_global_mouse_position() - drag_start_position
