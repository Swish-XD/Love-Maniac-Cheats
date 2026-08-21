class_name CheatsInitializator
extends RefCounted

const LOGGER = preload("res://loadot/mods/LoveManiacCheats/CheatSDK/core/LoggerHandle.gd")

const CHARACTERS_HANDLER = preload("res://loadot/mods/LoveManiacCheats/CharactersHandler.gd")
const SCENE_MANAGER = preload("res://loadot/mods/LoveManiacCheats/SceneManager.gd")
const PLAYER_SOUL_HANDLER = preload("res://loadot/mods/LoveManiacCheats/PlayerSoulHandler.gd")
const PLAYER_HANDLER = preload("res://loadot/mods/LoveManiacCheats/PlayerHandler.gd")

const CHARACTER_DATABASE = preload("res://loadot/mods/LoveManiacCheats/CharacterDatabase.gd")
const CHARACTER_CONFIG = preload("res://loadot/mods/LoveManiacCheats/CharacterConfig.gd")
const NSFW_SCENE = preload("res://loadot/mods/LoveManiacCheats/NsfwScene.gd")

var logger_instance: Node
var tree_ref: SceneTree

var sdk: Node
var char_handle: Node
var scene_manager: Node
var player_soul_handler: Node
var player_handler: Node

var _cached_battle_db: Dictionary = {}
var _cached_non_battle_db: Dictionary = {}
var _traversal_stack: Array[Node] = []

func _init(main_instance: Node, tree: SceneTree):
	logger_instance = LOGGER.new("Love Maniac")

	if logger_instance == null or not is_instance_valid(logger_instance):
		return

	if main_instance == null or not is_instance_valid(main_instance):
		logger_instance.log_msg(
			self,
			"Initialization failed: main_instance is null or invalid.",
			LOGGER.LogType.CRITICAL
		)
		return

	if tree == null or not is_instance_valid(tree):
		logger_instance.log_msg(
			self,
			"Initialization failed: SceneTree reference is null or invalid.",
			LOGGER.LogType.CRITICAL
		)
		return

	tree_ref = tree

	sdk = main_instance.get("sdk")
	char_handle = main_instance.get("char_handle")
	scene_manager = main_instance.get("scene_manager")
	player_soul_handler = main_instance.get("player_soul_handler")
	player_handler = main_instance.get("player_handler")

	_validate_dependency(sdk, "CheatSDK")
	_validate_dependency(char_handle, "CharactersHandler")
	_validate_dependency(scene_manager, "SceneManager")
	_validate_dependency(player_soul_handler, "PlayerSoulHandler")
	_validate_dependency(player_handler, "PlayerHandler")

	_dev_log("CheatsInitializator dependencies have been resolved.")
	
	_cached_battle_db = CHARACTER_DATABASE.get_battle_characters_database()
	_cached_non_battle_db = CHARACTER_DATABASE.get_non_battle_characters_database()

# ==================================================
# LOGGING / VALIDATION
# ==================================================

func _dev_log(message: String, type: LOGGER.LogType = LOGGER.LogType.INFO) -> void:
	if logger_instance == null or not is_instance_valid(logger_instance):
		return

	if sdk == null or not is_instance_valid(sdk):
		return

	if not sdk.DEV_MODE:
		return

	logger_instance.log_msg(self, message, type)

func _validate_dependency(target: Variant, dependency_name: String, log_success: bool = false) -> bool:
	if target == null:
		logger_instance.log_msg(
			self,
			"%s reference is null." % dependency_name,
			LOGGER.LogType.CRITICAL
		)
		return false

	if typeof(target) == TYPE_OBJECT and not is_instance_valid(target):
		logger_instance.log_msg(
			self,
			"%s reference is no longer valid." % dependency_name,
			LOGGER.LogType.CRITICAL
		)
		return false

	if log_success:
		_dev_log(
			"%s reference validated successfully." % dependency_name,
			LOGGER.LogType.SUCCESS
		)

	return true

func _validate_sdk() -> bool:
	return _validate_dependency(sdk, "CheatSDK", false)

func _validate_tree() -> bool:
	if tree_ref == null:
		logger_instance.log_msg(
			self,
			"SceneTree reference is null.",
			LOGGER.LogType.ERROR
		)
		return false

	if not is_instance_valid(tree_ref):
		logger_instance.log_msg(
			self,
			"SceneTree reference is invalid.",
			LOGGER.LogType.ERROR
		)
		return false

	if tree_ref.root == null or not is_instance_valid(tree_ref.root):
		logger_instance.log_msg(
			self,
			"SceneTree root node is unavailable.",
			LOGGER.LogType.ERROR
		)
		return false

	return true

# ==================================================
# INITIALIZATION
# ==================================================

