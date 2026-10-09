extends CharacterBody2D

@onready var camera = %Camera2D
@onready var animation = $AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D

@export var SPEED:float = 3000

var targetPosition:Vector2
var moving = false

var rotate_tween:Tween = null

var last_velocity = Vector2.ZERO

func _ready() -> void:
	#targetPosition = camera.position
	animation.play("default")

func _physics_process(delta: float) -> void:
	player_movement(delta)
	
	sprite.rotation = rotate_toward(sprite.rotation, position.angle_to_point(last_velocity + position)+deg_to_rad(90), 0.15)
	
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

func player_movement(delta:float):
	var move_vector = Input.get_vector("leftButton", "rightButton", "upButton", "downButton")
	var target_velocity = move_vector * delta * SPEED*10
	velocity = velocity.move_toward(target_velocity, 50)
	if move_vector != Vector2.ZERO:
		last_velocity = velocity

#func rotate_sprite(rotating:float):
	#if GameManager.time_scale <= 0.0: return
	#sprite.global_rotation = rotating
	#print(sprite.global_rotation)
