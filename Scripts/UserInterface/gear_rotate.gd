extends TextureRect

@export_enum("Clockwise:1","Counter-Clockwise:-1") var direction = -1

var speed := 1

func _ready() -> void:
	offset_transform_enabled = true
	mouse_entered.connect(func():
		var tween = create_tween()
		tween.tween_property(self, "offset_transform_scale", Vector2(1.1, 1.1), 0.1)
		)
	mouse_exited.connect(func():
		var tween = create_tween()
		tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.1)
		)

func _process(delta: float) -> void:
	rotation += direction * speed * delta