func build_menu() -> bool:
	if not _validate_sdk():
		return false

	logger_instance.log_msg(self, "Starting cheat menu initialization.", LOGGER.LogType.INFO)

	var results: Dictionary = {}

	results["Tabs"] = build_tabs()
	results["Scenes"] = build_scenes()
	results["Visuals"] = build_visuals()
	results["Player Combat"] = build_player_combat()
	results["Exploits"] = build_exploits_tab()
	results["Inventory"] = build_inventory()
	results["Save Manipulation"] = build_save_manipulation()
	results["Battle Characters Manipulation"] = build_battle_characters_manipulation()

	var successful: int = 0
	var failed: int = 0

	for component_name in results:
		if results[component_name]:
			successful += 1
			_dev_log(
				"Initialization succeeded: %s." % component_name,
				LOGGER.LogType.SUCCESS
			)
		else:
			failed += 1
			logger_instance.log_msg(
				self,
				"Initialization failed: %s." % component_name,
				LOGGER.LogType.ERROR
			)

	logger_instance.log_msg(
		self,
		"Cheat menu initialization completed. Successful: %d/%d, Failed: %d." % [successful, results.size(), failed],
		LOGGER.LogType.SUCCESS if failed == 0 else LOGGER.LogType.WARN)

	return failed == 0

# ==================================================
# TABS
# ==================================================

func build_tabs() -> bool:
	if not _validate_sdk():
		return false

	_dev_log("Creating main menu tabs.")

	sdk.add_tab("tab_combat", "Combat")
	sdk.add_tab("tab_save_manipulation", "Save Manipulation")
	sdk.add_tab("tab_inventory", "Inventory")
	sdk.add_tab("tab_exploits", "Exploits")
	sdk.add_tab("tab_player", "Player")
	sdk.add_tab("tab_visuals", "Visuals")
	sdk.add_tab("tab_scenes", "Scenes")

	logger_instance.log_msg(
		self,
		"Main menu tabs created successfully.",
		LOGGER.LogType.SUCCESS
	)

	return true

# ==================================================
# SCENES
# ==================================================

func build_scenes() -> bool:
	if not _validate_sdk():
		return false

	const scenes_path := "res://Scenes"

	if not DirAccess.dir_exists_absolute(scenes_path):
		logger_instance.log_msg(
			self,
			"Scenes directory does not exist: %s." % scenes_path,
			LOGGER.LogType.ERROR
		)
		return false

	sdk.add_header(
		"tab_scenes",
		"[center][b]Some scenes may crash the game.[/b][/center]"
	)

	var result := _scan_and_build_scene_ui(scenes_path, "tab_scenes")

	if result:
		logger_instance.log_msg(
			self,
			"Scene browser initialized successfully.",
			LOGGER.LogType.SUCCESS
		)

	return result

func _scan_and_build_scene_ui(dir_path: String, parent_category_id: String) -> bool:
	if not _validate_sdk():
		return false

	if dir_path.is_empty():
		logger_instance.log_msg(
			self,
			"Cannot scan scenes: directory path is empty.",
			LOGGER.LogType.ERROR
		)
		return false

	if parent_category_id.is_empty():
		logger_instance.log_msg(
			self,
			"Cannot scan scenes: parent category ID is empty.",
			LOGGER.LogType.ERROR
		)
		return false

	var dir := DirAccess.open(dir_path)

	if dir == null:
		logger_instance.log_msg(
			self,
			"Failed to open scene directory: %s." % dir_path,
			LOGGER.LogType.ERROR
		)
		return false

	dir.list_dir_begin()

	var file_name := dir.get_next()
	var success := true

	while file_name != "":
		if file_name == "." or file_name == "..":
			file_name = dir.get_next()
			continue

		var full_path := dir_path.path_join(file_name)

		if dir.current_is_dir():
			if has_scenes_recursive(full_path):
				var new_category_id := "cat_scene_%s" % full_path.hash()
				var category_name := file_name.capitalize()

				if category_name.is_empty():
					logger_instance.log_msg(
						self,
						"Skipping scene directory with an empty name: %s." % full_path,
						LOGGER.LogType.WARN
					)
					file_name = dir.get_next()
					continue

				sdk.add_category(
					parent_category_id,
					new_category_id,
					category_name
				)

				if not _scan_and_build_scene_ui(
					full_path,
					new_category_id
				):
					success = false
			else:
				_dev_log(
					"Skipping empty scene folder: %s." % file_name
				)

		elif (
			file_name.ends_with(".tscn")
			or file_name.ends_with(".scn")
			or file_name.ends_with(".remap")
		):
			var clean_scene_name := file_name \
				.replace(".tscn", "") \
				.replace(".scn", "") \
				.replace(".remap", "") \
				.capitalize()

			var target_scene_file := full_path.replace(".remap", "")
			var button_id := "btn_teleport_%s" % target_scene_file.hash()

			if not FileAccess.file_exists(target_scene_file):
				_dev_log(
					"Scene file does not currently exist after remap resolution: %s." %
					target_scene_file,
					LOGGER.LogType.WARN
				)
			else:
				sdk.add_button(
					parent_category_id,
					button_id,
					"Load: " + clean_scene_name,
					func():
						if not FileAccess.file_exists(target_scene_file):
							logger_instance.log_msg(
								self,
								"Scene file no longer exists: %s." %
								target_scene_file,
								LOGGER.LogType.ERROR
							)
							return

						logger_instance.log_msg(
							self,
							"Executing force warp to scene: %s." %
							target_scene_file,
							LOGGER.LogType.INFO
						)

						SceneTransition.change_scene_to_file(
							target_scene_file,
							true,
							true,
							0.2,
							0.2
						)
				)

		file_name = dir.get_next()

	dir.list_dir_end()

	return success

