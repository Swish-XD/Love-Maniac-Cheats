class_name CharactersHandler
extends Node

const BATTLE_CHARATERS_PATH = "res://battle_characters"

const LOGGER = preload("res://loadot/mods/LoveManiacCheats/CheatSDK/core/LoggerHandle.gd")

const CHARACTER_DATABASE = preload("res://loadot/mods/LoveManiacCheats/CharacterDatabase.gd")
const CHARACTER_CONFIG = preload("res://loadot/mods/LoveManiacCheats/CharacterConfig.gd")
const NSFW_SCENE = preload("res://loadot/mods/LoveManiacCheats/NsfwScene.gd")

var characters_dictionary: Dictionary = {}
var global_tree: SceneTree

var database: Dictionary

var logger_instance: Node

func _init(tree: SceneTree):
	logger_instance = LOGGER.new("Love Maniac")
	
	global_tree = tree
	if DirAccess.dir_exists_absolute(BATTLE_CHARATERS_PATH):
		var folders = DirAccess.get_directories_at(BATTLE_CHARATERS_PATH)
		
		for folder_name in folders:
			if not folder_name.begins_with("."):
				characters_dictionary.get_or_add(
					folder_name, 
					BATTLE_CHARATERS_PATH.path_join(folder_name)
				)
				logger_instance.log_msg(self, "Character registrated: " + folder_name, LOGGER.LogType.INFO)
				
	database = CHARACTER_DATABASE.get_battle_characters_database()
	logger_instance.log_msg(self, "CharacterHandler intialized...", LOGGER.LogType.SUCCESS)

func execute_sex_scene(character_config: CHARACTER_CONFIG, scene_name: String):
	logger_instance.log_msg(self, "execute_sex_scene info\n=== Starting Sex Scene ===\nCharacter Config ID: " + character_config.id + "\nScene Name: " + scene_name, LOGGER.LogType.INFO)
	var clothes_array: Array[Cloth] = get_character_dress_by_config(character_config.id)
	var cloth_array_to_destroy: Array[Cloth]
	
	for cloth_name in character_config.nsfw_scenes_dictionary[scene_name].clothes_to_destroy:
		cloth_array_to_destroy.append(get_cloth_by_id(cloth_name, clothes_array))
		
	for cloth_to_destroy in cloth_array_to_destroy:
		break_cloth_by_instance(cloth_to_destroy, clothes_array, character_config.id)
		
	character_config.nsfw_scenes_dictionary[scene_name].to_execute.call(character_config.character_reference)

func set_character_arousal_by_config(character_config: String, amount: int) -> void:
	var reference = database[character_config].character_reference
	if reference and is_instance_valid(reference):
		reference.arousal = amount

func get_character_arousal_by_config(character_config: String) -> int:
	var reference = database[character_config].character_reference
	if reference and is_instance_valid(reference):
		return reference.arousal
	return 0

func break_cloth_by_instance(target_cloth: Cloth, all_clothes: Array[Cloth], character_id: String) -> void:
	var character_instance = get_character_on_scene_by_id(character_id)

	if not target_cloth or not is_instance_valid(target_cloth):
		return
		
	var blocker: Cloth = _find_what_blocks_this_cloth(target_cloth, all_clothes)
	
	if blocker:
		break_cloth_by_instance(blocker, all_clothes, character_id)
	
	if not target_cloth.is_broken:
		target_cloth.break_cloth()
		character_instance.cloth_sprites.erase(target_cloth)
	else:
		print("[Love Maniac] Cloth with ID: " + target_cloth.name + " already broken.")


func _find_what_blocks_this_cloth(target_cloth: Cloth, all_clothes: Array[Cloth]) -> Cloth:
	for cloth in all_clothes:
		if not is_instance_valid(cloth):
			continue
			
		var dependency = cloth.get("unlocked_cloth_when_broken")
		
		if dependency:
			if dependency == target_cloth:
				return cloth
			
			var is_name_match = str(dependency) == target_cloth.name
			var is_id_match = str(dependency) == str(target_cloth.get("cloth_id"))
			
			if is_name_match or is_id_match:
				return cloth
				
	return null

func get_cloth_by_id(cloth_id: StringName, cloth_array: Array[Cloth]) -> Cloth:
	for cloth in cloth_array:
		if cloth.cloth_name == cloth_id:
			return cloth
			
	print("[Love Maniac] Cannot found cloth with id: ", cloth_id)
	return null

func get_character_dress_by_config(character_config: String) -> Array[Cloth]:
	var reference = database[character_config].character_reference
	var result: Array[Cloth] = []
	
	if not reference or not is_instance_valid(reference):
		return result
		
	for child in reference.find_children("*"):
		if child is Cloth:
			result.append(child)
	return result

func get_character_on_scene_by_id(character_id: String) -> NudableCharacter:
	if not global_tree or not is_instance_valid(global_tree):
		print("[Love Maniac] SceneTree is invalid!")
		return null
		
	var scene_root = global_tree.root
	var container_name: String = get_container_name_from_prefab(character_id)
	
	if container_name != "":
		var nudable_character = scene_root.find_child(
			container_name, 
			true, 
			false
		) as NudableCharacter
		
		if nudable_character and is_instance_valid(nudable_character):
			return nudable_character
	else:
		print("[Love Maniac] Container name is empty!")
	return null

func get_container_name_from_prefab(character_id: String) -> String:
	var prefab_path = get_character_prefab_path_with_id(character_id)
	if prefab_path == "" or not ResourceLoader.exists(prefab_path):
		return ""
		
	var packed_scene = load(prefab_path) as PackedScene
	if packed_scene:
		var virtual_node = packed_scene.instantiate()
		if virtual_node:
			var container_name: String = virtual_node.name
			virtual_node.queue_free()
			return container_name    
	return ""

func get_character_prefab_path_with_id(character_id: String) -> String:
	var char_path: String = get_character_path_with_id(character_id)
	if char_path != "":
		var files = DirAccess.get_files_at(char_path)
		
		for file in files:
			var file_lower = file.to_lower()
			if file_lower.ends_with(".tscn") or file_lower.ends_with(".tscn.remap"):
				var clean_file_name = file.replace(".remap", "")
				var found_scene_path = char_path + "/" + clean_file_name
				return found_scene_path
				
	return ""

func get_character_path_with_id(character_id: String) -> Variant:
	if not characters_dictionary.is_empty():
		if characters_dictionary.has(character_id):
			return characters_dictionary[character_id]
	else:
		print("[Love Maniac] Characters dictionary is empty!")
	
	return null
