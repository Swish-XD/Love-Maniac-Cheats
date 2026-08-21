class_name CharacterDatabase

const MAIN = preload("res://loadot/mods/LoveManiacCheats/main.gd")

const CHARACTER_CONFIG = preload("res://loadot/mods/LoveManiacCheats/CharacterConfig.gd")
const NSFW_SCENE = preload("res://loadot/mods/LoveManiacCheats/NsfwScene.gd")

static func get_battle_characters_database() -> Dictionary:
	return battle_character_database_dictionary

static func get_non_battle_characters_database() -> Dictionary:
	return non_battle_characters_database

static var battle_character_database_dictionary: Dictionary = {
	"Chara": CHARACTER_CONFIG.new(
		"Chara",
		[&"clothes_sweater", &"clothes_shorts", &"clothes_bra", &"clothes_panties"],
		["first_fight"],
		["full_nelson", "miss_scene", "side_bj", "strap_on", "thighjob_scene", "titjob_scene", "ride_scene", "butcher_blowjob", "pale_behind"], # "None" if character doesnt have any NSFW scenes
		["butcher", "pale_chara"], # "None" if character doesnt have any costumes
		{
			"Cowgirl": NSFW_SCENE.new(
				[&"clothes_sweater", &"clothes_shorts", &"clothes_bra", &"clothes_panties"],
				100,
				func(character: NudableCharacter):
					MAIN.instance.cheat_set_took_damage(true)
					character.actions[3].execute(character)
					),
			"Missionary": NSFW_SCENE.new(
				[],
				0,
				func(character: NudableCharacter):
					GameManager.chara_defeat_count = 3
					for i in range(11):
						MAIN.instance.player_soul_handler.damage_player()
					),
			"Thighjob": NSFW_SCENE.new(
				[&"clothes_panties"],
				100,
				func(character: NudableCharacter):
					MAIN.instance.player_soul_handler.player.took_damage = true
					character.actions[3].execute(character)
					),
			"Titfuck": NSFW_SCENE.new(
				[&"clothes_bra"],
				100,
				func(character: NudableCharacter):
					MAIN.instance.player_soul_handler.player.took_damage = true
					character.actions[3].execute(character)
					),
			"Full Nelson": NSFW_SCENE.new(
				[&"clothes_bra"],
				100,
				func(character: NudableCharacter):
					MAIN.instance.player_soul_handler.player.took_damage = false
					character.actions[3].execute(character)
					),
			"Strapon": NSFW_SCENE.new(
				[&"clothes_bra"],
				100,
				func(character: NudableCharacter):
					character._direct_hit_scene()
					)
		}
	)
}

static var non_battle_characters_database: Dictionary = {
	"Nebby": [
		"backshot_nebby",
		"nebby_titjob",
		"nebby_riding",
		"nebby_fingering"
	],
	"Frisk": [
		"frisk_jerking_off",
		"frisk_reverse_ride",
		"frisk_riding_dildo"
	]
}
