extends Label

@onready var vida: int
@onready var player: CharacterBody3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func set_player(node):
	player = node
	vida = player.current_health
	self.text = str(vida)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if vida:
		vida = player.current_health
		self.text = str(vida)
	pass
