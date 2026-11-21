@tool
extends TextureButton

@onready var camera = $"../../../../../../Player/Camera2D"
@onready var item_display = %ItemDisplay

@export var type:blockStats:
	set(new_val):
		type = new_val
		if type:
			texture_normal = type.icon

var hovering := false

func _ready() -> void:
	if type:
		texture_normal = type.icon

func _on_pressed() -> void:
	if not type: return
	camera.building_object_type = type
	camera.building_object = type.scene

func _on_mouse_entered() -> void:
	if not Engine.is_editor_hint():
		item_display.visible = true
		hovering = true
		item_display.position = global_position+(size/2)
		if is_ui_off_screen(item_display):
			item_display.position = global_position+(Vector2((-size.x*2)-10, size.y/2))
		
		item_display.get_node("Name").text = str(type.name)
		item_display.get_node("Description").text = str(type.description)
		for child in item_display.get_node("BuildCost").get_children():
			child.queue_free()
		for item in type.buildCosts.keys():
			var value = type.buildCosts[item]
			var template = item_display.get_node("Template").duplicate()
			var item_type = load("res://Resources/Data/Items/Raw%s.tres" % [item] if OreStats.isOre(item) else "res://Resources/Data/Items/%s.tres" % [item])
			item_display.get_node("BuildCost").add_child(template)
			template.visible = true
			template.get_node("Amount").text = str(value) + "x"
			template.get_node("TextureRect").texture = item_type.icon

func _on_mouse_exited() -> void:
	if not Engine.is_editor_hint():
		item_display.visible = false
		hovering = false

func is_ui_off_screen(control: Control) -> bool:
	var screen_rect := control.get_viewport_rect()
	var ui_rect := control.get_global_rect()
	return not screen_rect.encloses(ui_rect)
