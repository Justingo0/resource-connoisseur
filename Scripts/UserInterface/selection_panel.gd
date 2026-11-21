extends Panel

@onready var selections_tab = $"../SelectionMenu/Selections"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Delete"):
		visible = false

func _ready() -> void:
	visible = false

func _process(_delta: float) -> void:
	if selections_tab.visible:
		offset_transform_position = Vector2(0,-216)
	else:
		offset_transform_position = Vector2(0,0)
