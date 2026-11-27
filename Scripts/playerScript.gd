extends CharacterBody2D

@onready var vfx_ore = preload("res://Scenes/vfx_ore.tscn")

@onready var camera = %Camera2D
@onready var animation = $AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D
@onready var shadow = $Shadow

@onready var mine_timer = $MineTime

@export var SPEED:float = 3000

@onready var main_core = %Home

var targetPosition:Vector2
var moving = false

var rotate_tween:Tween = null

var last_velocity = Vector2.ZERO

enum actions {default, mining}
var action = actions.default

var action_object = null
var mining_ore:Area2D

func _ready() -> void:
	animation.play("default")

func _physics_process(delta: float) -> void:
	if GameManager.time_scale == 0.0: return
	player_movement(delta)
	
	if GameManager.time_scale == 0.0:
		$MineTime.paused = true
	else:
		$MineTime.paused = false
	
	if action == actions.default:
		sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(last_velocity + position)+deg_to_rad(90), 0.35)
		shadow.rotation = rotate_toward(sprite.rotation, position.angle_to_point(last_velocity + position)+deg_to_rad(90), 0.35)
		$Line2D.set_point_position(1, global_position)
	elif action == actions.mining and action_object:
		sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(action_object.global_position)+deg_to_rad(90), 0.35)
		shadow.rotation = rotate_toward(sprite.rotation, position.angle_to_point(action_object.global_position)+deg_to_rad(90), 0.35)
		$Line2D.set_point_position(1, action_object.global_position)
		$Line2D.default_color = Color(1.0, 0.0, 0.0)
	$Line2D.set_point_position(0, global_position+(velocity*0.02))
	
	if action_object and action != actions.default:
		var distance = global_position.distance_to(action_object.global_position)
		if distance > 400:
			give_action(actions.default, null)
	move_and_slide()

func player_movement(delta:float):
	var move_vector = Input.get_vector("leftButton", "rightButton", "upButton", "downButton")
	var target_velocity = move_vector * delta * SPEED*10
	velocity = velocity.move_toward(target_velocity, 50)
	if move_vector != Vector2.ZERO:
		last_velocity = velocity

func give_action(assignment, interacting_object):
	if interacting_object:
		var distance = global_position.distance_to(interacting_object.global_position)
		if distance > 400:
			action = actions.default
			return
	if assignment == actions.mining:
		if mine_timer.is_stopped():
			mine_timer.start()
	else:
		mine_timer.stop()
	action = assignment
	action_object = interacting_object


func _on_mine_time_timeout() -> void:
	print(main_core)
	if not main_core: return
	print("Hello")
	if action_object.is_in_group("Ore"):
		if not (action_object.type.name in main_core.inventory.keys()):
			main_core.inventory[action_object.type.name] = 0
		main_core.inventory[action_object.type.name] += 1
		var new_vfx = vfx_ore.instantiate()
		new_vfx.itemType = action_object.type.name
		get_tree().current_scene.add_child(new_vfx)
		new_vfx.position = action_object.position
		var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(new_vfx, "position", Vector2(0,0), 0.3)
		tween.finished.connect(func():
			new_vfx.queue_free())
