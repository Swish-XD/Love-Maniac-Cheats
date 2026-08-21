class_name CheatSDK
extends Node

signal _window_closed

var _tabs_buttons_container: VBoxContainer
var _tabs_content_container: PanelContainer

var _is_resizing_window: bool = false
var _resize_start_size: Vector2 = Vector2.ZERO
var _resize_start_mouse: Vector2 = Vector2.ZERO

var _canvas_instance: CanvasLayer
var _window_instance: Control
var _content_node: PanelContainer

var _tab_button_prefab: PackedScene
var _tab_content_prefab: PackedScene

var _tabs: Dictionary[String, VBoxContainer] = {} 
var _categories: Dictionary[String, VBoxContainer] = {}
var _all_buttons: Dictionary[String, Button] = {}
var elements: Dictionary[String, Control] = {}

var _hotkey_binds: Dictionary[Key, Callable] = {}

var default_active_tab_id: String

var tree_ref: SceneTree

var canvas_prefab
var window_prefab
var group_prefab
var button_prefab
var checkbox_prefab
var color_picker_prefab
var slider_prefab
var hotkey_prefab
var dropdown_prefab
var input_field_prefab
var header_prefab
var label_prefab
var separator_prefab
var notification_prefab

var _current_tab_id: String

const CONFIG_DIR = "user://configs/"

const DEV_MODE: bool = false

var background_rect
var background_material

var _menu_tween: Tween

var theme_manager_script
var theme_manager

func _init(tree: SceneTree):
	print("[CheatSDK] Started initialization")
	
	tree.root.add_child(self)
	
	tree_ref = tree
	
	var script_path = get_script().resource_path
	var base_folder = script_path.get_base_dir().get_base_dir() + "/"
	
	theme_manager_script = load(base_folder + "core/ThemeManager.gd")
	
	theme_manager = theme_manager_script.new(base_folder)
	theme_manager.set_sdk(self)
	
	canvas_prefab = load(base_folder + "Prefabs/CheatCanvas/CheatCanvas.tscn")
	window_prefab = load(base_folder + "Prefabs/CheatWindow/CheatWindow.tscn")
	group_prefab = load(base_folder + "Prefabs/CollapsibleGroup/CollapsibleGroup.tscn")
	_tab_content_prefab = load(base_folder + "Prefabs/CheatTab/CheatTab.tscn")
	_tab_button_prefab = load(base_folder + "Prefabs/TabButton/MenuTabButton.tscn")
	button_prefab = load(base_folder + "Prefabs/Elements/Button/CheatButton.tscn")
	checkbox_prefab = load(base_folder + "Prefabs/Elements/Checkbox/CheatCheckbox.tscn")
	color_picker_prefab = load(base_folder + "Prefabs/Elements/ColorPicker/CheatColorPicker.tscn")
	slider_prefab = load(base_folder + "Prefabs/Elements/Slider/CheatSlider.tscn")
	hotkey_prefab = load(base_folder + "Prefabs/Elements/Hotkey/CheatHotkey.tscn")
	dropdown_prefab = load(base_folder + "Prefabs/Elements/Dropdown/CheatDropdown.tscn")
	input_field_prefab = load(base_folder + "Prefabs/Elements/InputField/CheatInputField.tscn")
	
	header_prefab = load(base_folder + "Prefabs/Elements/Misc/Header/CheatHeader.tscn")
	label_prefab = load(base_folder + "Prefabs/Elements/Misc/Label/CheatLabel.tscn")
	separator_prefab = load(base_folder + "Prefabs/Elements/Misc/Separator/CheatSeparator.tscn")
	
	notification_prefab = load(base_folder + "Prefabs/Notifications/Notification.tscn")
	
	if not canvas_prefab or not window_prefab or not group_prefab:
		print("[CheatSDK] Unable to find prefabs in: ", base_folder)
		return
	
	_canvas_instance = canvas_prefab.instantiate() as CanvasLayer
	tree.root.add_child(_canvas_instance)
	
	_window_instance = window_prefab.instantiate() as Control
	_canvas_instance.add_child(_window_instance)
	var theme = load(base_folder + "Themes/base.res")
	if not theme:
		theme = load(base_folder + "Themes/base.tres")
	_window_instance.theme = theme
	
	_window_instance.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	
	_content_node = _window_instance.get_node("VBoxContainer/Content") as PanelContainer
	
	_tabs_buttons_container = _content_node.get_node("HBoxContainer/TabButtonContainerPanel/TabButtonContainer") as VBoxContainer
	_tabs_content_container = _content_node.get_node("HBoxContainer/TabContentContainer") as PanelContainer
	
	var resize_grip = Label.new()
	resize_grip.name = "ResizeGrip"
	
	resize_grip.text = "◢"
	
	resize_grip.add_theme_font_size_override("font_size", 10)
	
	var grip_color = Color(1, 1, 1, 0.8)
	resize_grip.add_theme_color_override("font_color", grip_color)
	
	resize_grip.mouse_filter = Control.MOUSE_FILTER_PASS
	
	resize_grip.mouse_default_cursor_shape = Control.CURSOR_FDIAGSIZE
	
	_window_instance.add_child(resize_grip)
	
	resize_grip.anchor_left = 1.0
	resize_grip.anchor_top = 1.0
	resize_grip.anchor_right = 1.0
	resize_grip.anchor_bottom = 1.0
	
	resize_grip.offset_left = -14
	resize_grip.offset_top = -16
	resize_grip.offset_right = 0
	resize_grip.offset_bottom = 0
	
	resize_grip.size_flags_horizontal = Control.SIZE_SHRINK_END
	resize_grip.size_flags_vertical = Control.SIZE_SHRINK_END
	
	background_rect = _window_instance.get_node("ColorRect") as Control
	background_material = background_rect.material as ShaderMaterial
	
	print("[CheatSDK] Successfully initialized dynamically from: ", base_folder)
	
	show_notification("CheatSDK", "Successfully initialized!")
	
	_create_cheat_sdk_tests() 
	_create_customization_tab()

