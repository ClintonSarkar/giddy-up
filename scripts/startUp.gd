extends Node

@onready var start_button = $start
@onready var quit_button = $quit

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	return

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/levels.tscn")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	return

func _on_quit_pressed():
	get_tree().quit()
	return
