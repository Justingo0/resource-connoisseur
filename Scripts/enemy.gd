extends CharacterBody2D

@export var speed:int
var health = 100
@onready var targetLocation = $"../Home"

func _physics_process(delta: float) -> void:
	var targetAngle = position.angle_to_point(targetLocation.global_position)
	var forwardDirection = Vector2.from_angle(rotation)
	if abs(rad_to_deg(targetAngle - rotation)) < 1:
		velocity = forwardDirection * speed
	elif global_position.distance_to(targetLocation.global_position) > 400:
		velocity = forwardDirection * 100
	else:
		velocity = forwardDirection * 0
	if global_position.distance_to(targetLocation.global_position) > 100:
		rotation = rotate_toward(rotation, targetAngle, 0.07)
	move_and_slide()

func _process(delta: float) -> void:
	pass

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		print("OHH THE AGONY")
		queue_free()

func knockback(knockDirection: Vector2, knockAmount: int) -> void:
	global_position += knockDirection * knockAmount