func _input(event: InputEvent) -> void:
	var is_window_open = _window_instance and _window_instance.visible
	
	if is_window_open:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_pressed():
				var mouse_pos = _window_instance.get_local_mouse_position()
				var window_size = _window_instance.size
				
				if mouse_pos.x >= window_size.x - 20.0 and mouse_pos.y >= window_size.y - 20.0:
					_is_resizing_window = true
					_resize_start_size = window_size
					_resize_start_mouse = _window_instance.get_global_mouse_position()
					get_viewport().set_input_as_handled()
			else:
				_is_resizing_window = false
		
		if _is_resizing_window and event is InputEventMouseMotion:
			var current_mouse = _window_instance.get_global_mouse_position()
			var mouse_delta = current_mouse - _resize_start_mouse
			
			var new_size = _resize_start_size + mouse_delta
			new_size.x = clampf(new_size.x, 450.0, 1200.0)
			new_size.y = clampf(new_size.y, 350.0, 900.0)
			
			_window_instance.size = new_size
			_window_instance.pivot_offset = new_size / 2
			get_viewport().set_input_as_handled()
			return
	
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if _hotkey_binds.has(event.keycode):
			_hotkey_binds[event.keycode].call()

func _process(delta: float) -> void:
	if _window_instance and _window_instance.visible:
		if background_material:
			var viewport_size = background_rect.get_viewport().get_visible_rect().size
			var global_mouse_pos = background_rect.get_global_mouse_position()
			
			var mouse_screen_uv = global_mouse_pos / viewport_size
			background_material.set_shader_parameter("mouse_position", mouse_screen_uv)

func update_title_bar(new_title: String) -> void:
	var header: RichTextLabel = _window_instance.find_child("HeaderTitle", true, false)
	if header or is_instance_valid(header):
		header.text = new_title

