extends Control

@onready var main_menu = "res://scenes/ui/menus/main_menu.tscn"
@onready var back_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/BackButton

func _ready() -> void:
	back_button.button_down.connect(back)

func _process(delta: float) -> void:
	pass

func back() -> void:
	get_tree().change_scene_to_file(main_menu)
