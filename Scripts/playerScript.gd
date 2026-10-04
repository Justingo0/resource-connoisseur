extends CharacterBody2D

@onready var camera = $"../Camera2D"
@onready var animation = $AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D

var targetPosition:Vector2
var moving = false

func _ready() -> void:
	targetPosition = camera.position
	animation.play("default")

func _process(_delta: float) -> void:
	if global_position.distance_to(camera.position) > 50:
		var targetRotation = position.angle_to_point(camera.position)
		sprite.global_rotation = rotate_toward(sprite.global_rotation, targetRotation+deg_to_rad(90), 0.1)

func _physics_process(delta: float) -> void:
	var target = camera.position
	#var forwardDirection = Vector2.from_angle(rotation)
	
	#if global_position.distance_to(target) > 30:
	#if abs(rad_to_deg(targetRotation - rotation)) < 1:
		#velocity = forwardDirection * 15000 * delta * GameManager.time_scale
		#moving = false
	if global_position.distance_to(target) > 50:
		velocity = global_position.direction_to(target) * 16000 * delta * GameManager.time_scale
		#look_at(target)
		#rotation = rotate_toward(rotation, targetRotation, 0.07)
		moving = true
	else:
		velocity = Vector2.ZERO
		moving = false
	#if global_position.distance_to(targetPosition) > 100:
		#velocity = forwardDirection * 0
	
	move_and_slide()
