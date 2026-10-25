extends CharacterBody2D

@onready var camera = %Camera2D
@onready var animation = $AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D

@export var SPEED:float = 3000

var targetPosition:Vector2
var moving = false

var rotate_tween:Tween = null

var last_velocity = Vector2.ZERO

enum actions {default, construct, deconstruct}
var action = actions.default

var action_object = null

func _ready() -> void:
	#targetPosition = camera.position
	animation.play("default")

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
	if action == actions.default:
		sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(last_velocity + position)+deg_to_rad(90), 0.35)
		$Line2D.set_point_position(0, Vector2.ZERO)
	#elif action == actions.construct and action_object:
		#sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(action_object.global_position)+deg_to_rad(90), 0.35)
		#$Line2D.set_point_position(0, to_local(action_object.global_position))
		#$Line2D.default_color = Color(0.0, 0.6, 0.686)
	#elif action == actions.deconstruct and action_object:
		#sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(action_object.global_position)+deg_to_rad(90), 0.35)
		#$Line2D.set_point_position(0, to_local(action_object.global_position))
		#$Line2D.default_color = Color(1.0, 0.0, 0.0)
	
	#targetPosition = camera.position
	#
	#if global_position.distance_to(targetPosition) > 50:
		#velocity = global_position.direction_to(targetPosition) * 20000 * delta * GameManager.time_scale
		#
		#var targetRotation = position.angle_to_point(targetPosition)
		#rotate_tween = create_tween()
		#rotate_tween.tween_method(rotate_sprite, sprite.global_rotation, targetRotation+deg_to_rad(90), 0.15)
		#
		#moving = true
	#else:
		#velocity = Vector2.ZERO
		#moving = false
	
	move_and_slide()

func give_action(assignment, interacting_object):
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
