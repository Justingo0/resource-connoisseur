extends Camera2D

@onready var build_cursor = $BuildCursor
@onready var delete_cursor = $DeleteCursor

var dissolve_shader = preload("res://Assets/Shader/dissolve_shader.tres")

var mouse_starting_pos := Vector2.ZERO
var starting_cam_pos := Vector2.ZERO
var dragging := false

var building_mode := false
var building := false
var building_object:PackedScene: #= preload("res://Scenes/conveyor.tscn"):
	set(new_object):
		building_object = new_object
		set_build_cursor(building_object)
	get:
		return building_object
var last_object_built = null
var deleting_objects = []

enum actions {placing, deleting, moving}
var current_action

# PRIVATE SETTINGS
var GRID_SIZE = 64

var ZOOM_SPEED = 0.1
var MIN_ZOOM = 0.5
var MAX_ZOOM = 2.5

func _ready() -> void:
	set_build_cursor(building_object)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if ((event.button_index == MOUSE_BUTTON_LEFT and not building_mode) or event.button_index == MOUSE_BUTTON_MIDDLE) and event.is_pressed():
			mouse_starting_pos = get_global_mouse_position()
			starting_cam_pos = position
			dragging = true
			current_action = actions.moving
		if ((event.button_index == MOUSE_BUTTON_LEFT and not building_mode) or event.button_index == MOUSE_BUTTON_MIDDLE) and event.is_released():
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
	
	if event.is_action_pressed("Cancel"):
		for object in deleting_objects:
			if not object: continue
			object.destroy_time = object.max_destroy_time
			object.material = null
		deleting_objects.clear()
	
	if event.is_action_pressed("Place"):
		current_action = actions.placing
		building = true
	if event.is_action_pressed("Delete"):
		current_action = actions.deleting
		building = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("Place"):
		building = false
		current_action = null
		last_object_built = null
	if event.is_action_released("Delete"):
		building = false
		current_action = null

func _physics_process(delta: float) -> void:
	keyboard_movement(delta)
	#if get_viewport().gui_get_hovered_control() == null:
		#if Input.is_action_pressed("Place"):
			#place(building_object)
		#if Input.is_action_pressed("Delete"):
			#delete()
	
	if building:
		if current_action == actions.placing:
			place(building_object)
		elif current_action == actions.deleting:
			delete()
	
	if not deleting_objects.is_empty():
		for object in deleting_objects:
			if not object: continue
			if "destroy_time" in object:
				object.destroy_time = max(object.destroy_time - delta*GameManager.time_scale, 0)
				object.material.set_shader_parameter("dissolve_progress", 1-object.destroy_time/object.max_destroy_time)
				if object.destroy_time == 0:
					object.queue_free()
			else:
				object.queue_free()
	
	build_cursor.global_position = get_global_mouse_position().snapped(Vector2(GRID_SIZE, GRID_SIZE))
	delete_cursor.global_position = get_global_mouse_position().snapped(Vector2(GRID_SIZE, GRID_SIZE))

func keyboard_movement(delta):
	var moveVector = Input.get_vector("leftButton", "rightButton", "upButton", "downButton")
	global_position += moveVector * 500 * delta

func set_build_cursor(object:PackedScene):
	for child in build_cursor.get_children():
		child.queue_free()
	
	if not object:
		building_mode = false
		return
	building_mode = true
	
	var highlight = object.instantiate() as Area2D
	highlight.collision_layer = 0
	highlight.collision_mask = 1
	build_cursor.add_child(highlight)
	highlight.position = Vector2.ZERO
	
	if "held" in highlight:
		highlight.held = true

func place(object:PackedScene):
	if not object or not building_mode or dragging: return
	
	if build_cursor.get_child(0).has_overlapping_areas() or build_cursor.get_child(0).has_overlapping_bodies():
		if last_object_built and last_object_built.is_in_group("Rotate") and build_cursor.global_position != last_object_built.global_position:
			var direction = last_object_built.global_position.direction_to(get_global_mouse_position())
			if abs(direction.x) > abs(direction.y):
				direction = Vector2(sign(direction.x), 0)
			else:
				direction = Vector2(0, sign(direction.y))
			last_object_built.rotation = deg_to_rad(rad_to_deg(direction.angle()) + 90)
		return
	
	if not deleting_objects.is_empty():
		for deleting_obj in deleting_objects:
			if not deleting_obj: continue
			deleting_obj.destroy_time = deleting_obj.max_destroy_time
			deleting_obj.material = null
		deleting_objects.clear()
	
	var placed_object = object.instantiate()
	get_tree().current_scene.add_child(placed_object)
	placed_object.global_position = build_cursor.global_position
	
	if last_object_built and last_object_built.is_in_group("Rotate"):
		var direction = last_object_built.global_position.direction_to(placed_object.global_position)
		if abs(direction.x) > abs(direction.y):
			direction = Vector2(sign(direction.x), 0)
		else:
			direction = Vector2(0, sign(direction.y))
		last_object_built.rotation = deg_to_rad(rad_to_deg(direction.angle()) + 90)
		placed_object.rotation = deg_to_rad(rad_to_deg(direction.angle()) + 90)
	last_object_built = placed_object
	
	#current_action = actions.placing

func delete():
	if dragging: return
	var objects = delete_cursor.get_overlapping_areas()+delete_cursor.get_overlapping_bodies()
	if not objects.is_empty(): 
		var deleting_object = objects[0]
		if deleting_object.is_in_group("Block") and not deleting_object.is_in_group("Unbreakable"):
			if deleting_object in deleting_objects: return
			#building_object = null
			deleting_object.destroy_time = deleting_object.max_destroy_time
			deleting_object.material = dissolve_shader.duplicate()
			deleting_objects.append(deleting_object)
	
	#current_action = actions.deleting
