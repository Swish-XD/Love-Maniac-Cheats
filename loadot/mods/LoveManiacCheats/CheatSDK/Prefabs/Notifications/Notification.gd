extends PanelContainer

@export var title_text: Label
@export var message_text: Label
@export var dissmiss_button: Button

@export var showtime_time: float = 5.0

var title_max_lenght: int = 32
var message_max_lenght: int = 128

func show_notification(title_string: String, message_string: String) -> void:
	if title_string.length() > title_max_lenght:
		print("[Notifications] Your notification title contains information that exceeds 32 characters.")
		return
	if message_string.length() > message_max_lenght:
		print("[Notifications] Your notification message contains information that exceeds 128 characters.")
		return
	
	title_text.text = title_string
	message_text.text = message_string
	
	if not dissmiss_button.pressed.is_connected(_on_button_clicked):
		dissmiss_button.pressed.connect(_on_button_clicked)
	
	var tween = create_tween()
	tween.tween_interval(showtime_time)
	tween.tween_callback(queue_free)

func _on_button_clicked():
	if is_instance_valid(self) and is_inside_tree():
		queue_free()
