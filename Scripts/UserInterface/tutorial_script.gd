extends Control

signal any_key_pressed

@onready var tutorial = $"."
@onready var pulse_effect = preload("res://Assets/Shader/UI/color_pulse.tres")

@onready var camera = $"../../../Player/Camera2D"

@export var actions:Dictionary ##First value is the action object and the second is the actions resource.

var iteration:int = 0

func _ready() -> void:
	for tip in tutorial.get_children():
		tip.visible = false
	start_iteration()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		any_key_pressed.emit()

func start_iteration():
	if iteration > 0 and not actions.keys()[iteration-1] is int:
		tutorial.get_child(iteration-1).visible = false
		get_node(actions.keys()[iteration-1]).offset_transform_enabled = false
		get_node(actions.keys()[iteration-1]).material = null
	if tutorial.get_child_count() == 0 or actions.size() == 0: return
	if tutorial.get_child_count() <= iteration or actions.size() <= iteration: return
	print("Made it through Security")
	var action = actions[actions.keys()[iteration]] as tutorialStats
	var tip = tutorial.get_child(iteration)
	tip.visible = true
	if actions.keys()[iteration] is int and action.expected_value != null:
		print("A hobo")
		var placed_obj = null
		while placed_obj != action.expected_value:
			placed_obj = await camera.get(action.external_action)
		iteration += 1
		start_iteration()
		return
	elif actions.keys()[iteration] is int and action.expected_value == null:
		print("Another hobo")
		await any_key_pressed
		iteration += 1
		start_iteration()
		return
	print("Not a hobo")
	var action_button = get_node(actions.keys()[iteration])
	
	if action.highlight_type == "color":
		#action_button.modulate = action.highlight_value
		action_button.material = pulse_effect.duplicate()
		action_button.material.set_shader_parameter("pulse_color", action.highlight_value)
	elif action.highlight_type != "null":
		action_button.offset_transform_enabled = true
		action_button["offset_transform_"+action.highlight_type] = action.highlight_value
	
	await action_button.get(action.action_type)
	print("All done")
	iteration += 1
	start_iteration()
