extends CharacterBody3D


const CANNON_BALL = preload("res://scenes/cannon_ball.tscn")

@onready var damage_sfx: AudioStreamPlayer3D = $DamageSFX
@onready var cannon_sfx: AudioStreamPlayer3D = $CannonSFX
@onready var HUD: Node2D = $CanvasLayer/Hud
@onready var label = $Label3D
@onready var camera = $Camera/CameraTarget/SpringArm3D/Camera3D 
@onready var cannon_camera: Camera3D = $CannonCamera
@onready var cannon: MeshInstance3D = $"cannon/cannon/cannon_right 12"
@onready var cannon_base: MeshInstance3D = $"cannon/cannon"
@onready var cannonBall_location = $cannon/CannonBall
@onready var cannon_exit: Marker3D = $"cannon/cannon/cannon_right 12/cannon_exit"
@onready var labelName
@onready var timer = $Timer

@export var speed = 0.3
@export var friction = 0.995
@export var rotation_speed = 0.3
@export var max_velocity = 0.2

var direction = Vector3.FORWARD # Vector (0,0,-1)
var axis = Vector3.UP 
var rotation_velocity = 0
var sailing_camera = true

@export var rotation_min_x = 0
@export var rotation_max_x = 89
@export var rotation_min_y = -135
@export var rotation_max_y = -45

var max_health:int = 3
@onready var current_health:int
var last_damage = -1.0
var invulnerability = 50.0

enum state {normal, slow, freeze, confused, inked}
var actual_state = state.normal

@export var wave_amplitude = 0.005 
@export var wave_frequency = 1.0
var wave_time = 0.0 

func _physics_process(delta):
	if is_multiplayer_authority():
		# Cambio de cámara
		if Input.is_action_just_pressed("change_camera"):
			if (camera.current):
				cannon_camera.current = true
				camera.current = false
			else:
				camera.current = true
				cannon_camera.current = false
			sailing_camera = not sailing_camera
		# Disparo
		if Input.is_action_just_pressed("fire"):
			shoot_cannon_ball()
			
		# Movimiento hacia adelante
		if Input.is_action_pressed("move_forward"):
			if (sailing_camera):
				velocity += direction * speed * delta
			else:
				cannon.rotate_x(delta)
		# Movimiento hacia y atrás
		if Input.is_action_pressed("move_back"):
			if (sailing_camera):
				velocity += -direction * speed * delta * 0.5
			else:
				cannon.rotate_x(-delta)
		# Movimiento hacia la derecha
		if Input.is_action_pressed("move_right"):
			if (sailing_camera):
				direction = direction.rotated(-axis, rotation_speed * delta).normalized()
			else:
				cannon_base.rotate_y(-delta)
		# Movimiento hacia la izquierda
		if Input.is_action_pressed("move_left"):
			if (sailing_camera):
				direction = direction.rotated(axis, rotation_speed * delta).normalized()
			else:
				cannon_base.rotate_y(delta)

		cannon.rotation.x = clamp(cannon.rotation.x, deg_to_rad(rotation_min_x),deg_to_rad(rotation_max_x))
		cannon_base.rotation.y = clamp(cannon_base.rotation.y, deg_to_rad(rotation_min_y),deg_to_rad(rotation_max_y))
		# Friccion
		velocity = velocity * friction
		
		wave_time += delta
		var wave = wave_amplitude * sin(wave_frequency * wave_time)
		velocity.y = wave
		
		velocity.x = clamp(velocity.x, -max_velocity, max_velocity)
		velocity.z = clamp(velocity.z, -max_velocity, max_velocity)
		look_at(global_transform.origin + direction, axis)
		position += velocity
		move_and_slide()
		send_position.rpc(position, direction)

@rpc("authority")
func send_position(pos : Vector3, dir : Vector3) -> void:
	position = pos
	direction = dir
	look_at(global_transform.origin + direction, axis)
	
@rpc("authority")
func _on_area_3d_area_entered(area: Area3D) -> void:
	var collision_normal = (global_transform.origin - area.global_transform.origin).normalized()
	velocity += collision_normal * speed * 0.4  	
	
func _on_timer_timeout():
	print("termino timer")
	if actual_state == state.freeze:
		max_velocity = 0.2
	actual_state = state.normal
	return
	

@rpc("authority")
func take_damage(damage):
	print("time :"+str(Time.get_ticks_msec()) + ", last damage=" + str(last_damage) + " involnerability =" + str(invulnerability))
	
	if Time.get_ticks_msec() - last_damage >= invulnerability:
		current_health -= damage
		print(current_health)
		last_damage = Time.get_ticks_msec()
		damage_sfx.play()
	
func shoot_cannon_ball() -> void:
	if multiplayer.is_server():
		rpc_id(0, "spawn_cannon_ball", cannon_exit.global_position, cannon_exit.global_position - cannonBall_location.global_position+ velocity)
	else:
		rpc_id(1, "request_shoot",cannon_exit.global_position, cannon_exit.global_position - cannonBall_location.global_position+ velocity)

@rpc("call_local", "reliable")
func request_shoot(spawn_position: Vector3, spawn_direction: Vector3) -> void:
	if multiplayer.is_server():
		spawn_cannon_ball(spawn_position, spawn_direction)
		rpc_id(0, "spawn_cannon_ball", spawn_position, spawn_direction)

@rpc("any_peer", "call_local", "reliable")
func spawn_cannon_ball(spawn_position: Vector3, spawn_direction: Vector3) -> void:
	var cannon_ball_node = CANNON_BALL.instantiate()
	cannon_ball_node.set_parent_player(self)
	cannon_ball_node._set_direction(spawn_direction)
	get_parent().add_child(cannon_ball_node)
	cannon_ball_node.global_position = spawn_position
	cannon_sfx.play()

func get_current_health():
	return current_health

func end_game() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/menus/end_game.tscn")

func die():
	self.visible=false
	self.position=Vector3(0,position.y + 10,0)
	Global.restantes -=1
	Global.nombres.erase(labelName)
	if Global.restantes <=1:
		end_game()

func slow(velocity_penalty: int):
	# velocity_penalty: porcentaje entre 0 y 100 de penalty en la velocidad del enemigo
	var current_speed = self.speed
	#disminuir la velocidad del barco por un tiempo y luego devolverla a la normalidad
	self.speed = current_speed
	return

func freeze():
	#disminuir la velocidad del barco por un tiempo y luego devolverla a la normalidad
	print("congelao")
	max_velocity = 0
	actual_state = state.freeze
	timer.start(10)
	return
	
func opposite_direction():
	return
	
func low_visibility():
	return

	
func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	current_health=max_health
	set_multiplayer_authority(player_data.id)
	label.text = player_data.name
	labelName = player_data.name
	Global.nombres.append(player_data.name)
	#print(Global.nombres)

	if is_multiplayer_authority():
		camera.current = true
	else:
		# Desactiva la cámara si es un jugador remoto
		camera.current = false
	Debug.log("admin")
	Debug.log(player_data.id)
