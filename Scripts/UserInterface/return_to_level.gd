extends Control

func _ready() -> void:
	visible = false

func _on_try_again_pressed() -> void:
	visible = false
	GameManager.time_scale = 1.0

func _on_main_menu_pressed() -> void:
	GameManager.next_scene = "res://Scenes/level_selector.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
