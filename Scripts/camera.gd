extends Camera2D

@onready var build_cursor = $BuildCursor

var mouse_starting_pos := Vector2.ZERO
var starting_cam_pos := Vector2.ZERO
var dragging := false

var building := false
var building_object:PackedScene = preload("res://Scenes/conveyor.tscn"):
	set(new_object):
		building_object = new_object
		set_build_cursor(building_object)
	get:
		return building_object
var last_object_built = null

enum actions {placing, deleting, moving}
var current_action

# PRIVATE SETTINGS
var GRID_SIZE = 64

var ZOOM_SPEED = 0.1
var MIN_ZOOM = 0.5
var MAX_ZOOM = 2

func _ready() -> void:
	set_build_cursor(building_object)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if ((event.button_index == MOUSE_BUTTON_LEFT and not building) or event.button_index == MOUSE_BUTTON_MIDDLE) and event.is_pressed():
			mouse_starting_pos = get_global_mouse_position()
			starting_cam_pos = position
			dragging = true
			current_action = actions.moving
		if ((event.button_index == MOUSE_BUTTON_LEFT and not building) or event.button_index == MOUSE_BUTTON_MIDDLE) and event.is_released():
			dragging = false
			current_action = null
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = clamp(zoom + Vector2(ZOOM_SPEED, ZOOM_SPEED), Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = clamp(zoom - Vector2(ZOOM_SPEED, ZOOM_SPEED), Vector2(MIN_ZOOM, MIN_ZOOM), Vector2(MAX_ZOOM, MAX_ZOOM))
	elif event is InputEventMouseMotion:
		if dragging:
			var viewport_size = get_viewport().get_visible_rect().size
			position = (starting_cam_pos + (mouse_starting_pos - get_global_mouse_position())).clamp(Vector2(limit_left+viewport_size.x, limit_top+viewport_size.y), Vector2(limit_right-viewport_size.x, limit_bottom-viewport_size.y))
	if event.is_action_released("Place"):
		current_action = null
		last_object_built = null
	if event.is_action_released("Delete"):
		current_action = null

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("Place"):
		place(building_object)
	if Input.is_action_pressed("Delete"):
		delete()
	build_cursor.global_position = get_global_mouse_position().snapped(Vector2(64, 64))

func set_build_cursor(object:PackedScene):
	for child in build_cursor.get_children():
		child.queue_free()
	
	if not object:
		building = false
		return
	building = true
	
	var highlight = object.instantiate()
	build_cursor.add_child(highlight)
	highlight.position = Vector2.ZERO
	
	if "held" in highlight:
		highlight.held = true

func place(object:PackedScene):
	if not object or not building or dragging: return
	if build_cursor.get_child(0).has_overlapping_areas() or build_cursor.get_child(0).has_overlapping_bodies():
		if last_object_built and build_cursor.global_position != last_object_built.global_position:
			var direction = last_object_built.global_position.direction_to(get_global_mouse_position())
			if abs(direction.x) > abs(direction.y):
				direction = Vector2(sign(direction.x), 0)
			else:
				direction = Vector2(0, sign(direction.y))
			last_object_built.rotation = deg_to_rad(rad_to_deg(direction.angle()) + 90)
		return
	
	
	var placed_object = object.instantiate()
	get_tree().current_scene.add_child(placed_object)
	placed_object.global_position = build_cursor.global_position
	
	if last_object_built:
		var direction = last_object_built.global_position.direction_to(placed_object.global_position)
		if abs(direction.x) > abs(direction.y):
			direction = Vector2(sign(direction.x), 0)
		else:
			direction = Vector2(0, sign(direction.y))
		last_object_built.rotation = deg_to_rad(rad_to_deg(direction.angle()) + 90)
		placed_object.rotation = deg_to_rad(rad_to_deg(direction.angle()) + 90)
	last_object_built = placed_object
	
	current_action = actions.placing

func delete():
	if not building or dragging: return
	var deleting_objects = []
	deleting_objects.append_array(build_cursor.get_child(0).get_overlapping_bodies())
	deleting_objects.append_array(build_cursor.get_child(0).get_overlapping_areas())
	if len(deleting_objects) >= 1:
		if deleting_objects[0].is_in_group("Block"):
			deleting_objects[0].queue_free()
	
	current_action = actions.deleting
