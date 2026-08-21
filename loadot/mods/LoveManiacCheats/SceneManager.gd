class_name SceneManager
extends Node

const LOGGER = preload("res://loadot/mods/LoveManiacCheats/CheatSDK/core/LoggerHandle.gd")

const OPENWORLD_SCENES: Array[String] = [
	"NewCharaRoom",
	"HallRoom",
	"LoungeRoom",
    "BedRoom"
]

const BATTLE_SCENES: Array[String] = [
    "BattleScene"
]

const MENU_SCENES: Array[String] = [
	"Screen",
	"MainMenuGallery",
	"Game Over Scene",
	"MainMenu",
	"SaveSlotSelect",
	"NebulaShop",
    "StartScene"
]

var global_tree: SceneTree

var _last_scene_name: String = ""
signal on_scene_changed(new_scene_name: String)
var logger_instance: Node

func _init(tree: SceneTree) -> void:
	logger_instance = LOGGER.new("Love Maniac")
	
	global_tree = tree
	if global_tree:
		global_tree.tree_changed.connect(_on_tree_changed)
		logger_instance.log_msg(self, "SceneManager intialized...", LOGGER.LogType.SUCCESS)
		
func _on_tree_changed() -> void:
	var current_scene = get_current_scene()
	if current_scene and is_instance_valid(current_scene):
		var scene_name: String = current_scene.name
		
		if scene_name != _last_scene_name:
			_last_scene_name = scene_name
			on_scene_changed.emit(scene_name)

func is_openworld_scene(scene_name: String) -> bool:
	return scene_name in OPENWORLD_SCENES

func is_battle_scene(scene_name: String) -> bool:
	return scene_name in BATTLE_SCENES

func is_menu_scene(scene_name: String) -> bool:
	return scene_name in MENU_SCENES

func _on_node_added(node: Node) -> void:
	if global_tree and node.get_parent() == global_tree.root and node != self:
		var scene_name: String = node.name
		on_scene_changed.emit(scene_name)

func get_current_scene() -> Node:
	if not global_tree:
		return null
		
	var current = global_tree.current_scene
	if current and is_instance_valid(current):
		return current
		
	var root = global_tree.root
	for child in root.get_children():
		if child != self and child != root.get_node_or_null("GUMM") and not child.name.begins_with("@"):
			return child
			
	return null