func toggle_menu() -> void:
	if not _window_instance: return
	if _menu_tween:
		_menu_tween.kill()
		
	_menu_tween = create_tween().set_parallel(true)
	
	_window_instance.pivot_offset = _window_instance.size / 2
	
	if not _window_instance.visible:
		_window_instance.visible = true
		
		_window_instance.scale = Vector2(0.7, 0.7)
		_window_instance.modulate.a = 0.0
		
		_menu_tween.tween_property(_window_instance, "modulate:a", 1.0, 0.25)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)
		
		_menu_tween.tween_property(_window_instance, "scale", Vector2.ONE, 0.35)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)
			
	else:
		_menu_tween.tween_property(_window_instance, "modulate:a", 0.0, 0.15)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)
			
		_menu_tween.tween_property(_window_instance, "scale", Vector2(0.8, 0.8), 0.15)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)
			
		_menu_tween.chain().tween_callback(func():
			_window_instance.visible = false
			_window_closed.emit() 
		)

func _register_element(tab_id: String, element_id: String, element: Control) -> void:
	if element_id != "":
		elements[element_id] = element
	
	if _tabs.has(tab_id):
		_tabs[tab_id].add_child(element)
	else:
		print("[CheatSDK] Error: Doesnt found tab with ID '", 
			tab_id,
			"' for element '", 
			element_id,
			"'")

func get_element_value(element_id: String) -> Variant:
	if not elements.has(element_id):
		return null
		
	var node = elements[element_id]
	if not is_instance_valid(node): 
		return null
	
	if node is CheckBox:
		return node.button_pressed
	elif node is HSlider:
		return node.value
	elif node is OptionButton:
		return node.selected
	elif node is ColorPickerButton:
		return node.color
	elif node is Button and "current_key" in node:
		return node.current_key
	elif node is LineEdit:
		return node.text
	
	return null

func set_element_disabled(element_id: String, is_disabled: bool) -> void:
	if not elements.has(element_id):
		return
		
	var node = elements[element_id]
	if is_instance_valid(node) and "disabled" in node:
		node.disabled = is_disabled
	elif is_instance_valid(node) and "editable" in node:
		node.set_editable(not is_disabled)
	
	if is_instance_valid(node):
		var target_alpha = 0.4 if is_disabled else 1.0
		var tween = create_tween()
		var parent_node = node.get_parent()
		if parent_node is HBoxContainer:
			tween.tween_property(parent_node, "modulate:a", target_alpha, 0.12).set_trans(Tween.TRANS_CUBIC)
		else:
			tween.tween_property(node, "modulate:a", target_alpha, 0.12).set_trans(Tween.TRANS_CUBIC)

func set_element_value(element_id: String, new_value: Variant) -> void:
	if not elements.has(element_id): return
	var node = elements[element_id]
	if not is_instance_valid(node): return
	
	if node is CheckBox and new_value is bool:
		node.button_pressed = new_value
		node.toggled.emit(new_value)
	elif node is HSlider and (new_value is float or new_value is int):
		node.value = new_value
		node.value_changed.emit(new_value)
	elif node is OptionButton and new_value is int:
		node.selected = new_value
		node.item_selected.emit(new_value)
	elif node is ColorPickerButton and new_value is Color:
		node.color = new_value
		node.color_changed.emit(new_value)
	elif node is Button and "current_key" in node and new_value is Key:
		if node.has_method("set_key"):
			node.set_key(new_value)
		node.key_assigned.emit(new_value)
	elif node is LineEdit and new_value is String:
		node.text = new_value
		node.text_changed.emit(new_value)

func add_tab(tab_id: String, tab_name: String) -> VBoxContainer:
	if _tabs.has(tab_id):
		return _tabs[tab_id]
	
	if not _tab_button_prefab or not _tab_content_prefab:
		return null
	
	var btn = _tab_button_prefab.instantiate() as Button
	btn.text = tab_name
	_tabs_buttons_container.add_child(btn)
	_all_buttons[tab_id] = btn
	
	var tab_content = _tab_content_prefab.instantiate() as ScrollContainer
	tab_content.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_tabs_content_container.add_child(tab_content)
	
	if _all_buttons.size() > 1:
		tab_content.visible = false
		
	btn.pressed.connect(func(): _switch_tab(tab_id))
	
	var internal_container = tab_content.get_child(0) as VBoxContainer
	if not internal_container:
		return null
		
	internal_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tabs[tab_id] = internal_container
	
	if _all_buttons.size() == 1:
		btn.button_pressed = true
		_current_tab_id = tab_id
	
	return internal_container

