extends Button

const THEME_TYPE = "CheatTabButton"

var animated_style: StyleBoxFlat
var tween: Tween

@onready var style_normal: StyleBoxFlat = get_theme_stylebox("normal", THEME_TYPE)
@onready var style_hover: StyleBoxFlat = get_theme_stylebox("hover", THEME_TYPE)
@onready var style_pressed: StyleBoxFlat = get_theme_stylebox("pressed", THEME_TYPE)

func _ready() -> void:
	assert(style_normal and style_hover and style_pressed, "Ошибка: Убедитесь, что для TabButton в теме настроены StyleBoxFlat!")

	animated_style = style_normal.duplicate()
	
	add_theme_stylebox_override("normal", animated_style)
	add_theme_stylebox_override("hover", animated_style)
	add_theme_stylebox_override("pressed", animated_style)
	add_theme_stylebox_override("focus", StyleBoxEmpty.new())

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	toggled.connect(_on_toggled)

func refresh_theme() -> void:
	# Временный Control для чтения чистой темы
	var temp = Control.new()
	temp.theme = theme
	
	style_normal = temp.get_theme_stylebox("normal", THEME_TYPE)
	style_hover = temp.get_theme_stylebox("hover", THEME_TYPE)
	style_pressed = temp.get_theme_stylebox("pressed", THEME_TYPE)
	
	temp.free()
	
	# Анимируем к текущему состоянию
	if button_pressed:
		_animate_to_properties(style_pressed.border_width_left, style_pressed.bg_color)
	elif is_hovered():
		_animate_to_properties(style_hover.border_width_left, style_hover.bg_color)
	else:
		_animate_to_properties(style_normal.border_width_left, style_normal.bg_color)

func _on_mouse_entered() -> void:
	if not button_pressed:
		_animate_to_properties(style_hover.border_width_left, style_hover.bg_color)

func _on_mouse_exited() -> void:
	if not button_pressed:
		_animate_to_properties(style_normal.border_width_left, style_normal.bg_color)

func _on_toggled(is_pressed: bool) -> void:
	if is_pressed:
		_animate_to_properties(style_pressed.border_width_left, style_pressed.bg_color)
	else:
		_animate_to_properties(style_normal.border_width_left, style_normal.bg_color)

func _animate_to_properties(target_border_left: int, target_bg: Color) -> void:
	if tween:
		tween.kill()
	
	tween = create_tween().set_parallel(true)
	tween.tween_property(animated_style, "border_width_left", target_border_left, 0.15)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_style, "bg_color", target_bg, 0.15)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
