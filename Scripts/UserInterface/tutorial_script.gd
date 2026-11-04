extends Control

@onready var tutorial = $"."
@onready var pulse_effect = preload("res://Assets/Shader/UI/color_pulse.tres")

@export var actions:Dictionary ##First value is the action object and the second is the actions resource.

var iteration:int = 0

func _ready() -> void:
	for tip in tutorial.get_children():
		tip.visible = false
	start_iteration()

func start_iteration():
	if iteration > 0:
		tutorial.get_child(iteration-1).visible = false
		get_node(actions.keys()[iteration-1]).offset_transform_enabled = false
		get_node(actions.keys()[iteration-1]).material = null
	if tutorial.get_child_count() == 0 or actions.size() == 0: return
	if tutorial.get_child_count() <= iteration or actions.size() <= iteration: return
	var tip = tutorial.get_child(iteration)
	var action = actions[actions.keys()[iteration]]
	var action_button = get_node(actions.keys()[iteration])
	tip.visible = true
	
	
	if action.highlight_type == "color":
		#action_button.modulate = action.highlight_value
		action_button.material = pulse_effect.duplicate()
		action_button.material.set_shader_parameter("pulse_color", action.highlight_value)
	elif action.highlight_type != "null":
		action_button.offset_transform_enabled = true
		action_button["offset_transform_"+action.highlight_type] = action.highlight_value
	
	if action.use_external_action == false:
		await action_button.get(action.action_type)
		
	iteration += 1
	start_iteration()
