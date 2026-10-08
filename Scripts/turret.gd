extends Area2D

@onready var turretTop = $turretTop
@onready var bullet = preload("res://Scenes/bullet.tscn")
@onready var turretProperties = preload("res://Resources/Data/Peashooter.tres")
@onready var range = $range
var health = 1
var targets = []
var targetRotation:float
var reloadTimer:float
var shotCount:int

func _ready() -> void:
	range.shape.radius = turretProperties.range * 64
	health = turretProperties.health
	shotCount = turretProperties.shotCount

func _process(delta: float) -> void:
	reloadTimer += delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		targets.append(body)
		targetRotation = global_position.angle_to_point(targets[0].global_position)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		targets.erase(body)

func _physics_process(delta: float) -> void:
	if !targets.is_empty():
		targetRotation = global_position.angle_to_point(targets[0].global_position)
		if abs(rad_to_deg(angle_difference(targetRotation + 1.571, turretTop.global_rotation))) < 3 and reloadTimer > turretProperties.reloadSpeed:
			while shotCount > 0:
				reloadTimer = 0
				await get_tree().create_timer(0.02).timeout
				shotCount -= 1
				var bulletClone = bullet.instantiate()
				bulletClone.position = global_position
				bulletClone.rotation = turretTop.rotation - 1.571 + deg_to_rad(randf_range(-turretProperties.spread, turretProperties.spread))
				bulletClone.projectileLifetime = turretProperties.projectileLifetime
				bulletClone.damage = turretProperties.damage
				bulletClone.projectilePierce = turretProperties.projectilePierce
				bulletClone.projectileSpeed = turretProperties.projectileSpeed
				bulletClone.laser = turretProperties.laser
				bulletClone.range = turretProperties.range
				bulletClone.widthMultiplier = turretProperties.widthMultiplier
				bulletClone.knockAmount = turretProperties.knockAmount
				
				get_tree().current_scene.add_child(bulletClone)
			shotCount = turretProperties.shotCount
	pointAtEnemy(targetRotation)

func pointAtEnemy(angle: float) -> void:
	turretTop.rotation = rotate_toward(turretTop.rotation, targetRotation + 1.571, 0.1)
