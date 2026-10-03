extends CharacterBody2D

@onready var camera = $"../Camera2D"
@onready var animation = $AnimatedSprite2D
var targetPosition:Vector2
var moving = false

func _ready() -> void:
	var targetPosition = camera.position
	animation.play("default")

func _physics_process(delta: float) -> void:
	var target = camera.position
	var targetRotation = position.angle_to_point(targetPosition)
	var forwardDirection = Vector2.from_angle(rotation)
	if global_position.distance_to(target) > 30:
		targetPosition = target
	if abs(rad_to_deg(targetRotation - rotation)) < 1:
		velocity = forwardDirection * 400
		moving = false
	elif global_position.distance_to(target) > 150:
		velocity = forwardDirection * 250
		moving = true
	else:
		velocity = forwardDirection * 0
		moving = false
	if global_position.distance_to(targetPosition) > 100:
		rotation = rotate_toward(rotation, targetRotation, 0.07)
		#velocity = forwardDirection * 0
	
	move_and_slide()