# ==================================================
# VISUALS
# ==================================================

func build_visuals() -> bool:
	if not _validate_sdk():
		return false

	if not _validate_tree():
		return false

	sdk.add_checkbox(
		"tab_visuals",
		"chkbx_collisions",
		"Toggle collisions",
		false,
		func(value: bool):
			if not _validate_tree():
				return
	
			tree_ref.debug_collisions_hint = value
	
			_traversal_stack.clear()
			_traversal_stack.append(tree_ref.root)
	
			while not _traversal_stack.is_empty():
				var current: Node = _traversal_stack.pop_back()
		
				if current == null or not is_instance_valid(current):
					continue
		
				if current is CollisionShape2D or current is CollisionPolygon2D:
					current.queue_redraw()
				elif current is TileMapLayer:
					if value:
						current.collision_visibility_mode = TileMapLayer.DEBUG_VISIBILITY_MODE_FORCE_SHOW
					else:
						current.collision_visibility_mode = TileMapLayer.DEBUG_VISIBILITY_MODE_FORCE_HIDE
		
				for child in current.get_children():
					_traversal_stack.append(child))

	sdk.add_hotkey(
		"tab_visuals",
		"hotkey_toggle_collisions",
		"Toggle Collision Hotkey",
		KEY_H,
		func():
			if not _validate_sdk():
				return

			var checkbox_value = sdk.get_element_value("chkbx_collisions")

			if typeof(checkbox_value) != TYPE_BOOL:
				logger_instance.log_msg(
					self,
					"Collision checkbox returned an invalid value.",
					LOGGER.LogType.ERROR
				)
				return

			sdk.set_element_value(
				"chkbx_collisions",
				not checkbox_value
			)
	)

	logger_instance.log_msg(
		self,
		"Visuals controls initialized successfully.",
		LOGGER.LogType.SUCCESS
	)

	return true

# ==================================================
# PLAYER COMBAT
# ==================================================

func build_player_combat() -> bool:
	if not _validate_sdk():
		return false

	if not _validate_dependency(
		player_soul_handler,
		"PlayerSoulHandler"
	):
		return false
	
	sdk.add_header("tab_combat", "[center][b]PLAYER CHEATS[/b][/center]")
	
	sdk.add_category(
		"tab_combat",
		"cat_player",
		"Player Combat Cheats"
	)

	sdk.add_checkbox(
		"cat_player",
		"chk_god",
		"God Mode",
		false,
		player_soul_handler.god_mode_toggle,
		true
	)

	sdk.add_button(
		"cat_player",
		"btn_damage",
		"Damage Player",
		player_soul_handler.damage_player
	)

	sdk.add_button(
		"cat_player",
		"btn_heal",
		"Heal Player",
		player_soul_handler.heal_player
	)

	sdk.add_slider(
		"cat_player",
		"sld_damageMultiplier",
		"Damage Multiplier",
		0.5,
		10.0,
		1.0,
		1.0,
		player_soul_handler.set_damage_changed
	)

	sdk.add_checkbox(
		"cat_player",
		"chk_pills_consumed",
		"Strange Pills Effect",
		false,
		func(value: bool):
			if not is_instance_valid(PillManager):
				logger_instance.log_msg(
					self,
					"Cannot update pill state because PillManager is invalid.",
					LOGGER.LogType.ERROR
				)
				return

			PillManager.pill_consumed = value,
		true
	)

	logger_instance.log_msg(
		self,
		"Player combat controls initialized successfully.",
		LOGGER.LogType.SUCCESS
	)

	return true

# ==================================================
# EXPLOITS
# ==================================================

