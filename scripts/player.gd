extends CharacterBody3D


const CANNON_BALL = preload("res://scenes/cannon_ball.tscn")


@onready var label = $Label3D
@onready var camera = $Camera/CameraTarget/SpringArm3D/Camera3D 
@onready var cannon_camera: Camera3D = $CannonCamera
@onready var cannon: MeshInstance3D = $"cannon/cannon/cannon_right 12"
@onready var cannon_base: MeshInstance3D = $"cannon/cannon"
@onready var cannonBall_location = $cannon/CannonBall
@onready var cannon_exit: Marker3D = $"cannon/cannon/cannon_right 12/cannon_exit"

 # Asumiendo que tu cámara está directamente bajo el nodo de jugador

@export var speed = 0.3
@export var friction = 0.995
@export var rotation_speed = 0.3 # Controla qué tan rápido gira el personaje
@export var max_velocity = 0.2

var direction = Vector3.FORWARD # Vector (0,0,-1)
var axis = Vector3.UP 
var rotation_velocity = 0
var sailing_camera = true


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
			#camera.current =  not camera.current
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
		# Movimiento hacia adelante
		if Input.is_action_pressed("move_right"):
			if (sailing_camera):
				direction = direction.rotated(-axis, rotation_speed * delta).normalized()
			else:
				cannon_base.rotate_y(-delta)
		# Movimiento hacia y atrás
		if Input.is_action_pressed("move_left"):
			if (sailing_camera):
				direction = direction.rotated(axis, rotation_speed * delta).normalized()
			else:
				cannon_base.rotate_y(delta)
	
	# Friccion
	velocity = velocity * friction
	
	velocity.x = clamp(velocity.x, -max_velocity, max_velocity)
	velocity.z = clamp(velocity.z, -max_velocity, max_velocity)
	
	position += velocity
	look_at(global_transform.origin + direction, axis)
	
	send_position.rpc(position, direction)
	move_and_slide()
	
@rpc
func send_position(pos : Vector3, dir : Vector3) -> void:
	position = pos
	direction = dir


func shoot_cannon_ball() -> void:
	if multiplayer.is_server():
		spawn_cannon_ball(cannonBall_location.global_position, cannon_exit.global_position - cannonBall_location.global_position)
		#rpc_id(0, "spawn_cannon_ball", global_position, direction.rotated(axis, 0.5 * PI))
		rpc_id(0, "spawn_cannon_ball", cannonBall_location.global_position, cannon_exit.global_position - cannonBall_location.global_position)
	else:
		#rpc_id(1, "request_shoot", global_position, direction.rotated(axis, 0.5 * PI))
		rpc_id(1, "request_shoot", cannonBall_location.global_position, cannon_exit.global_position - cannonBall_location.global_position)

@rpc("call_local", "reliable")
func request_shoot(spawn_position: Vector3, spawn_direction: Vector3) -> void:
	if multiplayer.is_server():
		spawn_cannon_ball(spawn_position, spawn_direction)
		rpc_id(0, "spawn_cannon_ball", spawn_position, spawn_direction)

@rpc("any_peer", "call_local", "reliable")
func spawn_cannon_ball(spawn_position: Vector3, spawn_direction: Vector3) -> void:
	var cannon_ball_node = CANNON_BALL.instantiate()
	cannon_ball_node._set_direction(spawn_direction)
	get_parent().add_child(cannon_ball_node)
	cannon_ball_node.global_position = spawn_position

	
func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	label.text = player_data.name

	if is_multiplayer_authority():
		camera.current = true
	else:
		# Desactiva la cámara si es un jugador remoto
		camera.current = false
	Debug.log("admin")
	Debug.log(player_data.id)
