extends CharacterBody2D

var targets = []

@export var speed:int
@export var health:int
@export var air:bool
@onready var targetLocation = $"../Home"
@onready var damageIndicator = $AnimatedSprite2D/ColorRect

@onready var bullet = preload("res://Scenes/bullet.tscn")
@export var range:int
@export var reloadSpeed:float
@export var spread:float
@export var shotCount:int
@export var shotInterval:float
@export var laser:bool
@export var shotgun:bool
@export var damage:int
@export var curvature:float
@export var projectileSpeed:int
@export var projectileLifetime:float
@export var projectilePierce:int
@export var splashRadius:int
@export var splashDamage:int
@export var widthMultiplier:float
@export var knockAmount:int
@export var targetRotation:float
@export var reloadTimer:float

func _ready() -> void:
	if air:
		collision_mask = 5
		collision_layer = 5

func _physics_process(delta: float) -> void:
	reloadTimer += delta*GameManager.time_scale
	if(!targetLocation): return
	var targetAngle = global_position.angle_to_point(targetLocation.global_position)
	var forwardDirection = Vector2.from_angle(rotation)
	if abs(rad_to_deg(targetAngle - rotation)) < 1:
		velocity = forwardDirection * speed *GameManager.time_scale
	elif global_position.distance_to(targetLocation.global_position) > 400:
		velocity = forwardDirection * 100 *GameManager.time_scale
	else:
		velocity = Vector2.ZERO
	if global_position.distance_to(targetLocation.global_position) > 100:
		rotation = rotate_toward(rotation, targetAngle, 0.07)
	if abs(rad_to_deg(angle_difference(targetRotation + 1.571, global_rotation))) < 120 and reloadTimer > reloadSpeed:
		shoot()
		reloadTimer = 0
	move_and_slide()

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		queue_free()
	flash()
	
func flash() -> void:
	damageIndicator.visible = true
	await get_tree().create_timer(0.025).timeout
	damageIndicator.visible = false

func knockback(knockDirection: Vector2, knockAmount: int) -> void:
	global_position += knockDirection * knockAmount


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Block"):
		targets.append(area)
		targetRotation = global_position.angle_to_point(targets[0].global_position)

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Block"):
		targets.erase(area)

func shoot():
	var shotsLeft = shotCount
	while shotsLeft > 0:
		reloadTimer = 0
		if !shotgun:
			await get_tree().create_timer(shotInterval).timeout
		shotsLeft -= 1
		var bulletClone = bullet.instantiate()
		bulletClone.position = global_position
		bulletClone.rotation = rotation + deg_to_rad(randf_range(-spread, spread))
		bulletClone.projectileLifetime = projectileLifetime
		bulletClone.projectilePierce = projectilePierce
		bulletClone.projectileSpeed = projectileSpeed
		if(shotgun):
			bulletClone.projectileSpeed += randf_range(-200, 200)
		bulletClone.damage = damage
		bulletClone.laser = laser
		bulletClone.range = range
		bulletClone.widthMultiplier = widthMultiplier
		bulletClone.knockAmount = knockAmount
		bulletClone.enemyBullet = true
		get_tree().current_scene.add_child(bulletClone)

func pointAtEnemy(angle: float) -> void:
	rotation = rotate_toward(rotation, targetRotation + 1.571, 0.2)
