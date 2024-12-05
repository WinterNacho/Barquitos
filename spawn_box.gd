extends Node

var balltype:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal spawn_box_destroyed

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.getSpecialBall(balltype)
		print("CHOQUE")
		print(body.actual_state)
		emit_signal("spawn_box_destroyed")
		queue_free()
