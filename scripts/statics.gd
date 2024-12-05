class_name Statics
extends Node


const MAX_CLIENTS = 3
const PORT = 5409 # Number between 1024 and 65535.


class PlayerData:
	var id: int
	var name: String
	var index: int = 0
	
	func _init(new_id: int, new_name: String, new_index: int = 0) -> void:
		id = new_id
		name = new_name
		index = new_index
	
	func to_dict() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"index": index,
		}
