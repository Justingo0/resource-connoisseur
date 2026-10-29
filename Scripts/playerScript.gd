extends CharacterBody2D

@onready var camera = %Camera2D
@onready var animation = $AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D

@onready var mine_timer = $MineTime

@export var SPEED:float = 3000

@export var main_core:Area2D

var targetPosition:Vector2
var moving = false


var rotate_tween:Tween = null

var last_velocity = Vector2.ZERO

enum actions {default, mining}
var action = actions.default

var action_object = null
var mining_ore:Area2D

func _ready() -> void:
	#targetPosition = camera.position
	animation.play("default")

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
	if action == actions.default:
		sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(last_velocity + position)+deg_to_rad(90), 0.35)
		$Line2D.set_point_position(0, Vector2.ZERO)
	elif action == actions.mining and action_object:
		sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(action_object.global_position)+deg_to_rad(90), 0.35)
		$Line2D.set_point_position(0, to_local(action_object.global_position))
		$Line2D.default_color = Color(1.0, 0.0, 0.0)
	
	if action_object and action != actions.default:
		var distance = global_position.distance_to(action_object.global_position)
		if distance > 400:
			give_action(actions.default, null)
	
	move_and_slide()

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

func player_movement(delta:float):
	var move_vector = Input.get_vector("leftButton", "rightButton", "upButton", "downButton")*GameManager.time_scale
	var target_velocity = move_vector * delta * SPEED*10
	velocity = velocity.move_toward(target_velocity, 50)*GameManager.time_scale
	if move_vector != Vector2.ZERO:
		last_velocity = velocity

#func rotate_sprite(rotating:float):
	#if GameManager.time_scale <= 0.0: return
	#sprite.global_rotation = rotating
	#print(sprite.global_rotation)

func _on_mine_time_timeout() -> void:
	if not main_core: return
	if action_object.is_in_group("Ore"):
		if not (action_object.type.name in main_core.inventory.keys()):
			main_core.inventory[action_object.type.name] = 0
		main_core.inventory[action_object.type.name] += 1
		print(main_core.inventory[action_object.type.name])
