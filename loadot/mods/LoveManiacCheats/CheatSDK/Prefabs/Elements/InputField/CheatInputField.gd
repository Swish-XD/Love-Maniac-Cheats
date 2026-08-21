extends LineEdit

var is_custom_focused: bool = false
var blink_timer: float = 0.0
var show_caret: bool = false

var cursor_index: int = 0

var is_all_selected: bool = false

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE 
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		is_custom_focused = true
		is_all_selected = false
		
		var font = get_theme_font("font")
		var font_size = get_theme_font_size("font_size")
		var mouse_x = get_local_mouse_position().x - 4
		
		var closest_index = 0
		var min_diff = 99999.0
		
		for i in range(text.length() + 1):
			var sub_str = text.substr(0, i)
			var width = font.get_string_size(sub_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			var diff = abs(width - mouse_x)
			if diff < min_diff:
				min_diff = diff
				closest_index = i
				
		cursor_index = closest_index
		show_caret = true
		blink_timer = 0.0
		queue_redraw()
		accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if not is_custom_focused: return
	
	if event is InputEventKey and event.is_pressed():
		if event.is_echo() and event.keycode != KEY_BACKSPACE: return
		
		var key = event.keycode
		var ctrl = event.ctrl_pressed
		
		if ctrl:
			if key == KEY_A:
				if text.length() > 0:
					is_all_selected = true
					cursor_index = text.length()
					show_caret = true
					queue_redraw()
				get_viewport().set_input_as_handled()
				return
			elif key == KEY_C:
				DisplayServer.clipboard_set(text)
				get_viewport().set_input_as_handled()
				return
			elif key == KEY_V:
				var clipboard = DisplayServer.clipboard_get()
				if clipboard != "":
					if is_all_selected:
						text = clipboard
						cursor_index = clipboard.length()
						is_all_selected = false
					else:
						text = text.substr(0, cursor_index) + clipboard + text.substr(cursor_index)
						cursor_index += clipboard.length()
					text_changed.emit(text)
					queue_redraw()
				get_viewport().set_input_as_handled()
				return
			elif key == KEY_X:
				DisplayServer.clipboard_set(text)
				text = ""
				cursor_index = 0
				is_all_selected = false
				text_changed.emit(text)
				queue_redraw()
				get_viewport().set_input_as_handled()
				return
		
		if key == KEY_ESCAPE or key == KEY_ENTER:
			is_custom_focused = false
			show_caret = false
			is_all_selected = false
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		if key == KEY_LEFT:
			if is_all_selected:
				cursor_index = 0
				is_all_selected = false
			else:
				cursor_index = max(0, cursor_index - 1)
			show_caret = true
			blink_timer = 0.0
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
		elif key == KEY_RIGHT:
			if is_all_selected:
				cursor_index = text.length()
				is_all_selected = false
			else:
				cursor_index = min(text.length(), cursor_index + 1)
			show_caret = true
			blink_timer = 0.0
			queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		if key == KEY_BACKSPACE:
			if is_all_selected:
				text = ""
				cursor_index = 0
				is_all_selected = false
				text_changed.emit(text)
				queue_redraw()
			elif cursor_index > 0:
				text = text.substr(0, cursor_index - 1) + text.substr(cursor_index)
				cursor_index -= 1
				text_changed.emit(text)
				queue_redraw()
			get_viewport().set_input_as_handled()
			return
		elif key == KEY_DELETE:
			if is_all_selected:
				text = ""
				cursor_index = 0
				is_all_selected = false
				text_changed.emit(text)
				queue_redraw()
			elif cursor_index < text.length():
				text = text.substr(0, cursor_index) + text.substr(cursor_index + 1)
				text_changed.emit(text)
				queue_redraw()
			get_viewport().set_input_as_handled()
			return
			
		if event.unicode > 0 and not ctrl:
			if is_all_selected:
				text = ""
				cursor_index = 0
				is_all_selected = false
				
			if text.length() < max_length:
				var character = char(event.unicode)
				text = text.substr(0, cursor_index) + character + text.substr(cursor_index)
				cursor_index += 1
				text_changed.emit(text)
				queue_redraw()
			get_viewport().set_input_as_handled()
			return

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var local_mouse = get_local_mouse_position()
		var rect = Rect2(Vector2.ZERO, size)
		if not rect.has_point(local_mouse):
			is_custom_focused = false
			show_caret = false
			is_all_selected = false
			queue_redraw()

	if is_custom_focused:
		blink_timer += delta
		if blink_timer >= 0.5:
			blink_timer = 0.0
			show_caret = !show_caret
			queue_redraw()
	elif show_caret:
		show_caret = false
		queue_redraw()

func _draw() -> void:
	var font = get_theme_font("font")
	var font_size = get_theme_font_size("font_size")
	
	if is_all_selected and text.length() > 0:
		var total_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var selection_rect = Rect2(Vector2(4, 4), Vector2(total_width, size.y - 8))
		draw_rect(selection_rect, Color(0.1, 0.4, 0.8, 0.5), true)
		
	if is_custom_focused and show_caret:
		var sub_str = text.substr(0, cursor_index)
		var text_width = font.get_string_size(sub_str, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		
		var caret_x = text_width + 4
		var caret_height = size.y - 8
		draw_line(Vector2(caret_x, 4), Vector2(caret_x, 4 + caret_height), Color.WHITE, 2.0)
