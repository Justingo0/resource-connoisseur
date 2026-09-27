extends Control

@onready var camera = $"../../Camera2D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_button_pressed() -> void:
	camera.building_object = load("res://Scenes/miner.tscn")
	# I want to set the buildcursor building to miner

func _on_button_2_pressed() -> void:
	camera.building_object = load("res://Scenes/conveyor.tscn")
	# I want to set the buildcursor building to conveyor

func _on_button_3_pressed() -> void:
	camera.building_object = load("res://Scenes/home.tscn")
	# I want to set the buildcursor building to core

func _on_button_4_pressed() -> void:
	camera.building_object = null
	# I want to set the buildcursor building to clear
