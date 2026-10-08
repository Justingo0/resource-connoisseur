extends Area2D

@export var widthMultiplier:float
@export var knockAmount:int
@export var range:int
var oneShot = false
@export var laser:bool
@export var projectileSpeed:int
@export var projectileLifetime:float
@export var projectilePierce:int
@export var damage:int
@export var splashRadius:int
@export var splashDamage:int
var forwardDirection:Vector2

func _ready() -> void:
	await get_tree().create_timer(projectileLifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	forwardDirection = Vector2.from_angle(rotation)
	if laser == true:
		scale.x = projectileSpeed * projectileLifetime / 20
		if !oneShot:
			scale.y *= widthMultiplier
			global_position += forwardDirection * range * 32
			oneShot = true
		print(projectileSpeed * projectileLifetime)
	else:
		global_position += forwardDirection * projectileSpeed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		body.knockback(forwardDirection, knockAmount)
		projectilePierce -= 1
		if projectilePierce < 0:
			queue_free()
