class_name Main
extends Node

static var instance: Node

const USERNAME = "Swish-XD"
const REPO = "Love-Maniac-Cheats"
const VERSION: String = "2.2.1"

var VERSION_INFO: String = "[color=gray]UPDATING INFO[/color]"

const CHEAT_SDK = preload("res://loadot/mods/LoveManiacCheats/CheatSDK/core/CheatSDK.gd")
const CHARACTERS_HANDLER = preload("res://loadot/mods/LoveManiacCheats/CharactersHandler.gd")
const SCENE_MANAGER = preload("res://loadot/mods/LoveManiacCheats/SceneManager.gd")
const PLAYER_SOUL_HANDLER = preload("res://loadot/mods/LoveManiacCheats/PlayerSoulHandler.gd")
const PLAYER_HANDLER = preload("res://loadot/mods/LoveManiacCheats/PlayerHandler.gd")
const LOGGER = preload("res://loadot/mods/LoveManiacCheats/CheatSDK/core/LoggerHandle.gd")

const CHARACTER_DATABASE = preload("res://loadot/mods/LoveManiacCheats/CharacterDatabase.gd")
const CHARACTER_CONFIG = preload("res://loadot/mods/LoveManiacCheats/CharacterConfig.gd")
const NSFW_SCENE = preload("res://loadot/mods/LoveManiacCheats/NsfwScene.gd")

const CHEAT_INITIALIZER = preload("res://loadot/mods/LoveManiacCheats/CheatsInitializator.gd")

@onready var http_request: HTTPRequest = $HTTPRequest 

var sdk: Node
var char_handle: Node
var scene_manager: Node
var player_soul_handler: Node
var player_handler: Node
var cheat_initializer: RefCounted

var disabled_nebby_cat: bool
var gold_layer_instance: GoldLayer

var logger_instance: Node

