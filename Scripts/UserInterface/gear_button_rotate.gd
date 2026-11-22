extends Button

@export_file() var map_scene:String
@export var map_icon:Texture2D
@export var map_name:String

var tween:Tween

func _ready() -> void:
	if GameManager.levels_completed < int(name)-1:
		disabled = true
	else:
		disabled = false
	
	if disabled:
		$TextureRect2/Gear2.speed = 0.0
		$Lock.visible = true
		$TextureRect.modulate = Color(0.406, 0.406, 0.406, 1.0)
	$Panel/Label.text = map_name
	$TextureRect.texture = map_icon
	if GameManager.levels_completed >= int(name):
		$TextureRect2.texture = load("res://Assets/UI/TabsIcons/CheckMark.png")
	else:
		$TextureRect2.texture = load("res://Assets/UI/TabsIcons/Walls.png")
	
	offset_transform_enabled = true
	mouse_entered.connect(func():
		if disabled: return
		if tween and tween.is_valid():
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "offset_transform_scale", Vector2(1.05, 1.05), 0.1)
		)
	mouse_exited.connect(func():
		if disabled: return
		if tween and tween.is_valid():
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.1)
		)
	button_down.connect(func():
		if disabled: return
		if tween and tween.is_valid():
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "offset_transform_scale", Vector2(0.95, 0.95), 0.1)
		)
	button_up.connect(func():
		if disabled: return
		if tween and tween.is_valid():
			tween.kill()
		tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(self, "offset_transform_scale", Vector2(1, 1), 0.1)
		)

func _pressed() -> void:
	if not map_scene: return
	GameManager.next_scene = map_scene
	get_tree().change_scene_to_file("res://Scenes/loading_screen.tscn")
