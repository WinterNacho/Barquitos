extends Node3D

@onready var player_scene  = preload("res://scenes/player.tscn")
@onready var players: Node3D = $Players
@onready var spawn_point: Node3D = $SpawnPoint

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst  = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position =  spawn_point.get_child(i).global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
