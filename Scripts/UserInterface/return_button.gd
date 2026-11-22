extends Button

func _pressed() -> void:
	GameManager.next_scene = "res://Scenes/main_menu.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
