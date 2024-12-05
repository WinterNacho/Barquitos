extends Label

@onready var playerName: String
@onready var player: CharacterBody3D
@onready var vida: int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



func set_player(node,player_data):
	player = node
	
	playerName = player_data.name
	print(playerName)
	self.text = playerName
	vida = player.max_health
	$Vida.text = str(vida)
	
func update_icon():
	var  current = player.actual_state
	match current:
		0:
			$State.texture = null
		1:
			$State.texture = preload("res://scenes/ui/HUD/snail.png")
		2:
			$State.texture = preload("res://scenes/ui/HUD/snowflake.png")
		3:
			$State.texture = preload("res://scenes/ui/HUD/confused.png")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player==null:
		self.visible = false
	else:
		update_icon()
		pass
		
	if vida:
		vida = player.current_health
		$Vida.text = str(vida)
	pass
	
	
