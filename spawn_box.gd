extends Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

signal spawn_box_destroyed

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		print("CHOQUE")
		emit_signal("spawn_box_destroyed")
		queue_free()