func _switch_tab(tab_id: String) -> void:
	if _current_tab_id == tab_id:
		var button = _all_buttons[_current_tab_id]
		if button: button.button_pressed = true
		return
	
	_current_tab_id = tab_id
	
	for _btn_key in _all_buttons:
		_all_buttons[_btn_key].button_pressed = (_btn_key == tab_id)
	
	for _tab_key in _tabs:
		var scroll_container = _tabs[_tab_key].get_parent() as ScrollContainer
		if scroll_container:
			scroll_container.visible = (_tab_key == tab_id)

func set_tab_disabled(tab_id: String, is_disabled: bool) -> void:
	if _all_buttons.has(tab_id):
		_all_buttons[tab_id].disabled = is_disabled

func add_category(parent_id: String, category_id: String, category_name: String, opened_by_default: bool = false) -> VBoxContainer:
	if _categories.has(category_id):
		return _categories[category_id]
		
	var group = group_prefab.instantiate()
	group.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	group.setup(category_name)
	if opened_by_default == false:
		group._on_header_pressed()
	
	if _tabs.has(parent_id):
		_tabs[parent_id].add_child(group)
	elif _categories.has(parent_id):
		_categories[parent_id].add_child(group)
	else:
		return null
	
	var container = group.get_node("VBoxContainer/ItemsContainer") as VBoxContainer
	_categories[category_id] = container
	return container

func add_button(parent_id: String, button_id: String, action_name: String, callback: Callable, save_to_config: bool = true) -> Button:		
	var btn = button_prefab.instantiate() as Button
	btn.text = action_name
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn.pressed.connect(callback)
	btn.set_meta("save_to_config", save_to_config)
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(btn)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(btn)
	else:
		return null
	
	if button_id != "":
		elements[button_id] = btn
		
	return btn

func add_checkbox(parent_id: String, element_id: String, feature_name: String, default_value: bool, callback: Callable, save_to_config: bool = true) -> CheckBox:
	if not checkbox_prefab:
		return null
	
	var checkbox = checkbox_prefab.instantiate() as CheckBox
	checkbox.text = feature_name
	checkbox.button_pressed = default_value
	checkbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	checkbox.toggled.connect(callback)
	checkbox.toggled.emit(checkbox.button_pressed)
	checkbox.set_meta("save_to_config", save_to_config)
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(checkbox)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(checkbox)
	else:
		checkbox.queue_free()
		return null
	
	if element_id != "":
		elements[element_id] = checkbox
	
	return checkbox

@warning_ignore("unused_parameter")
func add_color_picker(parent_id: String, element_id: String, feature_name: String, default_value: Color, callback: Callable, save_to_config: bool = true) -> ColorPickerButton:
	# TODO: Упростить данный элемент до простых 4 ползунков (rgba) и возможностью предпросмотра. ЗАЧЕМ: СТАНДАРТНЫЙ ПОЛНАЯ ХУЙНЯ ЧЕС СЛОВО Я ЕБАЛ В РОТ ЭТУ ПОЕБОТУ, ЧТО В 1 ВЕРСИИ ЛОМАЛОСЬ ЧТО ТУТ
	if not color_picker_prefab:
		return null
	
	var color_picker = color_picker_prefab.instantiate() as PanelContainer
	var color_picker_label = color_picker.get_node("Container/Label") as Label
	var color_picker_picker = color_picker.get_node("Container/ColorPickerButton") as ColorPickerButton
	color_picker_label.text = feature_name + ":" + " [WIP]"
	color_picker_picker.color = default_value
	color_picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	color_picker_picker.color_changed.connect(callback)
	color_picker_picker.set_meta("save_to_config", save_to_config)
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(color_picker)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(color_picker)
	else:
		color_picker.queue_free()
		return null
	
	if element_id != "":
		elements[element_id] = color_picker_picker
	
	return color_picker_picker

