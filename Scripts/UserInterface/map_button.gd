extends Button

func _pressed() -> void:
	$"../ReturnToLevel".visible = true
	GameManager.time_scale = 0.0
