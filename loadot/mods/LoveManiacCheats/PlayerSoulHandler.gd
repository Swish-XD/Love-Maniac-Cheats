class_name PlayerSoulHandler extends Node

const LOGGER = preload("res://loadot/mods/LoveManiacCheats/CheatSDK/core/LoggerHandle.gd")

var player: PlayerSoul
var fight_btn: FightButton = null
var default_fight_damage: float = 0.0
var scene_manager: Node
var logger_instance: Node

var is_god_mode_enabled: bool = false

func _init(scene_manager_instance: Node):
	scene_manager = scene_manager_instance
	logger_instance = LOGGER.new("Love Maniac")
	
	scene_manager.on_scene_changed.connect(
		func(_scene_name: String):
			if scene_manager.is_battle_scene(_scene_name):
				logger_instance.log_msg(self, "PlayerSoulHandler SCENE CHANGED!!!!", LOGGER.LogType.WARN)
				var current_scene = scene_manager.get_current_scene()
				
				_update_player_soul_reference(current_scene)
				god_mode_toggle(is_god_mode_enabled)
				
				if current_scene:
					fight_btn = current_scene.find_child("fight", true, false)
					if fight_btn and is_instance_valid(fight_btn):
						default_fight_damage = fight_btn.base_damage)
	logger_instance.log_msg(self, "PlayerSoulHandler intialized...", LOGGER.LogType.SUCCESS)

func _update_player_soul_reference(scene: Node) -> void:
	if scene:
		player = scene.find_child("player", true, false)
	
	if player or is_instance_valid(player):
		logger_instance.log_msg(self, "Player soul reference successful updated!", LOGGER.LogType.SUCCESS)
	else:
		logger_instance.log_msg(self, "Error occured when updating player soul reference", LOGGER.LogType.ERROR)

func god_mode_toggle(toggled_on: bool) -> void:
	is_god_mode_enabled = toggled_on
	
	if not player or not is_instance_valid(player):
		logger_instance.log_msg(self, "Player soul reference is not valid", LOGGER.LogType.ERROR)
	else:
		player.set_is_invulnerable(toggled_on)

func set_hp(new_hp_amount: int):
	if not is_instance_valid(player):
		logger_instance.log_msg(self, "Player reference is null", LOGGER.LogType.ERROR)
		return
	
	if not is_instance_valid(player.character):
		logger_instance.log_msg(self, "Character in player is null", LOGGER.LogType.ERROR)
		return
	
	player.character.set_hp(new_hp_amount)
	
	if get_player_current_hp() <= 0:
		GameManager.register_death(player.global_position)

func damage_player() -> void:
	if not is_instance_valid(player):
		logger_instance.log_msg(self, "Player reference is null", LOGGER.LogType.ERROR)
		return
	
	if not is_instance_valid(player.character):
		logger_instance.log_msg(self, "Character in player is null", LOGGER.LogType.ERROR)
		return
	
	player.character.damage(10)
	
	if get_player_current_hp() <= 0:
		GameManager.register_death(player.global_position)

func heal_player() -> void:
	if not is_instance_valid(player):
		logger_instance.log_msg(self, "Player reference is null", LOGGER.LogType.ERROR)
		return
	
	if not is_instance_valid(player.character):
		logger_instance.log_msg(self, "Character in player is null", LOGGER.LogType.ERROR)
		return
	
	player.character.heal(10)

func get_player_max_hp() -> int:
	if not is_instance_valid(player):
		logger_instance.log_msg(self, "Player reference is null", LOGGER.LogType.ERROR)
		return -1
	
	if not is_instance_valid(player.character):
		logger_instance.log_msg(self, "Character in player is null", LOGGER.LogType.ERROR)
		return -1
	
	return player.character.get_max_hp()

func get_player_current_hp() -> int:
	if not is_instance_valid(player):
		logger_instance.log_msg(self, "Player reference is null", LOGGER.LogType.ERROR)
		return -1
	
	if not is_instance_valid(player.character):
		logger_instance.log_msg(self, "Character in player is null", LOGGER.LogType.ERROR)
		return -1
	
	return player.character.get_hp()

func set_damage_changed(value: float) -> void:
	if fight_btn or is_instance_valid(fight_btn):
		var _new_damage: int = round(default_fight_damage * value)
		fight_btn.base_damage = _new_damage

func get_player() -> PlayerSoul:
	if not is_instance_valid(player):
		logger_instance.log_msg(self, "Player reference is null", LOGGER.LogType.ERROR)
		return null
		
	return player

func get_player_character() -> Character:
	if not is_instance_valid(player.character):
		logger_instance.log_msg(self, "Character in player is null", LOGGER.LogType.ERROR)
		return null
		
	return player.character