func add_slider(parent_id: String, element_id: String, feature_name: String, min_value: float, max_value, step: float, default_value: float, callback: Callable, save_to_config: bool = true) -> HSlider:
	if not slider_prefab:
		return null
	
	var slider_panel = slider_prefab.instantiate() as PanelContainer
	var slider_label = slider_panel.get_node("HBoxContainer/Label") as Label
	var slider_min_label = slider_panel.get_node("HBoxContainer/SliderContainer/MinValue") as Label
	var slider_slider = slider_panel.get_node("HBoxContainer/SliderContainer/HSlider") as HSlider
	var slider_max_label = slider_panel.get_node("HBoxContainer/SliderContainer/MaxValue") as Label
	slider_label.text = feature_name
	slider_min_label.text = "%s" % [min_value]
	slider_max_label.text = "%s" % [max_value]
	slider_slider.min_value = min_value
	slider_slider.max_value = max_value
	slider_slider.value = default_value
	slider_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider_slider.value_changed.connect(callback)
	slider_slider.set_meta("save_to_config", save_to_config)
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(slider_panel)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(slider_panel)
	else:
		slider_panel.queue_free()
		return null
	
	if element_id != "":
		elements[element_id] = slider_slider
	
	return slider_slider

func add_hotkey(parent_id: String, element_id: String, feature_name: String, default_value: Key, callback: Callable, save_to_config: bool = true) -> Button:
	if not hotkey_prefab:
		return null
	
	var hotkey_panel = hotkey_prefab.instantiate() as PanelContainer
	var hotkey_label = hotkey_panel.get_node("HBoxContainer/Label") as Label
	var hotkey_button = hotkey_panel.get_node("HBoxContainer/Button") as Button
	
	hotkey_label.text = feature_name + ":"
	
	if hotkey_button.has_method("set_key"):
		hotkey_button.set_key(default_value)
	
	if default_value != Key.KEY_NONE:
		_hotkey_binds[default_value] = callback
	
	hotkey_button.key_assigned.connect(func(new_key):
		for old_key in _hotkey_binds.keys():
			if _hotkey_binds[old_key] == callback:
				_hotkey_binds.erase(old_key)
				break
		
		if new_key != KEY_NONE:
			_hotkey_binds[new_key] = callback
		print("[CheatSDK] Bind successfully changed for physically key: ", OS.get_keycode_string(new_key))
	)
	
	hotkey_button.set_meta("save_to_config", save_to_config)
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(hotkey_panel)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(hotkey_panel)
	else:
		hotkey_panel.queue_free()
		return null
	
	if element_id != "":
		elements[element_id] = hotkey_button
	
	return hotkey_button

func add_dropdown(parent_id: String, element_id: String, feature_name, options: Array[String], default_option: int, callback: Callable, save_to_config: bool = true) -> OptionButton:
	if not dropdown_prefab:
		return
	
	var dropdown_panel = dropdown_prefab.instantiate() as PanelContainer
	var dropdown_label = dropdown_panel.get_node("HBoxContainer/Label") as Label
	var dropdown_option = dropdown_panel.get_node("HBoxContainer/OptionButton") as OptionButton
	
	dropdown_label.text = feature_name
	for i in range(options.size()):
		dropdown_option.add_item(options[i], i)
	
	dropdown_option.item_selected.connect(callback)
	dropdown_option.set_meta("save_to_config", save_to_config)
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(dropdown_panel)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(dropdown_panel)
	else:
		dropdown_panel.queue_free()
		return null
	
	if element_id != "":
		elements[element_id] = dropdown_option
	
	return dropdown_option

func add_input_field(parent_id: String, element_id, feature_name, default_value: String, callback: Callable, save_to_config: bool = true) -> LineEdit:
	if not input_field_prefab:
		return
	
	var input_field_panel: PanelContainer = input_field_prefab.instantiate() as PanelContainer
	var input_field_label: Label = input_field_panel.get_node("HBoxContainer/Label") as Label
	var input_field_line_edit: LineEdit = input_field_panel.get_node("HBoxContainer/LineEdit") as LineEdit
	
	input_field_label.text = feature_name + ":"
	input_field_line_edit.set_text(default_value)
	input_field_line_edit.max_length = 999
	
	input_field_line_edit.text_changed.connect(callback)
	input_field_line_edit.set_meta("save_to_config", save_to_config)
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(input_field_panel)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(input_field_panel)
	else:
		input_field_panel.queue_free()
		return null
	
	if element_id != "":
		elements[element_id] = input_field_line_edit
	
	return input_field_line_edit

