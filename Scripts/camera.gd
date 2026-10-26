extends Camera2D

@onready var build_cursor = $BuildCursor
@onready var delete_cursor = $DeleteCursor
@onready var mine_cursor = $DeleteCursor/MineCursor

@onready var player = %Player

var dissolve_shader = preload("res://Assets/Shader/dissolve_shader.tres")
var construct_shader = preload("res://Assets/Shader/construct_shader.tres")

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
var building_objects := []
var deleting_objects := []

var current_objects := []
var interacting_object = null
#var object_iteration := 0

enum actions {placing, deleting, moving}
var current_action
var object_action

var speed := 1.0

# PRIVATE SETTINGS
var GRID_SIZE = 64

var ZOOM_SPEED = 0.1
var MIN_ZOOM = 0.5
var MAX_ZOOM = 2.5

func _ready() -> void:
	set_build_cursor(building_object)
	#viewport_size = get_viewport().get_visible_rect().size

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
			pass
			#var viewport_size = get_viewport().get_visible_rect().size
			#position = (starting_cam_pos + (mouse_starting_pos - get_global_mouse_position()))#.clamp(Vector2(limit_left+viewport_size.x, limit_top+viewport_size.y), Vector2(limit_right-viewport_size.x, limit_bottom-viewport_size.y))
	
	if event.is_action_pressed("Place"):
		if object_action == actions.deleting and current_objects.size() > 0: return
		speed = 1.0
		current_action = actions.placing
		building = true
	if event.is_action_pressed("Delete"):
		#print(object_action == actions.placing and not current_objects.is_empty())
		#print(not building_objects.is_empty())
		#print((delete_cursor.get_overlapping_areas()+delete_cursor.get_overlapping_bodies()).is_empty())
		if object_action == actions.placing and not current_objects.is_empty(): return
		building_object = null
		if not building_objects.is_empty():
			for object in building_objects:
				object.queue_free()
			building_objects.clear()
			current_action = null
			return
		if (delete_cursor.get_overlapping_areas()+delete_cursor.get_overlapping_bodies()).is_empty():
			return
		current_action = actions.deleting
		building = true
		
		#building_object = null
		#build_cursor.modulate = Color.from_rgba8(255, 255, 255, 107)
		#
		#if object_action == actions.placing:
			#return
		#elif object_action == null and not current_objects.is_empty():
			#for object in current_objects:
				#object.queue_free()
			#current_objects.clear()
		#
		#current_action = actions.deleting
		#building = true

func _input(event: InputEvent) -> void:
	if event.is_action_released("Place"):
		if object_action == actions.deleting and current_objects.size() > 0: return
		
		build_cursor.modulate = Color.from_rgba8(255, 255, 255, 107)
		
		current_objects.append_array(building_objects)
		object_action = actions.placing
		
		building = false
		current_action = null
		last_object_built = null
		building_objects.clear()
	if event.is_action_released("Delete"):
		#print(object_action == actions.placing and current_objects.size() > 0)
		if object_action == actions.placing and not current_objects.is_empty(): return
		
		current_objects.append_array(deleting_objects)
		object_action = actions.deleting
		
		building = false
		current_action = null
		deleting_objects.clear()

func _physics_process(delta: float) -> void:
	if GameManager.time_scale <= 0.0:
		keyboard_movement(delta)
	else:
		position = Vector2.ZERO
	
	if building:
		if current_action == actions.placing:
			place(building_object)
		elif current_action == actions.deleting:
			delete()
	
	build_cursor.global_position = get_global_mouse_position().snapped(Vector2(GRID_SIZE, GRID_SIZE))
	delete_cursor.global_position = get_global_mouse_position().snapped(Vector2(GRID_SIZE, GRID_SIZE))
	
	if not current_objects.is_empty():
		#print("Has Current Objects")
		var object = current_objects[0]
		if not object:
			return
		interacting_object = object
		#print("Object exist")
		if object_action == actions.deleting:
			#print("Deleting ", current_objects)
			if "destroy_time" in object:
				object.destroy_time = max(object.destroy_time - delta*GameManager.time_scale*speed, 0)
				if not object.material:
					object.material = dissolve_shader.duplicate()
				object.material.set_shader_parameter("dissolve_progress", 1-object.destroy_time/object.max_destroy_time)
				if object.destroy_time == 0.0:
					object.queue_free()
					current_objects.erase(object)
			else:
				object.queue_free()
				current_objects.erase(object)
		elif object_action == actions.placing:
			if "destroy_time" in object:
				object.destroy_time = min(object.destroy_time + delta*GameManager.time_scale*speed, object.max_destroy_time)
				if not object.material:
					object.material = construct_shader.duplicate()
				object.material.set_shader_parameter("dissolve_progress", 1-object.destroy_time/object.max_destroy_time)
				if object.destroy_time == object.max_destroy_time:
					object.held = false
					object.modulate = Color.from_rgba8(255, 255, 255, 255)
					object.material = null
					current_objects.erase(object)
			else:
				object.queue_free()
				object.held = false
				object.modulate = Color.from_rgba8(255, 255, 255, 255)
				object.material = null
				current_objects.erase(object)

func keyboard_movement(delta):
	var moveVector = Input.get_vector("leftButton", "rightButton", "upButton", "downButton")
	#var viewport_size = get_viewport().get_visible_rect().size
	position += moveVector * 500 * delta

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
	if not building_object:
		var overlapping = mine_cursor.get_overlapping_areas()+mine_cursor.get_overlapping_bodies()
		if not overlapping.is_empty():
			var selectingOre = overlapping[0]
			if selectingOre and selectingOre.is_in_group("Ore"):
				player.give_action(player.actions.mining, selectingOre)
			else:
				player.give_action(player.actions.default, null)
		else:
			player.give_action(player.actions.default, null)
	if not object or not building_mode or dragging: return
	player.give_action(player.actions.default, null)
	if build_cursor.get_child(0).has_overlapping_areas() or build_cursor.get_child(0).has_overlapping_bodies():
		if last_object_built and last_object_built.is_in_group("Rotate") and build_cursor.global_position != last_object_built.global_position:
			var direction = last_object_built.global_position.direction_to(get_global_mouse_position())
			if abs(direction.x) > abs(direction.y):
				direction = Vector2(sign(direction.x), 0)
			else:
				direction = Vector2(0, sign(direction.y))
			last_object_built.rotation = deg_to_rad(rad_to_deg(direction.angle()) + 90)
		return
	
	#if not deleting_objects.is_empty():
		#for deleting_obj in deleting_objects:
			#if not deleting_obj: continue
			#deleting_obj.destroy_time = deleting_obj.max_destroy_time
			#deleting_obj.material = null
		#deleting_objects.clear()
	
	var placed_object = object.instantiate()
	get_tree().current_scene.add_child(placed_object)
	placed_object.held = true
	placed_object.destroy_time = 0
	placed_object.global_position = build_cursor.global_position
	#placed_object.material = construct_shader.duplicate()
	placed_object.modulate = Color.from_rgba8(255, 255, 255, 140)
	building_objects.append(placed_object)
	
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
		var deleting_object = objects[0] as Area2D
		if deleting_object.is_in_group("Block") and deleting_object.held == false and not deleting_object.is_in_group("Unbreakable"):
			if deleting_object in deleting_objects or deleting_object in current_objects: return
			#building_object = null
			deleting_object.destroy_time = deleting_object.max_destroy_time
			deleting_object.material = dissolve_shader.duplicate()
			deleting_objects.append(deleting_object)
	
	#current_action = actions.deleting
