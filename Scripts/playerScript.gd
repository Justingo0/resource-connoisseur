extends CharacterBody2D

@onready var camera = $"../Camera2D"
@onready var animation = $AnimatedSprite2D
@onready var sprite = $AnimatedSprite2D

var targetPosition:Vector2
var moving = false

var rotate_tween:Tween = null

func _ready() -> void:
	targetPosition = camera.position
	animation.play("default")

func _physics_process(delta: float) -> void:
	targetPosition = camera.position
	
	if global_position.distance_to(targetPosition) > 50:
		velocity = global_position.direction_to(targetPosition) * 20000 * delta * GameManager.time_scale
		
		var targetRotation = position.angle_to_point(targetPosition)
		rotate_tween = create_tween()
		rotate_tween.tween_method(rotate_sprite, sprite.global_rotation, targetRotation+deg_to_rad(90), 0.15)
		
		moving = true
	else:
		velocity = Vector2.ZERO
		moving = false
	
	move_and_slide()

func rotate_sprite(rotating:float):
	sprite.global_rotation = rotating
	#print(sprite.global_rotation)
