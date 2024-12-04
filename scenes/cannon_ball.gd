extends Area3D

@export var speed = 45
@export var damage = 1
@export var direction = Vector3()

var vertical_speed = 0
var parent_player = null

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
			print("dou")
			player.die()
