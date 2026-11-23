extends Area2D
signal inventory_changed(value:int)

@onready var death_particle = $DeathParticle

@export var inventory_size:int

@onready var timer = $ProductionTimer

@export var type:factoryStats

@export var inputItem:Dictionary

@export var outputItem:itemStats

@export var inventory := {}:
	set(new_val):
		inventory = new_val
		print(inventory ," from Main")
@export var inventory_2 := {}:
	set(new_val):
		inventory_2 = new_val
		print(inventory_2 ," from Secondary")

@export var max_destroy_time:float
@export var destroy_time:float

@export var held:bool

@export var max_health:int
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
	get:
		return conveyors

func get_disabled() -> bool:
	if destroy_time == max_destroy_time and held == false:
		return false
	return true

func _ready() -> void:
	max_health = health
	if type:
		inventory_size = type.inventory_size
		timer.wait_time = type.production_time
		inputItem = type.input
		outputItem = type.output
		$Sprite2D.texture = type.icon

func _physics_process(delta: float) -> void:
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
	if not can_output(): return
	if not conveyors.is_empty() and resources > 0 and not last_output_item:
		selected_conveyor = conveyors[conveyorInterval%conveyors.size()]
		conveyorInterval += 1
		if not selected_conveyor or selected_conveyor.get_disabled() or ("output_conveyor" in selected_conveyor and selected_conveyor.output_conveyor == self):
			#conveyors.erase(output_conveyor)
			selected_conveyor = null
			for conveyor in conveyors:
				if conveyor and conveyor.get_disabled() == false and ("output_conveyor" in conveyor and conveyor.output_conveyor != self):
					selected_conveyor = conveyor
					break
			if not selected_conveyor: return
		if selected_conveyor.is_in_group("Conveyor"):
			if selected_conveyor.item != null: #or selected_conveyor.item_incoming != null:
				for i in conveyors.size():
					selected_conveyor = conveyors[conveyorInterval%conveyors.size()]
					if selected_conveyor.is_in_group("Conveyor") and selected_conveyor.item == null: return #or selected_conveyor.item_incoming == null: return
			if (selected_conveyor.item == null) and selected_conveyor.held == false and !held:
				last_generated_item = outputType.instantiate()
				last_generated_item.itemType = type.output.name
				get_tree().current_scene.add_child(last_generated_item)
				last_generated_item.setProperties()
				last_output_item = last_generated_item
				output_conveyor = selected_conveyor
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
			if "inputItem" in selected_conveyor and not outputItem.name in selected_conveyor.inputItem.keys()[0]:
				if "inputItem" in selected_conveyor and selected_conveyor.inputItem.size() >= 2 and not outputItem.name in selected_conveyor.inputItem.keys()[1]:
					return
				elif "inputItem" in selected_conveyor and selected_conveyor.inputItem.size() == 1:
					return
			var size = 0
			for value in selected_conveyor.inventory.values():
				size += value
			if size >= selected_conveyor.inventory_size:
				if "inputItem" in selected_conveyor and selected_conveyor.inputItem.size() == 2 and outputItem.name == selected_conveyor.inputItem.keys()[1]:
					var size_2 = 0
					for value in selected_conveyor.inventory_2.values():
						size_2 += value
					if size_2 >= selected_conveyor.inventory_size: return
				else:
					return
			resources -= 1
			if "inputItem" in selected_conveyor and selected_conveyor.inputItem.size() == 2 and outputItem.name == selected_conveyor.inputItem.keys()[1]:
				if not (outputItem.name in selected_conveyor.inventory_2.keys()):
					selected_conveyor.inventory_2[outputItem.name] = 0
				selected_conveyor.inventory_2[outputItem.name] += 1
				selected_conveyor.inventory_2 = selected_conveyor.inventory_2
				return
			
			if not (outputItem.name in selected_conveyor.inventory.keys()):
				selected_conveyor.inventory[outputItem.name] = 0
			selected_conveyor.inventory[outputItem.name] += 1
			selected_conveyor.inventory = selected_conveyor.inventory

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		GameManager.screen_shake.emit(0.1, 6)
		death_particle.emitting = true
		remove_child(death_particle)
		get_tree().current_scene.add_child(death_particle)
		death_particle.global_position = global_position
		queue_free()

func _on_conveyor_detector_area_entered(area: Area2D) -> void:
	if (area.is_in_group("Conveyor") or area.is_in_group("Container")) and area.held == false and area != self:
		conveyors.append(area)
		conveyors = conveyors
		output()

func _on_conveyor_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Conveyor") or area.is_in_group("Container") and area in conveyors:
		conveyors.erase(area)
		conveyors = conveyors

func _on_production_timer_timeout() -> void:
	check_conveyors()
	if can_output():
		inventory[inventory.keys()[0]] -= inputItem.values()[0]
		inventory = inventory
		if inventory.values()[0] <= 0:
			inventory.erase(inventory.keys()[0])
			inventory = inventory
		if inputItem.size() == 2:
			inventory_2[inventory_2.keys()[0]] -= inputItem.values()[1]
			inventory_2 = inventory_2
			if inventory_2.values()[0] <= 0:
				inventory_2.erase(inventory_2.keys()[0])
				inventory_2 = inventory_2
		resources = min(resources + 1, type.inventory_size)

func check_conveyors():
	for conveyor in conveyors:
		if "output_conveyor" in conveyor:
			if conveyor.output_conveyor == self:
				conveyors.erase(conveyor)

func can_output() -> bool:
	if resources == inventory_size or conveyors.is_empty():
		return false
	if inventory.is_empty() or (inputItem.size() >= 2 and inventory_2.is_empty()):
		return false
	if inputItem.size() >= 1 and inventory[inventory.keys()[0]] >= inputItem.values()[0]:
		if inputItem.size() >= 2 and inventory_2[inventory_2.keys()[0]] < inputItem.values()[1]:
			return false
	elif inputItem.size() >= 1 and inventory[inventory.keys()[0]] < inputItem.values()[0]:
		return false
	return true

func _notification(notif: int) -> void:
	if notif == NOTIFICATION_PREDELETE:
		if last_output_item:
			last_output_item.queue_free()
			output_conveyor.item_incoming = null