func build_exploits_tab() -> bool:
	if not _validate_sdk():
		return false

	sdk.add_slider(
		"tab_exploits",
		"sldr_speedhack",
		"Game Speed Multiplier",
		0.1,
		5.0,
		0.1,
		1,
		func(value: float):
			if not is_finite(value):
				logger_instance.log_msg(
					self,
					"Received invalid game speed multiplier.",
					LOGGER.LogType.ERROR
				)
				return

			Engine.time_scale = value
	)

	sdk.add_button(
		"tab_exploits",
		"btn_add_gold",
		"Add 5000 Gold",
		func():
			var gold_saved = SaveManager.get_gold()

			if typeof(gold_saved) not in [TYPE_INT, TYPE_FLOAT]:
				logger_instance.log_msg(
					self,
					"SaveManager returned an invalid gold value.",
					LOGGER.LogType.ERROR
				)
				return

			SaveManager.save_gold(gold_saved + 5000)
	)

	sdk.add_button(
		"tab_exploits",
		"btn_unlock_all_cats",
		"Unlock all Nebby Cats",
		func():
			var cat_ids: Array[StringName] = [
				&"new_chara_room_cat_1",
				&"bed_room_cat_1",
				&"hall_room_cat_1",
				&"lounge_room_cat_1"
			]

			for cat_id in cat_ids:
				SaveManager.save_nebby_cat(cat_id)

			SaveManager.save_all()

			logger_instance.log_msg(
				self,
				"All Nebby Cats successfully added to save file!",
				LOGGER.LogType.SUCCESS
			)
	)

	sdk.add_checkbox(
		"tab_exploits",
		"chkbx_toggle_nebby_cat",
		"Disable nebby cat",
		false,
		func(value: bool):
			logger_instance.log_msg(
				self,
				"Shop Nebby Cat toggled: %s." % value,
				LOGGER.LogType.SUCCESS
			),
		true
	)

	logger_instance.log_msg(
		self,
		"Exploits tab initialized successfully.",
		LOGGER.LogType.SUCCESS
	)

	return true

# ==================================================
# INVENTORY
# ==================================================

func build_inventory() -> bool:
	if not _validate_sdk():
		return false

	var items_array: Array = load_all_items()

	if items_array.is_empty():
		logger_instance.log_msg(
			self,
			"No inventory items were loaded.",
			LOGGER.LogType.WARN
		)
		return true

	for item in items_array:
		if item == null:
			logger_instance.log_msg(
				self,
				"Encountered null inventory item. Skipping.",
				LOGGER.LogType.WARN
			)
			continue

		if not "id" in item:
			logger_instance.log_msg(
				self,
				"Inventory item does not contain an 'id' property. Skipping.",
				LOGGER.LogType.ERROR
			)
			continue

		var item_id = item.id

		if item_id.is_empty():
			logger_instance.log_msg(
				self,
				"Inventory item has an empty ID. Skipping.",
				LOGGER.LogType.ERROR
			)
			continue

		var item_name = item_id.capitalize()
		var button_id = StringName("btn_give_" + item_id)
		var button_text = "Give " + item_name

		_dev_log(
			"Creating inventory control for item: %s." % item_id
		)

		sdk.add_button(
			"tab_inventory",
			button_id,
			button_text,
			_give_item.bind(item)
		)

		_dev_log(
			"Inventory control created successfully for: %s." % item_id,
			LOGGER.LogType.SUCCESS
		)

	logger_instance.log_msg(
		self,
		"Inventory controls initialized successfully. Loaded items: %d." % items_array.size(),
		LOGGER.LogType.SUCCESS
	)
	
	return true

func _give_item(item) -> void:
	if SaveManager.slot_data == null:
		logger_instance.log_msg(
			self,
			"Cannot give item because SaveManager.slot_data is null.",
			LOGGER.LogType.ERROR
		)
		return

	if not "inventory_items" in SaveManager.slot_data:
		logger_instance.log_msg(
			self,
			"Cannot give item because inventory_items is unavailable.",
			LOGGER.LogType.ERROR
		)
		return

	SaveManager.slot_data.inventory_items.append(item)

# ==================================================
# SAVE MANIPULATION
# ==================================================

