extends Control

signal any_key_pressed

@onready var tutorial = $"."
@onready var pulse_effect = preload("res://Assets/Shader/UI/color_pulse.tres")

@onready var guide_arrow = $"../GuideArrow"

@onready var camera = $"../../../Player/Camera2D" as Camera2D

@export var actions:Array[Array] ##First value is the action object and the second is the actions resource.

var iteration:int = 0
var guide_node:Node2D

func _ready() -> void:
	for tip in tutorial.get_children():
		tip.visible = false
	start_iteration()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Place"):
		any_key_pressed.emit()

func _process(_delta: float) -> void:
	if guide_node:
		guide_arrow.visible = true
		var dir = (camera.position-Vector2(0,266)).angle_to_point(guide_node.global_position)
		guide_arrow.rotation = dir + deg_to_rad(90)
		print(dir + deg_to_rad(90))
	else:
		guide_arrow.visible = false

func start_iteration():
	if iteration > 0:
		tutorial.get_child(iteration-1).visible = false
		if actions[iteration-1][0]:
			get_node(actions[iteration-1][0]).offset_transform_enabled = false
			get_node(actions[iteration-1][0]).material = null
	if tutorial.get_child_count() == 0 or actions.size() == 0: return
	if tutorial.get_child_count() <= iteration or actions.size() <= iteration: return
	var action = actions[iteration][1] as tutorialStats
	guide_node = null
	if action.use_guide_arrow:
		guide_node = get_node(NodePath(action.guide_node))
	var tip = tutorial.get_child(iteration)
	tip.visible = true
	if not actions[iteration][0] and not action.use_next:
		var placed_obj = null
		while placed_obj != action.expected_value:
			if action.private_recieving_object == "GameManager" and not action.public_recieving_object:
				placed_obj = await GameManager.get(action.external_action)
			elif action.private_recieving_object == "Camera" and not action.public_recieving_object:
				placed_obj = await camera.get(action.external_action)
			elif action.public_recieving_object:
				placed_obj = await get_node(NodePath(action.public_recieving_object)).get(action.external_action)
		iteration += 1
		start_iteration()
		return
	if action.use_next:
		await any_key_pressed
		iteration += 1
		start_iteration()
		return
	var action_button = get_node(actions[iteration][0])
	
	if action.highlight_type == "color":
		#action_button.modulate = action.highlight_value
		action_button.material = pulse_effect.duplicate()
		action_button.material.set_shader_parameter("pulse_color", action.highlight_value)
	elif action.highlight_type != "null":
		action_button.offset_transform_enabled = true
		action_button["offset_transform_"+action.highlight_type] = action.highlight_value
	
	await action_button.get(action.action_type)
	iteration += 1
	start_iteration()
