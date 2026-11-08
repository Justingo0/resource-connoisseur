extends Area2D
signal inventory_changed(value:int)

@export var inventory_size:int

@onready var timer = $ProductionTimer

@export var type:blockStats

@export var inputItem:Dictionary

@export var outputItem:OreStats

@export var inventory = {}:
	set(new_val):
		inventory = new_val
		GameManager.core_inventory = inventory

@export var max_destroy_time:float
@export var destroy_time:float

@export var held:bool

@export var health = 200

var conveyorInterval = 0
var last_output_item = null
var last_generated_item = null
var selected_conveyor = null
@export var output_conveyor = null

@onready var outputType = preload("res://Scenes/ore_item.tscn")

var resources = 0
@export var conveyors = []:
	set(newValue):
		conveyors = newValue
		#print(conveyors)
	get:
		return conveyors

func get_disabled() -> bool:
	if destroy_time == max_destroy_time and held == false:
		return false
	return true

func _ready() -> void:
	if type:
		inventory_size = type.inventory_size
		timer.wait_time = type.production_time
		inputItem = type.input
		outputItem = type.output

func _physics_process(delta: float) -> void:
	if inventory.keys().size() > 0 and resources != inventory_size:
		if inventory[inventory.keys()[0]] == 0:
			inventory.erase(inventory.keys()[0])
		if inventory.keys().size() > 1:
			if inventory[inventory.keys()[1]] == 0:
				inventory.erase(inventory.keys()[1])
	if get_disabled(): return
	if last_output_item:
		last_output_item.global_position = last_output_item.global_position.move_toward(output_conveyor.global_position, 400*delta*GameManager.time_scale)
		if last_output_item.global_position == output_conveyor.global_position:
			output_conveyor.item = last_output_item
			output_conveyor.item_incoming = null
			last_output_item = null
			output_conveyor = null
	output()

func output():
	if not conveyors.is_empty() and resources > 0 and not last_output_item:
		selected_conveyor = conveyors[conveyorInterval%conveyors.size()]
		if not selected_conveyor or selected_conveyor.held or ("output_conveyor" in selected_conveyor and selected_conveyor.output_conveyor == self):
			#conveyors.erase(output_conveyor)
			selected_conveyor = null
			for conveyor in conveyors:
				if conveyor and conveyor.held == false and ("output_conveyor" in conveyor and conveyor.output_conveyor != self):
					selected_conveyor = conveyor
					break
			if not selected_conveyor: return
		if selected_conveyor.is_in_group("Conveyor"):
			if selected_conveyor.item != null: #or selected_conveyor.item_incoming != null:
				for i in conveyors.size():
					conveyorInterval += 1
					selected_conveyor = conveyors[conveyorInterval%conveyors.size()]
					if selected_conveyor.item == null: return #or selected_conveyor.item_incoming == null: return
			if (selected_conveyor.item == null) and selected_conveyor.held == false and !held:
				last_generated_item = outputType.instantiate()
				last_generated_item.itemType = type.output.name
				get_tree().current_scene.add_child(last_generated_item)
				last_generated_item.setProperties()
				last_output_item = last_generated_item
				output_conveyor = selected_conveyor
				conveyorInterval += 1
				resources -= 1
				
				selected_conveyor.item_incoming = last_generated_item
				
				var starting_pos = global_position
				if (selected_conveyor.global_position.y - global_position.y) == 64.0 or (selected_conveyor.global_position.y - global_position.y) == -128:
					starting_pos.x = selected_conveyor.global_position.x
					if (selected_conveyor.global_position.y - global_position.y) == -128:
						starting_pos.y -= 64
				else:
					starting_pos.y = selected_conveyor.global_position.y
					if (selected_conveyor.global_position.x - global_position.x) == -128:
						starting_pos.x -= 64
				
				last_generated_item.global_position = starting_pos #- (64 * global_position.direction_to(selected_conveyor.global_position))
		elif selected_conveyor.is_in_group("Container"):
			var size = 0
			for value in selected_conveyor.inventory.values():
				size += value
			if size >= selected_conveyor.inventory_size: return
			
			conveyorInterval += 1
			resources -= 1
			
			if not (outputType in selected_conveyor.inventory.keys()):
				selected_conveyor.inventory[outputType] = 0
			selected_conveyor.inventory[outputType] += 1
			selected_conveyor.inventory = selected_conveyor.inventory

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		queue_free()

func _on_conveyor_detector_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Conveyor") or area.is_in_group("Container")) and area.held == false and area != self:
		if not held:
			pass
			#print(area, " from ", self)
		conveyors.append(area)
		conveyors = conveyors
		output()

func _on_conveyor_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Conveyor") or area.is_in_group("Container") and area in conveyors:
		conveyors.erase(area)
		conveyors = conveyors

func _on_production_timer_timeout() -> void:
	if inventory.keys().size() > 0 and resources != inventory_size:
		if inputItem.size() == 2 and inventory[inventory.keys()[0]] >= inputItem.keys()[0] and inventory[inventory.keys()[1]] >= inputItem.keys()[1]:
			resources = min(resources + 1, 10)
		elif inventory[inventory.keys()[0]] >= inputItem.values()[0]:
			inventory[inventory.keys()[0]] -= inputItem.values()[0]
			resources = min(resources + 1, 10)

func _notification(notif: int) -> void:
	if notif == NOTIFICATION_PREDELETE:
		if last_output_item:
			last_output_item.queue_free()
			output_conveyor.item_incoming = null
