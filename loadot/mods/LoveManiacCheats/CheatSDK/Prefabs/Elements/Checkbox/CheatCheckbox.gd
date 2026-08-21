extends CheckBox

const CHECKBOX_THEME_TYPE = "CheatCheckbox"

var animated_style
var tween: Tween

var style_normal
var style_hover
var style_pressed
var style_checked

var color_normal: Color
var color_hover: Color
var color_pressed: Color

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	clip_contents = true
	
	var raw_normal = get_theme_stylebox("normal", CHECKBOX_THEME_TYPE)
	style_normal = raw_normal if raw_normal is StyleBoxFlat else StyleBoxFlat.new()
	
	var raw_hover = get_theme_stylebox("hover", CHECKBOX_THEME_TYPE)
	style_hover = raw_hover if raw_hover is StyleBoxFlat else StyleBoxFlat.new()
	
	var raw_pressed = get_theme_stylebox("pressed", CHECKBOX_THEME_TYPE)
	style_pressed = raw_pressed if raw_pressed is StyleBoxFlat else StyleBoxFlat.new()
	
	if has_theme_stylebox("checked", CHECKBOX_THEME_TYPE):
		var raw_checked = get_theme_stylebox("checked", CHECKBOX_THEME_TYPE)
		style_checked = raw_checked if raw_checked is StyleBoxFlat else style_hover
	else:
		style_checked = style_hover
	
	color_normal = get_theme_color("font_color", CHECKBOX_THEME_TYPE)
	color_hover = get_theme_color("font_hover_color", CHECKBOX_THEME_TYPE)
	color_pressed = get_theme_color("font_pressed_color", CHECKBOX_THEME_TYPE)
	
	if style_normal and style_hover:
		animated_style = style_normal.duplicate()
		
		add_theme_stylebox_override("normal", animated_style)
		add_theme_stylebox_override("hover", animated_style)
		add_theme_stylebox_override("pressed", animated_style)
		
		add_theme_stylebox_override("checked", animated_style)
		add_theme_stylebox_override("hover_pressed", animated_style)
		add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		
		if button_pressed:
			animated_style.bg_color = style_checked.bg_color
			animated_style.border_color = style_checked.border_color
			add_theme_color_override("font_color", color_pressed)
		else:
			add_theme_color_override("font_color", color_normal)
		
		mouse_entered.connect(_on_mouse_entered)
		mouse_exited.connect(_on_mouse_exited)
		button_down.connect(_on_button_down)
		button_up.connect(_on_button_up)
		toggled.connect(_on_toggled)

func refresh_theme() -> void:
	var raw_normal = get_theme_stylebox("normal", CHECKBOX_THEME_TYPE)
	style_normal = raw_normal if raw_normal is StyleBoxFlat else StyleBoxFlat.new()
	
	var raw_hover = get_theme_stylebox("hover", CHECKBOX_THEME_TYPE)
	style_hover = raw_hover if raw_hover is StyleBoxFlat else StyleBoxFlat.new()
	
	var raw_pressed = get_theme_stylebox("pressed", CHECKBOX_THEME_TYPE)
	style_pressed = raw_pressed if raw_pressed is StyleBoxFlat else StyleBoxFlat.new()
	
	if has_theme_stylebox("checked", CHECKBOX_THEME_TYPE):
		var raw_checked = get_theme_stylebox("checked", CHECKBOX_THEME_TYPE)
		style_checked = raw_checked if raw_checked is StyleBoxFlat else style_hover
	else:
		style_checked = style_hover
	
	color_normal = get_theme_color("font_color", CHECKBOX_THEME_TYPE)
	color_hover = get_theme_color("font_hover_color", CHECKBOX_THEME_TYPE)
	color_pressed = get_theme_color("font_pressed_color", CHECKBOX_THEME_TYPE)
	
	if button_pressed:
		_animate_to(style_checked, color_pressed, 0.1)
	elif is_hovered():
		_animate_to(style_hover, color_hover, 0.1)
	else:
		_animate_to(style_normal, color_normal, 0.1)

func _on_mouse_entered() -> void:
	if not button_pressed and style_hover and animated_style:
		_animate_to(style_hover, color_hover)

func _on_mouse_exited() -> void:
	if animated_style:
		if button_pressed:
			_animate_to(style_checked, color_pressed)
		else:
			_animate_to(style_normal, color_normal)

func _on_button_down() -> void:
	if style_pressed and animated_style:
		_animate_to(style_pressed, color_pressed, 0.07)

func _on_button_up() -> void:
	if animated_style:
		if button_pressed:
			_animate_to(style_checked, color_pressed, 0.1)
		else:
			_animate_to(style_hover, color_hover, 0.1)

func _on_toggled(is_checked: bool) -> void:
	if animated_style:
		if is_checked:
			_animate_to(style_checked, color_pressed, 0.15)
		else:
			_animate_to(style_normal, color_normal, 0.15)

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