func build_save_manipulation() -> bool:
	if not _validate_sdk():
		return false

	if _cached_battle_db == null:
		logger_instance.log_msg(
			self,
			"Battle characters database is null.",
			LOGGER.LogType.ERROR
		)
		return false

	if _cached_non_battle_db == null:
		logger_instance.log_msg(
			self,
			"Non-battle characters database is null.",
			LOGGER.LogType.ERROR
		)
		return false

	sdk.add_category(
		"tab_save_manipulation",
		"cat_battle_characters",
		"Battle Characters"
	)

	for battle_character_key in _cached_battle_db:
		var character_config = _cached_battle_db[battle_character_key]

		if character_config == null:
			logger_instance.log_msg(
				self,
				"Character '%s' has a null configuration. Skipping." %
				battle_character_key,
				LOGGER.LogType.ERROR
			)
			continue

		if not is_instance_valid(character_config):
			logger_instance.log_msg(
				self,
				"Character '%s' has an invalid configuration. Skipping." %
				battle_character_key,
				LOGGER.LogType.ERROR
			)
			continue

		if character_config.id.is_empty():
			logger_instance.log_msg(
				self,
				"Character '%s' has an empty ID. Skipping." %
				battle_character_key,
				LOGGER.LogType.ERROR
			)
			continue

		_dev_log(
			"Creating save manipulation UI for: %s." %
			battle_character_key
		)

		var category_id = "save_manipulation_cat_" + character_config.id

		sdk.add_category(
			"cat_battle_characters",
			category_id,
			character_config.id.capitalize()
		)

		if character_config.scenes_id == null:
			logger_instance.log_msg(
				self,
				"Character '%s' has a null scenes_id array." %
				character_config.id,
				LOGGER.LogType.ERROR
			)
		elif not character_config.scenes_id.is_empty() and \
				character_config.scenes_id[0] != "None":

			var scenes_category_id = "cat_scenes_" + character_config.id

			sdk.add_category(
				category_id,
				scenes_category_id,
				"Scenes"
			)

			for character_scene_id in character_config.scenes_id:
				if character_scene_id.is_empty():
					logger_instance.log_msg(
						self,
						"Character '%s' contains an empty scene ID. Skipping." %
						character_config.id,
						LOGGER.LogType.WARN
					)
					continue

				var scene_id = character_scene_id

				sdk.add_button(
					scenes_category_id,
					"btn_unlock_" + scene_id,
					"Unlock " + scene_id.capitalize(),
					_unlock_scene.bind(scene_id)
				)

		if character_config.suits_id == null:
			logger_instance.log_msg(
				self,
				"Character '%s' has a null suits_id array." %
				character_config.id,
				LOGGER.LogType.ERROR
			)
		elif not character_config.suits_id.is_empty() and \
				character_config.suits_id[0] != "None":

			var costumes_category_id = \
				"save_manipulation_cat_costumes_" + character_config.id

			sdk.add_category(
				category_id,
				costumes_category_id,
				"Costumes"
			)

			for character_suit_id in character_config.suits_id:
				if character_suit_id.is_empty():
					logger_instance.log_msg(
						self,
						"Character '%s' contains an empty costume ID. Skipping." %
						character_config.id,
						LOGGER.LogType.WARN
					)
					continue

				var suit_id = character_suit_id

				sdk.add_button(
					costumes_category_id,
					"btn_unlock_" + suit_id,
					"Unlock " + suit_id.capitalize(),
					_unlock_costume.bind(suit_id)
				)

		if character_config.battles == null:
			logger_instance.log_msg(
				self,
				"Character '%s' has a null battles array." %
				character_config.id,
				LOGGER.LogType.ERROR
			)
		elif not character_config.battles.is_empty() and \
				character_config.battles[0] != "None":

			var battles_category_id = \
				"save_manipulation_cat_battles_" + character_config.id

			sdk.add_category(
				category_id,
				battles_category_id,
				"Battles"
			)

			for character_battle_id in character_config.battles:
				if character_battle_id.is_empty():
					logger_instance.log_msg(
						self,
						"Character '%s' contains an empty battle ID. Skipping." %
						character_config.id,
						LOGGER.LogType.WARN
					)
					continue

				var battle_id = character_battle_id

				sdk.add_button(
					battles_category_id,
					"btn_unlock_" + battle_id,
					"Unlock " + battle_id.capitalize(),
					_unlock_battle.bind(battle_id)
				)

		_dev_log(
			"Save manipulation UI created successfully for: %s." %
			battle_character_key,
			LOGGER.LogType.SUCCESS
		)

	sdk.add_category(
		"tab_save_manipulation",
		"cat_non_battle_characters",
		"Non-Battle Characters"
	)

	for non_battle_character_key in _cached_non_battle_db:
		var category_id = \
			"save_manipulation_cat_" + non_battle_character_key.to_lower()

		sdk.add_category(
			"cat_non_battle_characters",
			category_id,
			non_battle_character_key.capitalize()
		)

		var scenes_array = _cached_non_battle_db[
			non_battle_character_key
		]

		if scenes_array == null:
			logger_instance.log_msg(
				self,
				"Non-battle character '%s' has a null scenes array." %
				non_battle_character_key,
				LOGGER.LogType.ERROR
			)
			continue

		if scenes_array.is_empty():
			_dev_log(
				"Non-battle character '%s' has no scenes." %
				non_battle_character_key
			)
			continue

		if scenes_array[0] != "None":
			var scenes_category_id = \
				"save_manipulation_cat_scenes_" + category_id

			sdk.add_category(
				category_id,
				scenes_category_id,
				"Scenes"
			)

			for scene_id_value in scenes_array:
				var scene_id = scene_id_value

				if scene_id.is_empty():
					logger_instance.log_msg(
						self,
						"Non-battle character '%s' contains an empty scene ID." %
						non_battle_character_key,
						LOGGER.LogType.WARN
					)
					continue

				sdk.add_button(
					scenes_category_id,
					"btn_unlock_" + scene_id,
					"Unlock " + scene_id.capitalize(),
					_unlock_scene.bind(scene_id)
				)

	logger_instance.log_msg(
		self,
		"Save manipulation controls initialized successfully.",
		LOGGER.LogType.SUCCESS
	)

	return true

func _unlock_scene(scene_id: String) -> void:
	SaveManager.unlock_scene(scene_id, false)
	SaveManager.unlock_scene_second_round(scene_id)

func _unlock_costume(suit_id: String) -> void:
	SaveManager.unlock_costume(suit_id)

func _unlock_battle(battle_id: String) -> void:
	SaveManager.unlock_battle(battle_id)

# ==================================================
# BATTLE CHARACTER MANIPULATION
# ==================================================

