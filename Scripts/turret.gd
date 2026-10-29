extends Area2D

@onready var turretTop = $turretTop
@onready var bullet = preload("res://Scenes/bullet.tscn")
@onready var turretProperties = preload("res://Resources/Data/Turrets/Hua-Che.tres")
@onready var range = $rangeCone/range

@export var held:bool = false
@export var max_destroy_time:float = 2.5
@export var destroy_time:float

var health = 1
var targets = []
var targetRotation:float
var reloadTimer:float
var shotCount:int

@export var inventory_size = 10
@export var inventory = {"ore": 0}

func _ready() -> void:
	range.shape.radius = turretProperties.range * 64
	health = turretProperties.health
	shotCount = turretProperties.shotCount

func get_disabled() -> bool:
	if destroy_time == max_destroy_time and held == false:
		return false
	return true

func _process(delta: float) -> void:
	reloadTimer += delta*GameManager.time_scale

#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("Enemy") and not held:
		#targets.append(body)
		#targetRotation = global_position.angle_to_point(targets[0].global_position)
#
#func _on_body_exited(body: Node2D) -> void:
	#if body.is_in_group("Enemy") and not held:
		#targets.erase(body)

func _on_range_cone_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy") and not held:
		targets.append(body)
		targetRotation = global_position.angle_to_point(targets[0].global_position)

func _on_range_cone_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy") and not held:
		targets.erase(body)

func _physics_process(_delta: float) -> void:
	if held: return
	if !targets.is_empty():
		targetRotation = global_position.angle_to_point(targets[0].global_position)
		if abs(rad_to_deg(angle_difference(targetRotation + 1.571, turretTop.global_rotation))) < 3 and reloadTimer > turretProperties.reloadSpeed:
			shoot()
			reloadTimer = 0
	pointAtEnemy(targetRotation)

func take_damage(damage: int) -> void:
	if !held:
		health -= damage
		if health < 1:
			queue_free()

func shoot():
	if held: return

	if inventory.ore >= 0.5:
		inventory.ore = inventory.ore - 0.5
	else:
		return

	while shotCount > 0:
		reloadTimer = 0
		if !turretProperties.shotgun:
			await get_tree().create_timer(turretProperties.shotInterval).timeout
		shotCount -= 1
		var bulletClone = bullet.instantiate()
		bulletClone.position = global_position
		bulletClone.rotation = turretTop.rotation - 1.571 + deg_to_rad(randf_range(-turretProperties.spread, turretProperties.spread))
		bulletClone.projectileLifetime = turretProperties.projectileLifetime
		bulletClone.damage = turretProperties.damage
		bulletClone.projectilePierce = turretProperties.projectilePierce
		bulletClone.projectileSpeed = turretProperties.projectileSpeed
		if(turretProperties.shotgun):
			bulletClone.projectileSpeed += randf_range(-200, 200)
		bulletClone.laser = turretProperties.laser
		bulletClone.range = turretProperties.range
		bulletClone.widthMultiplier = turretProperties.widthMultiplier
		bulletClone.knockAmount = turretProperties.knockAmount
		
		get_tree().current_scene.add_child(bulletClone)
	shotCount = turretProperties.shotCount

func pointAtEnemy(angle: float) -> void:
	turretTop.rotation = rotate_toward(turretTop.rotation, targetRotation + 1.571, 0.1)
