extends Area2D

var oreCount = 0
var mineTime = 0
var time = 0
@export var held:bool = false
@export var conveyors = []:
	set(newValue):
		conveyors = newValue
		#print(conveyors)
	get:
		return conveyors

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

var conveyorInterval = 0
var resources = 0
var resourcesUnderneath = []
var resourceInterval = 0
@onready var ore_item = preload("res://Scenes/ore_item.tscn")
var minerSelf = self

var last_generated_item = null
var selected_conveyor = null

func _ready() -> void:
	$Sprite2D2/AnimationPlayer.speed_scale = 0

func _process(delta: float) -> void:
	if !held:
		$Sprite2D2/AnimationPlayer.play("new_animation")
	time += delta*GameManager.time_scale
	if oreCount > 0 and time > mineTime:
		resources = min(resources + 1, 10)
		time = 0
	if not conveyors.is_empty() and resources > 0:
		var selectedConveyor = conveyorInterval%conveyors.size()
		if conveyors[selectedConveyor].item == null and conveyors[selectedConveyor].held == false and !held:
			last_generated_item = ore_item.instantiate()
			selected_conveyor = conveyors[selectedConveyor]
			
			get_tree().current_scene.add_child(last_generated_item)
			conveyorInterval += 1
			resources -= 1
			
			var starting_pos = global_position
			
			if (selected_conveyor.global_position.y - global_position.y) == 64.0 or (selected_conveyor.global_position.y - global_position.y) == -128:
				print((selected_conveyor.global_position.y - global_position.y), " - ", (selected_conveyor.global_position.y - global_position.y) > 0.0, " - From Bottom or Top")
				starting_pos.x = selected_conveyor.global_position.x + (64 - (64 * signf(selected_conveyor.global_position.x)))
				starting_pos.y 
			else:
				print((selected_conveyor.global_position.y - global_position.y), " - ", (selected_conveyor.global_position.y - global_position.y) > 0.0, " - From Left or Right")
				starting_pos.y = selected_conveyor.global_position.x + (64 * signf(selected_conveyor.global_position.x))
			
			last_generated_item.global_position = starting_pos #- (64 * global_position.direction_to(selected_conveyor.global_position))
	if last_generated_item:
		last_generated_item.global_position = last_generated_item.global_position.move_toward(selected_conveyor.global_position, 200*delta*GameManager.time_scale)
		selected_conveyor.item_incoming = last_generated_item
		if last_generated_item.global_position == selected_conveyor.global_position:
			selected_conveyor.item = last_generated_item
			selected_conveyor.item_incoming = null
			last_generated_item = null
			selected_conveyor = null

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Conveyor"):
		conveyors.append(area)
		conveyors = conveyors

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Conveyor"):
		conveyors.erase(area)
		conveyors = conveyors

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Ore"):
		resourcesUnderneath.append(area.type.name)
		oreCount += 1
		#print(resourcesUnderneath)
		mineTime = int(4.0/oreCount)
		$Sprite2D2/AnimationPlayer.speed_scale = oreCount

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Ore"):
		resourcesUnderneath.erase(area.type.name)
		oreCount -= 1
		#print(resourcesUnderneath)
		if oreCount > 0: mineTime = int(4.0/oreCount)
