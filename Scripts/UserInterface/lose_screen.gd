extends Control

func _on_try_again_pressed() -> void:
	GameManager.next_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")

func _on_main_menu_pressed() -> void:
	GameManager.next_scene = "res://Scenes/main_menu.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