func show_critical_error(title: String, message: String) -> void:
	var os_name = OS.get_name()
	var output = []

	match os_name:
		"Windows":
			var safe_message = message.replace("'", "''")
			var safe_title = title.replace("'", "''")
			var script = "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show(([string]'%s'), ([string]'%s'), [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)" % [safe_message, safe_title]
			var args = PackedStringArray(["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script])
			OS.execute("powershell", args, output, false, false)

		"Linux", "FreeBSD":
			var safe_message = message.replace('"', '\\"')
			var safe_title = title.replace('"', '\\"')
			
			var args = PackedStringArray(["--error", "--title=" + safe_title, "--text=" + safe_message])
			var exit_code = OS.execute("zenity", args, output, false, false)
			
			if exit_code < 0:
				var k_args = PackedStringArray(["--title", safe_title, "--error", safe_message])
				OS.execute("kdialog", k_args, output, false, false)

		"macOS":
			var safe_message = message.replace('"', '\\"')
			var safe_title = title.replace('"', '\\"')
			
			var apple_script = 'display dialog "%s" with title "%s" buttons {"OK"} default button "OK" with icon stop' % [safe_message, safe_title]
			var args = PackedStringArray(["-e", apple_script])
			OS.execute("osascript", args, output, false, false)

func set_new_header() -> void:
	sdk.update_title_bar("Love Maniac Cheats [{0} {1}]".format([VERSION, VERSION_INFO]))

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	sdk = CHEAT_SDK.new(get_tree())
	char_handle = CHARACTERS_HANDLER.new(get_tree())
	scene_manager = SCENE_MANAGER.new(get_tree())
	logger_instance = LOGGER.new("Love Maniac")
	
	player_soul_handler = PLAYER_SOUL_HANDLER.new(scene_manager)
	player_handler = PLAYER_HANDLER.new(get_tree(), scene_manager)
	
	cheat_initializer = CHEAT_INITIALIZER.new(self, get_tree())
	
	var initialized: bool = cheat_initializer.build_menu()
	cheat_initializer.initialize_scene_manager()
	
	check_for_updates()
	
	var current_scene = scene_manager.get_current_scene()
	
	if current_scene.name == "Screen":
		var button_path = "res://reutilizable_ui/skip_button.tscn"
		if ResourceLoader.exists(button_path):
			var button_res = load(button_path)
			if button_res:
				var skip_button_instance = button_res.instantiate()
				current_scene.add_child(skip_button_instance)
				skip_button_instance.skip.connect(
					func():
						SceneTransition.change_scene_to_file("res://Scenes/menu_scenes/main_menu/main_menu.tscn", true, true, 0.2, 0.2)
				)
	
	sdk.set_tab_disabled("tab_combat", true)
	sdk.set_tab_disabled("tab_player", true)
	
	if initialized:
		set_new_header()
		logger_instance.log_msg(self, "Cheats UI Initialized", LOGGER.LogType.SUCCESS)
	elif not initialized:
		if cheat_initializer._validate_sdk():
			sdk.show_notification("CRITICAL ERROR", "Follow the instructions on the projects official Github page and submit a ticket on the issues page.")
			logger_instance.log_msg(self, "Follow the instructions on the projects official Github page and submit a ticket on the issues page.", LOGGER.LogType.CRITICAL)
		else:
			logger_instance.log_msg(self, "Follow the instructions on the projects official Github page and submit a ticket on the issues page.", LOGGER.LogType.CRITICAL)
			show_critical_error(
				"CRITICAL ERROR", 
				"Follow the instructions on the projects official Github page and submit a ticket on the issues page."
			)

func cheat_set_took_damage(value: bool) -> void:
	if player_soul_handler and is_instance_valid(player_soul_handler.player):
		player_soul_handler.player.took_damage = value

func check_for_updates() -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_request_completed.bind(http_request))
	var url = "https://api.github.com/repos/%s/%s/releases/latest" % [USERNAME, REPO]
	var headers = ["User-Agent: GodotAutoUpdater"]
	logger_instance.log_msg(self, "Checking for updates...", LOGGER.LogType.INFO)
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET, "")
	if error != OK:
		logger_instance.log_msg(self, "Request initialization error: " + error, LOGGER.LogType.ERROR)
		
func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray, http_node: HTTPRequest) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		logger_instance.log_msg(self, "The request could not be completed.", LOGGER.LogType.ERROR)
		VERSION_INFO = "[color=red]REQUEST ERROR[/color]"
		return
	if response_code != 200:
		logger_instance.log_msg(self, "GitHub returned the response code: %s" % [response_code], LOGGER.LogType.ERROR)
		VERSION_INFO = "[color=red]%s ERROR[/color]" % [response_code]
		return
	var json = JSON.new()
	var parse_err = json.parse(body.get_string_from_utf8())
	
	if parse_err == OK:
		var response = json.get_data()
		var latest_version = response.get("tag_name", "").replace("v", "")
		
		if parse_err == OK:
			response = json.get_data()
			latest_version = response.get("tag_name", "").replace("v", "")
		
			if latest_version != VERSION:
				logger_instance.log_msg(self, "Update available! New version: " + latest_version, LOGGER.LogType.SUCCESS)
				VERSION_INFO = "[color=yellow]OUTDATED[/color]"
			else:
				logger_instance.log_msg(self, "You have the latest version installed.", LOGGER.LogType.SUCCESS)
				VERSION_INFO = "[color=green]LATEST[/color]"
		else:
			logger_instance.log_msg(self, "JSON parsing error.", LOGGER.LogType.ERROR)
			VERSION_INFO = "[color=red]JSON ERROR[/color]"
	
	set_new_header()
	
	if is_instance_valid(http_node):
		http_node.queue_free()

func _init() -> void:
	var current_scene = Engine.get_main_loop().current_scene
	
	if current_scene:
		current_scene.call_deferred("add_child", self)
	else:
		Engine.get_main_loop().root.call_deferred("add_child", self)
