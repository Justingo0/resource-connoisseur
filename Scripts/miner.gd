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
var conveyorInterval = 0
var resources = 0
var resourceType = ""
@onready var ore_item = preload("res://Scenes/ore_item.tscn")
var minerSelf = self
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
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
		oreCount += 1
		mineTime = 4/oreCount

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Ore"):
		oreCount -= 1
		if oreCount > 0: mineTime = 4/oreCount
