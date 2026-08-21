class_name CharacterConfig
extends RefCounted

var id: String = ""
var character_reference: NudableCharacter = null
var clothes_id_array: Array[StringName] = []
var battles: Array[String] = []
var scenes_id: Array[String] = []
var suits_id: Array[String] = []
var nsfw_scenes_dictionary: Dictionary = {}
var selected_scene_id: int = 0

func _init(_id: StringName, _clothes_id_array: Array[StringName], _battles: Array[String], _scenes_id: Array[String], _suits_id: Array[String], _nsfw_scenes_dictionary: Dictionary, _character_reference: NudableCharacter = null):
	id = _id
	clothes_id_array = _clothes_id_array
	battles = _battles
	scenes_id = _scenes_id
	suits_id = _suits_id
	nsfw_scenes_dictionary = _nsfw_scenes_dictionary
