extends Button

func _ready() -> void:
	mouse_entered.connect(hover)
	mouse_exited.connect(exit)

func _pressed() -> void:
	call(str(name).to_lower())

func play():
	get_tree().change_scene_to_file("res://Scenes/test_scene.tscn")

func settings():
	print("OH SO YOU WANT TO CHANGE SETTINGS!?!?!?")

func quit():
	get_tree().quit()

func hover():
	var tween = create_tween()
	tween.tween_property(self, "offset_transform_scale", Vector2(1.1,1.1), 0.1)

func exit():
	var tween = create_tween()
	tween.tween_property(self, "offset_transform_scale", Vector2(1,1), 0.1)