func build_battle_characters_manipulation() -> bool:
	if not _validate_sdk():
		return false

	if not _validate_dependency(char_handle, "CharactersHandler"):
		return false
	
	sdk.add_separator("tab_combat")
	sdk.add_header("tab_combat", "[center][b]BATTLE CHARACTERS[/b][/center]")

	if _cached_battle_db == null:
		logger_instance.log_msg(
			self,
			"Battle characters database is null.",
			LOGGER.LogType.ERROR
		)
		return false

	if _cached_battle_db.is_empty():
		logger_instance.log_msg(
			self,
			"Battle characters database is empty.",
			LOGGER.LogType.WARN
		)
		return true

	for character_key in _cached_battle_db:
		var config = _cached_battle_db[character_key]

		if config == null:
			logger_instance.log_msg(
				self,
				"Character configuration is null for: %s." % character_key,
				LOGGER.LogType.ERROR
			)
			continue

		if not is_instance_valid(config):
			logger_instance.log_msg(
				self,
				"Character configuration is invalid for: %s." % character_key,
				LOGGER.LogType.ERROR
			)
			continue

		if config.id.is_empty():
			logger_instance.log_msg(
				self,
				"Character configuration has an empty ID: %s." % character_key,
				LOGGER.LogType.ERROR
			)
			continue

		var main_category_id = StringName("cat_" + config.id)
		var dress_control_category_id = StringName(main_category_id + "_dress_control")
		var scene_control_category_id = StringName(main_category_id + "_scene_control")

		_dev_log("Creating battle controls for: %s." % config.id)

		sdk.add_category(
			"tab_combat",
			main_category_id,
			config.id + " Combat Cheats"
		)

		sdk.add_category(
			main_category_id,
			dress_control_category_id,
			config.id + " Dress Control"
		)

		sdk.add_category(
			main_category_id,
			scene_control_category_id,
			config.id + " Scenes Control"
		)

		# Arousal buttons
		sdk.add_button(
			main_category_id,
			StringName("btn_add_arousal_" + config.id),
			"Add Arousal To " + config.id,
			_add_arousal.bind(config)
		)

		sdk.add_button(
			main_category_id,
			StringName("btn_take_arousal_" + config.id),
			"Take Arousal From " + config.id,
			_take_arousal.bind(config)
		)

		# Undress all button
		sdk.add_button(
			dress_control_category_id,
			StringName("btn_undress_all_" + config.id),
			"Undress " + config.id,
			_undress_all.bind(config)
		)

		# Specific clothing buttons
		if config.clothes_id_array == null:
			logger_instance.log_msg(
				self,
				"Character '%s' has a null clothes_id_array." % config.id,
				LOGGER.LogType.ERROR
			)
		else:
			for cloth_id_value in config.clothes_id_array:
				var cloth_id = cloth_id_value

				if cloth_id.is_empty():
					logger_instance.log_msg(
						self,
						"Character '%s' contains an empty clothing ID." % config.id,
						LOGGER.LogType.WARN
					)
					continue

				var safe_cloth_id: StringName = cloth_id.replace("clothes_", "")
				var button_id = StringName("btn_undress_" + cloth_id + "_" + config.id)
				var button_text = "Undress " + safe_cloth_id.capitalize() + " from " + config.id

				sdk.add_button(
					dress_control_category_id,
					button_id,
					button_text,
					_undress_specific.bind(safe_cloth_id, config)
				)

		# NSFW scenes
		var scenes_name: Array[String] = []

		if config.nsfw_scenes_dictionary == null:
			logger_instance.log_msg(
				self,
				"Character '%s' has no NSFW scenes dictionary." % config.id,
				LOGGER.LogType.WARN
			)
		else:
			for nsfw_scene_key in config.nsfw_scenes_dictionary:
				var scene_key = nsfw_scene_key

				if scene_key.is_empty():
					logger_instance.log_msg(
						self,
						"Character '%s' contains an empty NSFW scene ID." % config.id,
						LOGGER.LogType.WARN
					)
					continue

				scenes_name.append(scene_key)
				_dev_log(
					"Registered NSFW scene '%s' for '%s'." % [scene_key, config.id]
				)

		if scenes_name.is_empty():
			logger_instance.log_msg(
				self,
				"Character '%s' has no valid NSFW scenes. Scene controls will be skipped." % config.id,
				LOGGER.LogType.WARN
			)
			continue

		sdk.add_dropdown(
			scene_control_category_id,
			StringName("drpdwn_scenes_" + config.id),
			"Scenes for " + config.id,
			scenes_name,
			0,
			_select_scene.bind(config, scenes_name)
		)

		sdk.add_button(
			scene_control_category_id,
			StringName("btn_start_sex_scene_" + config.id),
			"Start NSFW Scene for " + config.id,
			_start_sex_scene.bind(config)
		)

		_dev_log(
			"Battle character controls initialized successfully for: %s." % config.id,
			LOGGER.LogType.SUCCESS
		)

	logger_instance.log_msg(
		self,
		"Battle character manipulation controls initialized successfully.",
		LOGGER.LogType.SUCCESS
	)

	return true

