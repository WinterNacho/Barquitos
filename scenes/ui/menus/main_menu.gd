class_name MainMenu
extends Control

@onready var play_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/PlayButton
@onready var credits_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/CreditsButton
@onready var quit_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuitButton

@onready var lobby_scene = preload("res://scenes/lobby.tscn") as PackedScene
@onready var credit_scene = preload("res://scenes/ui/menus/credits.tscn") as PackedScene
func _ready() -> void:
	play_button.button_down.connect(play)
	credits_button.button_down.connect(credits)
	quit_button.button_down.connect(quit)
	
func _process(delta: float) -> void:
	if Input.is_action_pressed("quit"):
		quit()
		
func play() -> void:
	get_tree().change_scene_to_packed(lobby_scene)
	
func credits() -> void:
	get_tree().change_scene_to_packed(credit_scene)
	
func quit() -> void:
	get_tree().quit()
