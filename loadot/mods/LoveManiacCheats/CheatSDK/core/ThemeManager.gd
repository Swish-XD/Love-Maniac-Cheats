class_name ThemeManager
extends RefCounted

var base_theme: Theme
var available_themes: Dictionary = {}
var sdk_ref

var is_loading: bool

func _init(base_path: String) -> void:
	base_theme = load(base_path + "Themes/base.tres") as Theme
	if not base_theme:
		push_error("[ThemeManager] Cant load base.tres at path: " + base_path + "Themes/base.tres")
		return
	
	#available_themes = {
	#	"Dark Default": base_path + "Themes/DarkThemes/DarkDefault.tres",
	#	"Dark Green": base_path + "Themes/DarkThemes/DarkGreen.tres",
	#}
	
	print("[ThemeManager] Initialized. Themes avaiable: ", available_themes.keys())

func set_sdk(sdk) -> void:
	sdk_ref = sdk

func get_theme_names() -> Array[String]:
	var names: Array[String] = []
	names.assign(available_themes.keys())
	return names

func switch_theme(theme_name: String) -> void:
	if is_loading:
		print("[ThemeManager] Warning: Another theme is already loading!")
		return
	
	if not available_themes.has(theme_name):
		print("[ThemeManager] Error: Theme '", theme_name, "' doenst founded!")
		return
	
	is_loading = true
	var path = available_themes[theme_name]
	
	WorkerThreadPool.add_task(_async_load_theme.bind(path, theme_name))

func _async_load_theme(path: String, theme_name: String) -> void:
	var new_preset = load(path) as Theme;
	if not new_preset:
		print("[ThemeManager] Error while loading theme: ", available_themes[theme_name])
		is_loading = false
		return
	
	call_deferred("_apply_theme_on_main_thread", new_preset, theme_name)

func _apply_theme_on_main_thread(new_preset: Theme, theme_name: String) -> void:
	for type_name in base_theme.get_type_list():
		_clear_type(base_theme, type_name)
		
	base_theme.clear()
	base_theme.merge_with(new_preset)
	
	call_deferred("_refresh_all_elements")
	
	is_loading = false
	print("[ThemeManager] Theme switched on: ", theme_name)

func _clear_type(target: Theme, type_name: String) -> void:
	for style_name in target.get_stylebox_list(type_name):
		target.clear_stylebox(style_name, type_name)
	for color_name in target.get_color_list(type_name):
		target.clear_color(color_name, type_name)
	for font_name in target.get_font_list(type_name):
		target.clear_font(font_name, type_name)
	for constant_name in target.get_constant_list(type_name):
		target.clear_constant(constant_name, type_name)

func _refresh_all_elements() -> void:
	if not sdk_ref:
		return
	
	for element_id in sdk_ref.elements:
		var element = sdk_ref.elements[element_id]
		if is_instance_valid(element):
			call_deferred("_refresh_recursive", element)
	
	for tab_id in sdk_ref._all_buttons:
		var btn = sdk_ref._all_buttons[tab_id]
		if is_instance_valid(btn):
			call_deferred("_refresh_recursive", btn)
	
	for cat_id in sdk_ref._categories:
		var container = sdk_ref._categories[cat_id]
		if is_instance_valid(container):
			call_deferred("_refresh_recursive", container)

func _refresh_recursive(node: Control) -> void:
	if node.has_method("refresh_theme"):
		node.call_deferred("refresh_theme")
	
	for child in node.get_children():
		if child is Control:
			call_deferred("_refresh_recursive", child)