func _add_arousal(config) -> void:
	var current_arousal = char_handle.get_character_arousal_by_config(config.id)

	if typeof(current_arousal) not in [TYPE_INT, TYPE_FLOAT]:
		logger_instance.log_msg(
			self,
			"Invalid arousal value returned for character: %s." % config.id,
			LOGGER.LogType.ERROR
		)
		return

	char_handle.set_character_arousal_by_config(
		config.id,
		current_arousal + 20
	)


func _take_arousal(config) -> void:
	var current_arousal = char_handle.get_character_arousal_by_config(config.id)

	if typeof(current_arousal) not in [TYPE_INT, TYPE_FLOAT]:
		logger_instance.log_msg(
			self,
			"Invalid arousal value returned for character: %s." % config.id,
			LOGGER.LogType.ERROR
		)
		return

	char_handle.set_character_arousal_by_config(
		config.id,
		current_arousal - 20
	)


func _undress_all(config) -> void:
	var clothes_array = char_handle.get_character_dress_by_config(config.id)

	if clothes_array == null:
		logger_instance.log_msg(
			self,
			"Failed to retrieve clothes for character: %s." % config.id,
			LOGGER.LogType.ERROR
		)
		return

	for cloth in clothes_array:
		if cloth == null or not is_instance_valid(cloth):
			continue

		char_handle.break_cloth_by_instance(
			cloth,
			clothes_array,
			config.id
		)


func _undress_specific(safe_cloth_id: StringName, config) -> void:
	var clothes_array = char_handle.get_character_dress_by_config(config.id)

	if clothes_array == null:
		logger_instance.log_msg(
			self,
			"Failed to retrieve clothes for character: %s." % config.id,
			LOGGER.LogType.ERROR
		)
		return

	for cloth in clothes_array:
		if cloth == null or not is_instance_valid(cloth):
			continue

		if safe_cloth_id == cloth.name:
			char_handle.break_cloth_by_instance(
				cloth,
				clothes_array,
				config.id
			)


func _select_scene(config, scenes_name: Array[String], value: int) -> void:
	if value < 0 or value >= scenes_name.size():
		logger_instance.log_msg(
			self,
			"Invalid scene selection index %d for character '%s'." % [value, config.id],
			LOGGER.LogType.ERROR
		)
		return

	config.selected_scene_id = value


func _start_sex_scene(config) -> void:
	_start_sex_scene_internal(config, config.selected_scene_id)

func _start_sex_scene_internal(character_config, scene_id: int) -> bool:
	if character_config == null:
		logger_instance.log_msg(
			self,
			"Cannot start NSFW scene: character configuration is null.",
			LOGGER.LogType.ERROR
		)
		return false

	if not is_instance_valid(character_config):
		logger_instance.log_msg(
			self,
			"Cannot start NSFW scene: character configuration is invalid.",
			LOGGER.LogType.ERROR
		)
		return false

	if character_config.nsfw_scenes_dictionary == null:
		logger_instance.log_msg(
			self,
			"Cannot start NSFW scene: scene dictionary is null.",
			LOGGER.LogType.ERROR
		)
		return false

	var all_scene_names: Array = character_config.nsfw_scenes_dictionary.keys()

	if scene_id < 0 or scene_id >= all_scene_names.size():
		logger_instance.log_msg(
			self,
			"Cannot start NSFW scene: scene index %d is out of bounds. Available scenes: %d." % [scene_id, all_scene_names.size()],
			LOGGER.LogType.ERROR
		)
		return false

	var selected_key: String = str(all_scene_names[scene_id])

	if selected_key.is_empty():
		logger_instance.log_msg(
			self,
			"Cannot start NSFW scene: selected scene ID is empty.",
			LOGGER.LogType.ERROR
		)
		return false

	if not _validate_dependency(char_handle, "CharactersHandler"):
		return false

	char_handle.execute_sex_scene(
		character_config,
		selected_key
	)

	logger_instance.log_msg(
		self,
		"NSFW scene execution requested successfully: %s." % selected_key,
		LOGGER.LogType.SUCCESS
	)

	return true

# ==================================================
# UTILITY
# ==================================================