func add_header(parent_id: String, text: String) -> void:
	if not header_prefab:
		return
	
	var header: RichTextLabel = header_prefab.instantiate() as RichTextLabel
	
	header.text = text
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(header)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(header)
	else:
		header.queue_free()
		return

func add_label(parent_id: String, text: String) -> void:
	if not label_prefab:
		return
	
	var label: Label = label_prefab.instantiate() as Label
	
	label.text = text
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(label)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(label)
	else:
		label.queue_free()
		return

func add_separator(parent_id: String) -> void:
	if not separator_prefab:
		return
	
	var separator: HSeparator = separator_prefab.instantiate() as HSeparator
	
	if _categories.has(parent_id):
		_categories[parent_id].add_child(separator)
	elif _tabs.has(parent_id):
		_tabs[parent_id].add_child(separator)
	else:
		separator.queue_free()
		return

func _create_customization_tab() -> void:
	var tab_id = "cheatsdk_internal_tab_customization"
	add_tab(tab_id, "Customization")
	add_header(tab_id, "[center] === CheatSDK Customization === [/center]")
	add_input_field(tab_id, "inputfield_config_name", "Config name", "default", func(): print("Config new name"), false)
	add_button(tab_id, "btn_save_config", "Save config", func(): save_config(get_element_value("inputfield_config_name")))
	add_button(tab_id, "btn_load_config", "Load config", func(): load_config(get_element_value("inputfield_config_name")))
	add_checkbox(tab_id, "chkbx_auto_save", "Auto save on window close", true, 
		func(value: bool): 
			if value == true and not _window_closed.is_connected(_on_window_closed_autosave):
				_window_closed.connect(_on_window_closed_autosave)
			else:
				_window_closed.disconnect(_on_window_closed_autosave))
	add_dropdown(tab_id, "drpdwn_all_saved_configs", "Saved configs", get_all_configs(), 0, 
		func(value: int):
			var configs = get_all_configs()
			set_element_value("inputfield_config_name", configs[value]), false
	)
	
	add_separator(tab_id)
	
	add_hotkey(tab_id, "htky_window_toggle", "Window toggle", KEY_INSERT, func(): toggle_menu())
	add_category(tab_id, "cat_background_shader", "Background shader settings", false)
	add_checkbox("cat_background_shader", "chkbx_blur_toggle", "Enable blur", true, 
		func(value: bool): 
			background_material.set_shader_parameter("enable_blur", value)
	)
	add_checkbox("cat_background_shader", "chkbx_aberration_toggle", "Enable chromatic aberration", true, 
		func(value: bool): 
			background_material.set_shader_parameter("enable_aberration", value)
	)
	add_checkbox("cat_background_shader", "chkbx_dithering_toggle", "Enable dithering", true, 
		func(value: bool): 
			background_material.set_shader_parameter("enable_dithering", value)
	)
	add_checkbox("cat_background_shader", "chkbx_scanlines_toggle", "Enable scanlines", true, 
		func(value: bool): 
			background_material.set_shader_parameter("enable_scanlines", value)
	)
	add_checkbox("cat_background_shader", "chkbx_zoom_toggle", "Enable zoom", true, 
		func(value: bool): 
			background_material.set_shader_parameter("enable_zoom", value)
	)
	add_checkbox("cat_background_shader", "chkbx_cursor_toggle", "Enable cursor effects", true, 
		func(value: bool): 
			background_material.set_shader_parameter("enable_mouse_effect", value)
	)
	
	#var theme_names = theme_manager.get_theme_names()
	#add_dropdown(tab_id, "drpdwn_theme", "Theme", theme_names, 0, 
	#	func(value: int): 
	#		theme_manager.switch_theme(theme_names[value])
	#)

