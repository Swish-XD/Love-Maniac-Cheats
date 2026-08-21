extends Button

signal key_assigned(new_key: Key)

const BUTTON_THEME_TYPE = "CheatHotkeyButton"

var animated_style: StyleBoxFlat
var tween: Tween

var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat
var style_pressed: StyleBoxFlat

var color_normal: Color
var color_hover: Color
var color_pressed: Color

var is_listening: bool = false
var current_key: Key = Key.KEY_NONE

var hotkey_listener

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	clip_contents = true
	
	style_normal = get_theme_stylebox("normal", BUTTON_THEME_TYPE)
	style_hover = get_theme_stylebox("hover", BUTTON_THEME_TYPE)
	style_pressed = get_theme_stylebox("pressed", BUTTON_THEME_TYPE)
	
	color_normal = get_theme_color("font_color", BUTTON_THEME_TYPE)
	color_hover = get_theme_color("font_hover_color", BUTTON_THEME_TYPE)
	color_pressed = get_theme_color("font_pressed_color", BUTTON_THEME_TYPE)
	
	if style_normal and style_hover:
		animated_style = style_normal.duplicate()
		
		add_theme_stylebox_override("normal", animated_style)
		add_theme_stylebox_override("hover", animated_style)
		add_theme_stylebox_override("pressed", animated_style)
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		add_theme_color_override("font_color", color_normal)
		
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		pressed.connect(_on_pressed)

func refresh_theme() -> void:
	style_normal = get_theme_stylebox("normal", BUTTON_THEME_TYPE)
	style_hover = get_theme_stylebox("hover", BUTTON_THEME_TYPE)
	style_pressed = get_theme_stylebox("pressed", BUTTON_THEME_TYPE)
	
	color_normal = get_theme_color("font_color", BUTTON_THEME_TYPE)
	color_hover = get_theme_color("font_hover_color", BUTTON_THEME_TYPE)
	color_pressed = get_theme_color("font_pressed_color", BUTTON_THEME_TYPE)
	
	if is_listening:
		_animate_to(style_pressed, color_pressed, 0.1)
	elif is_hovered():
		_animate_to(style_hover, color_hover, 0.1)
	else:
		_animate_to(style_normal, color_normal, 0.1)

func set_key(key: Key) -> void:
	current_key = key
	if key == Key.KEY_NONE:
		text = "[ NONE ]"
	else:
		text = "[ " + OS.get_keycode_string(key).to_upper() + " ]"

func _on_mouse_entered() -> void:
	if not is_listening and style_hover and animated_style:
		_animate_to(style_hover, color_hover)

func _on_mouse_exited() -> void:
	if not is_listening and style_normal and animated_style:
		_animate_to(style_normal, color_normal)

func _on_pressed() -> void:
	if is_listening: return
	
	is_listening = true
	text = "[ PRESS KEY ]"
	
	if style_pressed and animated_style:
		_animate_to(style_pressed, color_pressed, 0.08)

func _input(event: InputEvent) -> void:
	if not is_listening: return
	
	if event is InputEventKey and event.is_pressed():
		var pressed_key = event.keycode
		
		if pressed_key == Key.KEY_ESCAPE:
			set_key(Key.KEY_NONE)
		else:
			set_key(pressed_key)
			
		is_listening = false
		
		get_viewport().set_input_as_handled()
		
		key_assigned.emit(current_key)
		
		if is_hovered() and style_hover:
			_animate_to(style_hover, color_hover, 0.12)
		elif style_normal:
			_animate_to(style_normal, color_normal, 0.12)

func _animate_to(target_style: StyleBoxFlat, target_text_color: Color, duration: float = 0.12) -> void:
	if tween:
		tween.kill()
		
	tween = create_tween().set_parallel(true)
	
	tween.tween_property(animated_style, "bg_color", target_style.bg_color, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_style, "border_color", target_style.border_color, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(animated_style, "border_width_left", target_style.border_width_left, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_style, "border_width_top", target_style.border_width_top, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_style, "border_width_right", target_style.border_width_right, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_style, "border_width_bottom", target_style.border_width_bottom, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(animated_style, "shadow_color", target_style.shadow_color, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_style, "shadow_size", target_style.shadow_size, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(animated_style, "shadow_offset", target_style.shadow_offset, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	var current_text_color = get_theme_color("font_color")
	tween.tween_method(func(c): add_theme_color_override("font_color", c), current_text_color, target_text_color, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
