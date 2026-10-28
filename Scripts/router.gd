extends Area2D

var health = 50

signal inventory_changed(value:int)

@onready var ore_item = preload("res://Scenes/ore_item.tscn")

@onready var output_timer = $OutputTimer

@export var inventory = {}:
	set(new_val):
		inventory = new_val
		inventory_changed.emit(inventory[inventory.keys()[0]])
	get:
		return inventory
@export var inventory_size:int

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool

var last_output_item = null
@export var output_conveyor = null

var conveyors = []:
	set(newValue):
		conveyors = newValue
		#print(conveyors)
	get:
		return conveyors
var conveyor_interval = 0

func get_disabled() -> bool:
	if destroy_time == max_destroy_time and held == false:
		return true
	return false

func _on_conveyor_detector_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Conveyor") or area.is_in_group("Container")) and area.held == false and area != self:
		if area in conveyors: return
		if not held:
			print(area, " from ", self)
		conveyors.append(area)
		conveyors = conveyors
		deposit()

func _on_conveyor_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Conveyor") or area.is_in_group("Container") and area in conveyors:
		conveyors.erase(area)
		conveyors = conveyors

func _physics_process(delta: float) -> void:
	if get_disabled(): return
	if last_output_item:
		last_output_item.global_position = last_output_item.global_position.move_toward(output_conveyor.global_position, 400*delta*GameManager.time_scale)
		if last_output_item.global_position == output_conveyor.global_position:
			output_conveyor.item = last_output_item
			output_conveyor.item_incoming = null
			last_output_item = null
			output_conveyor = null

func take_damage(damage: int) -> void:
	if !get_disabled():
		health -= damage
		if health < 1:
			queue_free()

func deposit():
	if get_disabled(): return
	if conveyors.is_empty() or inventory.keys().size() == 0 or inventory.values()[0] <= 0: return
	
	conveyor_interval += 1
	#print(conveyor_interval%conveyors.size())
	output_conveyor = conveyors[conveyor_interval%conveyors.size()]
	if not output_conveyor: #or ("output_conveyor" in output_conveyor and output_conveyor.output_conveyor == self):
		conveyors.erase(output_conveyor)
		output_conveyor = null
		for convey in conveyors:
			if convey: #and ("output_conveyor" in convey and convey.output_conveyor != self):
				output_conveyor = convey
				break
		if not output_conveyor: return
	#print(output_conveyor)
	#print("Where am i")
	
	var conveyor_ray = output_conveyor.get_node("RayCast")
	if conveyor_ray and conveyor_ray.is_colliding() and conveyor_ray.get_collider() == self:
		conveyors.erase(output_conveyor)
		deposit()
		return
	
	#print(output_conveyor.item == null and output_conveyor.held == false and !held)
	if output_conveyor.is_in_group("Conveyor"):
		if output_conveyor.item == null and output_conveyor.held == false and !held:
			last_output_item = ore_item.instantiate()
			last_output_item.itemType = inventory.keys()[0]
			get_tree().current_scene.call_deferred('add_child', last_output_item)
			
			var starting_pos = global_position
			
			last_output_item.global_position = starting_pos
			output_conveyor.item_incoming = last_output_item
		else:
			return
	elif output_conveyor.is_in_group("Container"):
		var size = 0
		for value in output_conveyor.inventory.values():
			size += value
		if size >= output_conveyor.inventory_size:
			conveyors.erase(output_conveyor)
			deposit()
			return
		output_conveyor.inventory[inventory.keys()[0]] += 1
		output_conveyor.inventory = output_conveyor.inventory
	else:
		return
	inventory[inventory.keys()[0]] -= 1
	inventory = inventory

func _on_inventory_changed(value: int) -> void:
	if value > 0:
		if output_timer.is_stopped():
			deposit()
			output_timer.start()
	else:
		output_timer.stop()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if last_output_item:
			last_output_item.queue_free()
			output_conveyor.item_incoming = null

func _on_output_timer_timeout() -> void:
	deposit()
