extends Control

func _ready() -> void:
	GameManager.game_won.connect(func(): 
		visible = true
		GameManager.time_scale = 0.0
		GameManager.peacful_mode = true
		GameManager.levels_completed += 1)

func _on_continue_pressed() -> void:
	visible = false
	GameManager.time_scale = 1.0

func _on_next_pressed() -> void:
	GameManager.next_scene = "res://Scenes/level_selector.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
