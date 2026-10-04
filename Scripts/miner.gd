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
			var newItem = ore_item.instantiate()
			get_tree().current_scene.add_child(newItem)
			conveyorInterval += 1
			resources -= 1
			newItem.global_position = conveyors[selectedConveyor].global_position
			conveyors[selectedConveyor].item = newItem

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
