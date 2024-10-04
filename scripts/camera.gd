extends Node3D
@export var cameratarget: Node3D
@export var pitch_max = -10
@export var pitch_min =-90

var yaw = float()
var pitch = float()
var yaw_sensitivity = .002
var pitch_sensitivity = .002

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() != 0:
		yaw -= event.relative.x * yaw_sensitivity
		pitch -= event.relative.y * pitch_sensitivity


func _physics_process(delta: float) -> void:
	cameratarget.rotation.y = lerpf(cameratarget.rotation.y,yaw,delta*10)
	cameratarget.rotation.x = lerpf(cameratarget.rotation.x,pitch,delta*10)
	pitch = clamp(pitch, deg_to_rad(pitch_min),deg_to_rad(pitch_max))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
