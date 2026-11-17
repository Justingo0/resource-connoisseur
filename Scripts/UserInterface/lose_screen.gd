extends Control

func _on_try_again_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
