class_name UILobbyPlayer
extends MarginContainer

@onready var player_name: Label = %Name
@onready var ready_texture: TextureRect = %Ready

var player: Statics.PlayerData


func _ready() -> void:
	ready_texture.hide()


func setup(value: Statics.PlayerData) -> void:
	player = value
	name = str(player.id)
	_update()
	Game.player_updated.connect(_on_player_updated)


func _on_player_updated(id: int) -> void:
	if id == player.id:
		_update()


func _update():
	_set_player_name(player.name)


func _set_player_name(value: String) -> void:
	player_name.text = value


func set_ready(value: bool) -> void:
	ready_texture.visible = value
