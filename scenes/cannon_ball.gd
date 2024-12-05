extends Area3D

@export var speed = 45
@export var damage = 1
@export var direction = Vector3()
@export var target_velocity_penalty: int = 0 #porcentaje entre 0 y 100 de penalty en la velocidad del enemigo
@export var target_opposite_direction = false #para cambiarle la direccion al barco enemigo
@export var target_low_visibility = false #para que el enemigo tenga poca vision
@export var target_freeze = false #para que el enemigo no se pueda mover

var vertical_speed = 0
var parent_player = null

enum state {normal, slow, freeze, confused, inked}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(Callable(self, "_on_body_entered"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	vertical_speed -= gravity * delta

	global_position += (speed * delta * direction) + Vector3(0, vertical_speed * delta, 0)
	if (position.y < -5) :
		queue_free()


func set_parent_player(player):
	parent_player = player

func _set_direction(dir: Vector3):
	direction = dir

func set_state(new_state):
	match new_state:
		state.slow:
			print("cannonball_state = slow")
			target_velocity_penalty = 45
		state.freeze:
			print("cannonball_state = freeze")
			target_freeze = true
		state.confused:
			print("cannonball_state = confused")
			target_opposite_direction = true
		state.inked:
			print("cannonball_state = inked")
			target_low_visibility = true
	return

func _on_body_entered(body):
	if body.is_in_group("player") and body!= parent_player:  # Asegúrate de que el jugador esté en el grupo "Player"
		var player = body
		queue_free()
		
		player.take_damage(damage)
		damage = 0
		print(damage) # Aquí llamas a una función del jugador para restarle una vida
		  # Elimina la cannonball después de la colisión
		if player.current_health <=0:
			player.current_health=0
			player.die()
			return
		if target_velocity_penalty != 0:
			player.slow(target_velocity_penalty)
		if target_freeze:
			player.freeze()
		if target_opposite_direction:
			player.opposite_direction()
		if target_low_visibility:
			player.low_visibility()
		
