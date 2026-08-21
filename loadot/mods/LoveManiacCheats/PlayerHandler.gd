class_name PlayerHandler
extends Node

const LOGGER = preload("res://loadot/mods/LoveManiacCheats/CheatSDK/core/LoggerHandle.gd")

var player: Frisk
var scene_manager: Node
var logger_instance: Node

var default_movement_velocity: int

func _init(tree: SceneTree, scene_manager_instance: Node):
	scene_manager = scene_manager_instance
	logger_instance = LOGGER.new("Love Maniac")
	
	scene_manager.on_scene_changed.connect(
		func(name: String):
			if scene_manager.is_openworld_scene(name):
				var current_scene = scene_manager.get_current_scene()
				_update_player_reference(current_scene)
				if player and is_instance_valid(player):
					default_movement_velocity = player.movement_velocity)
	
	logger_instance.log_msg(self, "PlayerHandler intialized...", LOGGER.LogType.SUCCESS)

func _update_player_reference(scene: Node) -> void:
	if scene:
		player = scene.find_child("CharacterBody2D", true, false)

func multiply_player_movement_velocity(value: float) -> void:
	if not player or not is_instance_valid(player):
		_update_player_reference(scene_manager.get_current_scene())
		
	if player and is_instance_valid(player):
		player.movement_velocity = default_movement_velocity * value