func _on_window_closed_autosave() -> void:
	var config_name = get_element_value("inputfield_config_name")
	save_config(config_name)

func _create_cheat_sdk_tests() -> void:
	var tab_id = "tab_cheatsdk_tests"
	
	add_tab(tab_id, "Cheat SDK Tests")
	
	add_button(tab_id, "btn_button_tests", "Button", func(): print("Button test successful"))
	add_checkbox(tab_id, "chkbx_checkbox_tests", "Checkbox", false, func(value: bool): print("Checkbox test successful. Value: ", value))
	add_slider(tab_id, "sld_slider_tests", "Slider", 0, 10, 1, 5, func(value: float): print("Slider tests successful. Value: ", value))
	add_dropdown(tab_id, "drpdwn_dropdwon_tests", "Dropdown", ["Test option 1", "Test option 2", "Test option 3", "Test option 4"], 0, func(value: int): print("Dropdown tests successful. Value:", value))
	add_hotkey(tab_id, "htky_hotkey_tests", "Hotkey", KEY_H, func(): print("Hotkey tests successful."))
	add_color_picker(tab_id, "clr_color_tests", "Color Picker", Color.AQUA, func(value: Color): print("Color picker tests successful. Value: ", value))
	add_input_field(tab_id, "inpfld_input_field_tests", "Input Field", "Hello, world!", func(value: String): print("Input field tests successful. Value: ", value))
	
	add_button(tab_id, "btn_get_values_from_elements", "Get elements values",
		func():
			var checkbox_value = get_element_value("chkbx_checkbox_tests")
			var slider_value = get_element_value("sld_slider_tests")
			var dropdown_value = get_element_value("drpdwn_dropdwon_tests")
			var hotkey_value = get_element_value("htky_hotkey_tests")
			var color_value = get_element_value("clr_color_tests")
			
			print("Getted values:")
			print("Checkbox value: ", checkbox_value)
			print("Slider value: ", slider_value)
			print("Dropdown value: ", dropdown_value)
			print("Hotkey value: ", hotkey_value)
			print("Color value: ", color_value)
	)
	
	add_button(tab_id, "btn_set_values_from_elements", "Set elements values",
		func():
			set_element_value("chkbx_checkbox_tests", true)
			set_element_value("sld_slider_tests", 10)
			set_element_value("drpdwn_dropdwon_tests", 3)
			set_element_value("htky_hotkey_tests", KEY_ALT)
			set_element_value("clr_color_tests", Color.RED)
	)
	
	var active_cat_id = "cat_active_elements"
	var disabled_cat_id = "cat_disabled_elements"
	
	add_category(tab_id, active_cat_id, "Active Elements (without callbacks)", false)
	add_category(tab_id, disabled_cat_id, "Disabled Elements (without callbacks)", false)
	
	add_button(active_cat_id, "btn_button_active", "Button", func(): print("Button test successful"))
	add_checkbox(active_cat_id, "chkbx_checkbox_active", "Checkbox", false, func(value: bool): print("Checkbox test successful. Value: ", value))
	add_slider(active_cat_id, "sld_slider_active", "Slider", 0, 10, 1, 5, func(value: float): print("Slider tests successful. Value: ", value))
	add_dropdown(active_cat_id, "drpdwn_dropdwon_active", "Dropdown", ["Test option 1", "Test option 2", "Test option 3", "Test option 4"], 0, func(value: int): print("Dropdown tests successful. Value:", value))
	add_hotkey(active_cat_id, "htky_hotkey_active", "Hotkey", KEY_H, func(): print("Hotkey tests successful."))
	add_color_picker(active_cat_id, "clr_color_active", "Color Picker", Color.AQUA, func(value: Color): print("Color picker tests successful. Value: ", value))
	add_input_field(active_cat_id, "inpfld_input_field_active", "Input Field", "Hello, world!", func(value: String): print("Input field tests successful. Value: ", value))
	add_category(active_cat_id, "cat_enabled", "Category", false)
	
	add_button(disabled_cat_id, "btn_button_disabled", "Button", func(): print("Button test successful"))
	add_checkbox(disabled_cat_id, "chkbx_checkbox_disabled", "Checkbox", false, func(value: bool): print("Checkbox test successful. Value: ", value))
	add_slider(disabled_cat_id, "sld_slider_disabled", "Slider", 0, 10, 1, 5, func(value: float): print("Slider tests successful. Value: ", value))
	add_dropdown(disabled_cat_id, "drpdwn_dropdwon_disabled", "Dropdown", ["Test option 1", "Test option 2", "Test option 3", "Test option 4"], 0, func(value: int): print("Dropdown tests successful. Value:", value))
	add_hotkey(disabled_cat_id, "htky_hotkey_disabled", "Hotkey", KEY_H, func(): print("Hotkey tests successful."))
	add_color_picker(disabled_cat_id, "clr_color_disabled", "Color Picker", Color.AQUA, func(value: Color): print("Color picker tests successful. Value: ", value))
	add_input_field(disabled_cat_id, "inpfld_input_field_disabled", "Input Field", "Hello, world!", func(value: String): print("Input field tests successful. Value: ", value))
	add_category(disabled_cat_id, "cat_disabled", "Category", false)
	
	set_element_disabled("btn_button_disabled", true)
	set_element_disabled("chkbx_checkbox_disabled", true)
	set_element_disabled("sld_slider_disabled", true)
	set_element_disabled("drpdwn_dropdwon_disabled", true)
	set_element_disabled("htky_hotkey_disabled", true)
	set_element_disabled("clr_color_disabled", true)
	set_element_disabled("inpfld_input_field_disabled", true)

