extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.is_in_group("player"):  # Asegúrate de que el jugador esté en el grupo "Player"
		var player = body
		queue_free()
		
		player.take_damage(0)
		print("CHOQUE") # Aquí llamas a una función del jugador para restarle una vida
