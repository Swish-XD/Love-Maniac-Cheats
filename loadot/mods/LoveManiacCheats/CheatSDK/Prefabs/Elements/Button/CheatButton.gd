extends Button

const BUTTON_THEME_TYPE = "CheatButton"

var animated_style: StyleBoxFlat
var tween: Tween

var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat
var style_pressed: StyleBoxFlat

var color_normal: Color
var color_hover: Color
var color_pressed: Color

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
		button_down.connect(_on_button_down)
		button_up.connect(_on_button_up)

func _on_mouse_entered() -> void:
	if style_hover and animated_style and not is_hovered():
		_animate_to(style_hover, color_hover)

func _on_mouse_exited() -> void:
	if style_normal and animated_style:
		_animate_to(style_normal, color_normal)

func _on_button_down() -> void:
	if style_pressed and animated_style:
		_animate_to(style_pressed, color_pressed, 0.07)

func _on_button_up() -> void:
	if style_hover and animated_style:
		if is_hovered():
			_animate_to(style_hover, color_hover, 0.1)
		else:
			_animate_to(style_normal, color_normal, 0.1)

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
	
	var current_text_color = get_theme_color("font_color")
	tween.tween_method(func(c): add_theme_color_override("font_color", c), current_text_color, target_text_color, duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

static var _empty_focus_style := StyleBoxEmpty.new()

func refresh_theme() -> void:
	style_normal = get_theme_stylebox("normal", BUTTON_THEME_TYPE)
	style_hover = get_theme_stylebox("hover", BUTTON_THEME_TYPE)
	style_pressed = get_theme_stylebox("pressed", BUTTON_THEME_TYPE)
	
	color_normal = get_theme_color("font_color", BUTTON_THEME_TYPE)
	color_hover = get_theme_color("font_hover_color", BUTTON_THEME_TYPE)
	color_pressed = get_theme_color("font_pressed_color", BUTTON_THEME_TYPE)
	
	if not has_theme_stylebox_override("focus"):
		add_theme_stylebox_override("focus", _empty_focus_style)
	
	add_theme_color_override("font_color", color_normal)
	
	if disabled:
		_animate_to(style_normal, color_normal, 0.1)
	elif button_pressed:
		_animate_to(style_pressed, color_pressed, 0.1)
	elif is_hovered():
		_animate_to(style_hover, color_hover, 0.1)
	else:
		_animate_to(style_normal, color_normal, 0.1)
