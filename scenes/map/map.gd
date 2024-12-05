extends Node3D
@onready var HUD: Node2D = $CanvasLayer/Hud
@onready var player_scene  = preload("res://scenes/player.tscn")
@onready var players: Node3D = $Players
@onready var spawn_point: Node3D = $SpawnPoint
@onready var sea_sfx: AudioStreamPlayer = $SeaSFX
@onready var creak_sfx: AudioStreamPlayer = $CreakSFX
@onready var bullet_spawn_points: Node3D = $BulletSpawnPoints
@onready var spawn_box  = preload("res://scenes/spawn_box.tscn")
@onready var spawn_timer: Timer = $SpawnTimer

var max_spawn_boxes: int = 2
var current_spawn_boxes: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sea_sfx.play()
	creak_sfx.play()
	Global.restantes = Game.players.size()
	if is_multiplayer_authority():
		spawn_timer.start(15.0)
		spawn_timer.connect("timeout", Callable(self, "_on_SpawnTimer_timeout"))

	for i in Game.players.size():
		var player_data = Game.players[i]
		var player_inst  = player_scene.instantiate()
		players.add_child(player_inst)
		player_inst.setup(player_data)
		player_inst.global_position =  spawn_point.get_child(i).global_position
		print(i)
		HUD.get_node("Label" + str(i+1)).set_player(player_inst)
		print(HUD.get_node("Label2").text)
		
func _on_spawn_box_destroyed() -> void:
	spawn_box_death()

func _on_SpawnTimer_timeout():
	print("El temporizador ha terminado")
	print("current_spawn_boxes", current_spawn_boxes)
	if current_spawn_boxes < max_spawn_boxes:
		spawn_spawner_box()


func random_spawner() -> Node3D:
	if bullet_spawn_points.get_child_count() > 0:
		var random_index = randi() % bullet_spawn_points.get_child_count()
		print("Bullet Spawn seleccionado:", random_index)
		return bullet_spawn_points.get_child(random_index)
	return null

func spawn_spawner_box():
	if current_spawn_boxes >= max_spawn_boxes:
		return
	var random_spawn_point = random_spawner()
	if random_spawn_point:
		var spawner_box_instance = spawn_box.instantiate()
		add_child(spawner_box_instance)
		spawner_box_instance.global_position = random_spawn_point.global_position
		current_spawn_boxes += 1 
		rpc("spawn_spawner_box_at_position", spawner_box_instance.global_position, spawner_box_instance.global_rotation)
		spawner_box_instance.connect("spawn_box_destroyed", Callable(self, "_on_spawn_box_destroyed"))

@rpc("call_remote")
func spawn_spawner_box_at_position(position: Vector3, rotation: Vector3):
	var spawner_box_instance = spawn_box.instantiate()
	add_child(spawner_box_instance)
	spawner_box_instance.global_position = position

@rpc("call_remote")
func spawn_box_death():
	current_spawn_boxes = max(current_spawn_boxes - 1, 0)

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
