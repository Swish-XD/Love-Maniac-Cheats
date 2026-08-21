extends PanelContainer

const HEADER_BUTTON_THEME_TYPE = "CheatCollapsibleGroupButton"
const PANEL_THEME_TYPE = "CheatCollapsibleGroupBackground"

@onready var toggle_header: Button
@onready var separator: HSeparator
@onready var items_container: VBoxContainer

var group_title: String = ""
var is_expanded: bool = true

var current_anim_height: float = 0.0
var is_animating: bool = false
var content_tween: Tween

var animated_style: StyleBoxFlat
var hover_tween: Tween
var style_normal: StyleBoxFlat
var style_hover: StyleBoxFlat
var color_normal: Color
var color_hover: Color

func setup(title_text: String) -> void:
	group_title = title_text
	
	toggle_header = get_node("VBoxContainer/ToggleHeader") as Button
	separator = get_node("VBoxContainer/HSeparator") as HSeparator
	items_container = get_node("VBoxContainer/ItemsContainer") as VBoxContainer
	
	clip_contents = true
	
	var vbox = get_node("VBoxContainer") as VBoxContainer
	if vbox:
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	toggle_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	separator.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	items_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	toggle_header.pressed.connect(_on_header_pressed)
	
	_update_header_text()
	_init_button_animation()

func refresh_theme() -> void:
	var current_theme: Theme = toggle_header.theme
	
	if current_theme:
		style_normal = current_theme.get_stylebox("normal", HEADER_BUTTON_THEME_TYPE)
		style_hover = current_theme.get_stylebox("hover", HEADER_BUTTON_THEME_TYPE)
		color_normal = current_theme.get_color("font_color", HEADER_BUTTON_THEME_TYPE)
		color_hover = current_theme.get_color("font_hover_color", HEADER_BUTTON_THEME_TYPE)
	else:
		style_normal = toggle_header.get_theme_stylebox("normal", HEADER_BUTTON_THEME_TYPE)
		style_hover = toggle_header.get_theme_stylebox("hover", HEADER_BUTTON_THEME_TYPE)
		color_normal = toggle_header.get_theme_color("font_color", HEADER_BUTTON_THEME_TYPE)
		color_hover = toggle_header.get_theme_color("font_hover_color", HEADER_BUTTON_THEME_TYPE)
	
	if toggle_header.is_hovered():
		_animate_hover(style_hover, color_hover)
	else:
		_animate_hover(style_normal, color_normal)
	
	queue_redraw()
	
	_refresh_children(items_container)

func _refresh_children(node: Control) -> void:
	for child in node.get_children():
		if child.has_method("refresh_theme"):
			child.refresh_theme()
		if child is Control:
			_refresh_children(child)

func _init_button_animation() -> void:
	style_normal = toggle_header.get_theme_stylebox("normal", HEADER_BUTTON_THEME_TYPE)
	style_hover = toggle_header.get_theme_stylebox("hover", HEADER_BUTTON_THEME_TYPE)
	color_normal = toggle_header.get_theme_color("font_color", HEADER_BUTTON_THEME_TYPE)
	color_hover = toggle_header.get_theme_color("font_hover_color", HEADER_BUTTON_THEME_TYPE)
	
	if style_normal and style_hover:
		animated_style = style_normal.duplicate()
		toggle_header.add_theme_stylebox_override("normal", animated_style)
		toggle_header.add_theme_stylebox_override("hover", animated_style)
		toggle_header.add_theme_stylebox_override("pressed", animated_style)
		toggle_header.add_theme_color_override("font_color", color_normal)
		
		toggle_header.mouse_entered.connect(func(): _animate_hover(style_hover, color_hover))
		toggle_header.mouse_exited.connect(func(): _animate_hover(style_normal, color_normal))

func _process(_delta: float) -> void:
	if is_animating:
		queue_redraw()

func _draw() -> void:
	var box_style = get_theme_stylebox("panel", PANEL_THEME_TYPE) as StyleBoxFlat
	if not box_style: return
	
	var rect_size = size
	if is_animating:
		rect_size.y = current_anim_height
		
	var draw_rect = Rect2(Vector2.ZERO, rect_size)
	draw_style_box(box_style, draw_rect)

func _on_header_pressed() -> void:
	is_expanded = !is_expanded
	_update_header_text()
	_animate_content_reveal()

func _animate_content_reveal() -> void:
	if content_tween:
		content_tween.kill()
		
	is_animating = true
	var start_h = size.y
	content_tween = create_tween().set_parallel(true)
	
	if is_expanded:
		items_container.visible = true
		separator.visible = true
		
		items_container.custom_minimum_size.y = 0
		var target_h = get_combined_minimum_size().y
		
		items_container.custom_minimum_size.y = 0
		items_container.modulate.a = 0.0
		content_tween.tween_property(items_container, "custom_minimum_size:y", target_height_calculation(target_h), 0.2).set_trans(Tween.TRANS_QUAD)
		content_tween.tween_property(items_container, "modulate:a", 1.0, 0.2)
		
		current_anim_height = start_h
		content_tween.tween_property(self, "current_anim_height", target_h, 0.2).set_trans(Tween.TRANS_QUAD)
		
		content_tween.chain().tween_callback(func():
			is_animating = false
			items_container.custom_minimum_size.y = 0
			queue_redraw()
		)
	else:
		items_container.custom_minimum_size.y = items_container.size.y
		var target_h = toggle_header.size.y + 6
		
		content_tween.tween_property(items_container, "custom_minimum_size:y", 0, 0.18).set_trans(Tween.TRANS_QUAD)
		content_tween.tween_property(items_container, "modulate:a", 0.0, 0.15)
		
		current_anim_height = start_h
		content_tween.tween_property(self, "current_anim_height", target_h, 0.18).set_trans(Tween.TRANS_QUAD)
		
		content_tween.chain().tween_callback(func():
			if not is_expanded:
				items_container.visible = false
				separator.visible = false
			is_animating = false
			queue_redraw()
		)

func target_height_calculation(full_tab_h: float) -> float:
	return full_tab_h - toggle_header.size.y - 10

func _update_header_text() -> void:
	if not toggle_header: return
	toggle_header.text = ("↓ " if is_expanded else "→ ") + group_title.to_upper()

func _animate_hover(target_style: StyleBoxFlat, target_text_color: Color) -> void:
	if hover_tween: hover_tween.kill()
	hover_tween = create_tween().set_parallel(true)
	hover_tween.tween_property(animated_style, "bg_color", target_style.bg_color, 0.15)
	hover_tween.tween_property(animated_style, "border_color", target_style.border_color, 0.15)
	var current_color = toggle_header.get_theme_color("font_color")
	hover_tween.tween_method(func(c): toggle_header.add_theme_color_override("font_color", c), current_color, target_text_color, 0.15)
