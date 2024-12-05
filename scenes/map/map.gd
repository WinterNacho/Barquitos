extends Node3D
@onready var HUD: Node2D = $CanvasLayer/Hud
@onready var player_scene  = preload("res://scenes/player.tscn")
@onready var players: Node3D = $Players
@onready var spawn_point: Node3D = $SpawnPoint
@onready var sea_sfx: AudioStreamPlayer = $SeaSFX
@onready var creak_sfx: AudioStreamPlayer = $CreakSFX

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sea_sfx.play()
	creak_sfx.play()
	Global.restantes = Game.players.size()
	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst  = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position =  spawn_point.get_child(i).global_position
		player_inst.look_at_mapcenter()
		player_inst.set_color(i)
		print(i)
		HUD.get_node("Label" + str(i+1)).set_player(player_inst)
		print(HUD.get_node("Label2").text)
		

func is_end_game_question_mark():
	print("omero")
	var count = 0
	for player in Game.players:
		if player.current_health > 0:
			count+=1
	if count<=1:
		end_game()

func end_game() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menus/end_game.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
