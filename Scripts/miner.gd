extends Area2D

@onready var driller_anim = $Drill/AnimationPlayer

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
	driller_anim.speed_scale = 0
	if !held:
		driller_anim.play("new_animation")

func _process(delta: float) -> void:
	time += delta*GameManager.time_scale
	if oreCount > 0 and time > mineTime:
		resources = min(resources + 1, 10)
		if resources > 0:
			output()
		time = 0
	if last_generated_item and selected_conveyor and (selected_conveyor.item == null): #or selected_conveyor.item_incoming == last_generated_item):
		last_generated_item.global_position = last_generated_item.global_position.move_toward(selected_conveyor.global_position, 400*delta*GameManager.time_scale)
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
		driller_anim.speed_scale = oreCount

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Ore"):
		resourcesUnderneath.erase(area.type.name)
		oreCount -= 1
		#print(resourcesUnderneath)
		if oreCount > 0: mineTime = int(4.0/oreCount)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if last_generated_item:
			last_generated_item.queue_free()
			selected_conveyor.item_incoming = null

func output():
	if not conveyors.is_empty() and resources > 0:
		selected_conveyor = conveyors[conveyorInterval%conveyors.size()]
		if selected_conveyor.item != null: #or selected_conveyor.item_incoming != null:
			for i in conveyors.size():
				conveyorInterval += 1
				selected_conveyor = conveyors[conveyorInterval%conveyors.size()]
				if selected_conveyor.item == null: return #or selected_conveyor.item_incoming == null: return
		if (selected_conveyor.item == null) and selected_conveyor.held == false and !held:
			if last_generated_item:
				last_generated_item.queue_free()
				last_generated_item = null
			last_generated_item = ore_item.instantiate()
			
			get_tree().current_scene.add_child(last_generated_item)
			conveyorInterval += 1
			resources -= 1
			
			selected_conveyor.item_incoming = last_generated_item
			
			var starting_pos = global_position
			if (selected_conveyor.global_position.y - global_position.y) == 64.0 or (selected_conveyor.global_position.y - global_position.y) == -128:
				#print((selected_conveyor.global_position.y - global_position.y), " - ", (selected_conveyor.global_position.y - global_position.y) > 0.0, " - From Bottom or Top")
				starting_pos.x = selected_conveyor.global_position.x
				if (selected_conveyor.global_position.y - global_position.y) == -128:
					starting_pos.y -= 64
			else:
				#print((selected_conveyor.global_position.y - global_position.y), " - ", (selected_conveyor.global_position.y - global_position.y) > 0.0, " - From Left or Right")
				starting_pos.y = selected_conveyor.global_position.y
				if (selected_conveyor.global_position.x - global_position.x) == -128:
					starting_pos.x -= 64
			
			last_generated_item.global_position = starting_pos #- (64 * global_position.direction_to(selected_conveyor.global_position))