func load_all_items() -> Array:
	var items_array: Array = []
	const path := "res://resources/items/"

	if not DirAccess.dir_exists_absolute(path):
		logger_instance.log_msg(
			self,
			"Items directory does not exist: %s." % path,
			LOGGER.LogType.ERROR
		)
		return items_array

	var dir := DirAccess.open(path)

	if dir == null:
		logger_instance.log_msg(
			self,
			"Failed to open items directory: %s." % path,
			LOGGER.LogType.ERROR
		)
		return items_array

	var files := dir.get_files()

	for file_name_value in files:
		var file_name := str(file_name_value)
		
		if file_name.ends_with(".png") or file_name.ends_with(".jpg") or file_name.ends_with(".jpeg"):
			logger_instance.log_msg(
				self,
				"Skipping resource: %s." % file_name,
				LOGGER.LogType.WARN
			)
			continue
		
		if file_name.ends_with(".remap"):
			file_name = file_name.trim_suffix(".remap")
		elif file_name.ends_with(".import"):
			continue

		var full_path := path.path_join(file_name)

		if not ResourceLoader.exists(full_path):
			_dev_log(
				"Skipping file that is not a loadable resource: %s." %
				full_path,
				LOGGER.LogType.WARN
			)
			continue

		var resource := load(full_path)

		if resource == null:
			logger_instance.log_msg(
				self,
				"Failed to load item resource: %s." % full_path,
				LOGGER.LogType.ERROR
			)
			continue

		if not "id" in resource:
			logger_instance.log_msg(
				self,
				"Loaded resource does not contain an 'id' property: %s." %
				full_path,
				LOGGER.LogType.ERROR
			)
			continue

		items_array.append(resource)

		_dev_log(
			"Item loaded successfully: %s." % file_name,
			LOGGER.LogType.SUCCESS
		)

	return items_array

# ==================================================
# SCENE MANAGER
# ==================================================

func initialize_scene_manager() -> bool:
	if not _validate_sdk():
		return false

	if not _validate_dependency(scene_manager, "SceneManager"):
		return false

	if not _validate_dependency(char_handle, "CharactersHandler"):
		return false

	var battle_characters_database: Dictionary = \
		CHARACTER_DATABASE.get_battle_characters_database()

	if battle_characters_database == null:
		logger_instance.log_msg(
			self,
			"Cannot initialize SceneManager: battle characters database is null.",
			LOGGER.LogType.ERROR
		)
		return false

	if not scene_manager.on_scene_changed:
		logger_instance.log_msg(
			self,
			"SceneManager scene-changed signal is unavailable.",
			LOGGER.LogType.ERROR
		)
		return false

	if scene_manager.on_scene_changed.is_connected(_on_scene_changed):
		_dev_log("SceneManager signal is already connected.")
		return true

	scene_manager.on_scene_changed.connect(_on_scene_changed)

	logger_instance.log_msg(
		self,
		"SceneManager integration initialized successfully.",
		LOGGER.LogType.SUCCESS
	)

	return true

func _on_scene_changed(name: String) -> void:
	if not _validate_sdk():
		return

	if not _validate_dependency(scene_manager, "SceneManager"):
		return

	if not _validate_dependency(char_handle, "CharactersHandler"):
		return

	_dev_log(
		"Scene changed: %s." % name
	)

	var pill_manager = PillManager

	if pill_manager != null and is_instance_valid(pill_manager):
		var pills_value = sdk.get_element_value("chk_pills_consumed")

		if typeof(pills_value) == TYPE_BOOL:
			pill_manager.pill_consumed = pills_value
		else:
			logger_instance.log_msg(
				self,
				"Failed to update PillManager: checkbox returned an invalid value.",
				LOGGER.LogType.ERROR
			)

	if scene_manager.is_battle_scene(name):
		_dev_log("Battle scene detected: %s." % name)
		sdk.set_tab_disabled("tab_combat", false)

		for character_key in _cached_battle_db:
			var config = _cached_battle_db[character_key]

			if config == null or not is_instance_valid(config):
				logger_instance.log_msg(
					self,
					"Invalid character configuration while entering battle scene: %s." %
					character_key,
					LOGGER.LogType.ERROR
				)
				continue

			config.character_reference = \
				char_handle.get_character_on_scene_by_id(config.id)

	else:
		sdk.set_tab_disabled("tab_combat", true)

		for character_key in _cached_battle_db:
			var config = _cached_battle_db[character_key]

			if config == null or not is_instance_valid(config):
				continue

			config.character_reference = null

	if scene_manager.is_openworld_scene(name):
		_dev_log("Open-world scene detected: %s." % name)
		sdk.set_tab_disabled("tab_player", false)
	else:
		sdk.set_tab_disabled("tab_player", true)

	if scene_manager.is_menu_scene(name):
		_dev_log("Menu scene detected: %s." % name)

# ==================================================
# SCENE SEARCH
# ==================================================

func has_scenes_recursive(dir_path: String) -> bool:
	if dir_path.is_empty():
		return false

	var dir := DirAccess.open(dir_path)

	if dir == null:
		_dev_log(
			"Failed to open directory while searching for scenes: %s." %
			dir_path,
			LOGGER.LogType.WARN
		)
		return false

	dir.list_dir_begin()

	var file_name := dir.get_next()

	while file_name != "":
		if file_name != "." and file_name != "..":
			var full_path := dir_path.path_join(file_name)

			if dir.current_is_dir():
				if has_scenes_recursive(full_path):
					dir.list_dir_end()
					return true

			elif (
				file_name.ends_with(".tscn")
				or file_name.ends_with(".scn")
				or file_name.ends_with(".remap")
			):
				dir.list_dir_end()
				return true

		file_name = dir.get_next()

	dir.list_dir_end()

	return false