func save_config(config_name: String) -> void:
	if config_name.strip_edges() == "": 
		config_name = "default"
	
	if not DirAccess.dir_exists_absolute(CONFIG_DIR):
		DirAccess.make_dir_absolute(CONFIG_DIR)
		
	var config := ConfigFile.new()
	var file_path = CONFIG_DIR + config_name + ".ini"
	
	for element_id in elements:
		var node = elements[element_id]
		if not is_instance_valid(node): continue
		
		if node.has_meta("save_to_config") and not node.get_meta("save_to_config"):
			continue
		
		var value = get_element_value(element_id)
		if value != null:
			config.set_value("Settings", element_id, value)
			
	var err = config.save(file_path)
	if err == OK:
		print("[CheatSDK] Config successfully saved to: ", ProjectSettings.globalize_path(file_path))
	else:
		print("[CheatSDK] Error saving config: ", err)

func load_config(config_name: String) -> void:
	if config_name.strip_edges() == "": 
		config_name = "default"
		
	var config := ConfigFile.new()
	var file_path = CONFIG_DIR + config_name + ".ini"
	
	var err = config.load(file_path)
	if err != OK:
		print("[CheatSDK] Config file not found: ", file_path)
		return
		
	if not config.has_section("Settings"): return
	
	for element_id in config.get_section_keys("Settings"):
		if elements.has(element_id):
			var node = elements[element_id]
			if node.has_meta("save_to_config") and not node.get_meta("save_to_config"):
				continue
			var saved_value = config.get_value("Settings", element_id)
			set_element_value(element_id, saved_value)
			
	print("[CheatSDK] Config '", config_name, "' successfully loaded!")

func get_all_configs() -> Array[String]:
	var list: Array[String] = []
	if not DirAccess.dir_exists_absolute(CONFIG_DIR):
		return list
		
	var dir = DirAccess.open(CONFIG_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".ini"):
				list.append(file_name.get_basename())
			file_name = dir.get_next()
	return list

func show_notification(title_string: String, message_string: String) -> void:
	if not notification_prefab:
		return
	
	var notification: Node = notification_prefab.instantiate() as Node
	
	var notification_container = _canvas_instance.find_child("NotificationContainer", true, false)
	
	if notification_container:
		notification_container.add_child(notification)
	else:
		print("Cannot find notification container")
	
	if notification.has_method("show_notification"):
		notification.show_notification(title_string, message_string)
	else:
		notification.queue_free()
		return
