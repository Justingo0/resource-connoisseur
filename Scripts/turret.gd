extends Area2D

@export var inputItem:Dictionary

@onready var bullet = preload("res://Scenes/bullet.tscn")
@export var type:turretStats #= preload("res://Resources/Data/Turrets/Ballista.tres")
@onready var turretTop = $turretTop
@onready var topSprite = $turretTop
@onready var baseSprite = $turretBase
@onready var range = $rangeCone/range
@onready var range_outline = $RadiusOutline
@onready var death_particle = $DeathParticle

@export var held:bool = false
@export var max_destroy_time:float = 2.5
@export var destroy_time:float

@export var max_health:int
@export var health = 1
var targets = []
var targetRotation:float
var reloadTimer:float
var shotCount:int

@export var inventory_size = 10
@export var inventory = {}

# Radius Outline Settings
var dot_count: int = 36
var dash_length_ratio: float = 0.5
var line_width: float = 2.0
var radius_color: Color = Color.YELLOW

func _ready() -> void:
	range.shape = CircleShape2D.new()
	range.shape.radius = type.range * 64
	health = type.health
	shotCount = type.shotCount
	inputItem = type.input
	topSprite.texture = type.topSprite
	baseSprite.texture = type.baseSprite
	
	max_destroy_time = type.destroy_time
	
	$CollisionShape2D.scale *= type.size
	$turretBase.scale *= type.size
	$turretTop.scale *= type.size
	
	if type.size % 2 == 0:
		$turretBase.position = Vector2(-32, -32)
		$CollisionShape2D.position = Vector2(-32, -32)
		$turretTop.position = Vector2(-32, -32)
		$RadiusOutline.position = Vector2(-32, -32)
		$rangeCone.position = Vector2(-32, -32)

func get_disabled() -> bool:
	if destroy_time == max_destroy_time and held == false:
		return false
	return true

func _process(delta: float) -> void:
	reloadTimer += delta*GameManager.time_scale

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
		if abs(rad_to_deg(angle_difference(targetRotation + 1.571, turretTop.global_rotation))) < 3 and reloadTimer > type.reloadSpeed:
			shoot()
			reloadTimer = 0
	pointAtEnemy(targetRotation)

func take_damage(damage: int) -> void:
	if !held:
		health -= damage
		if health < 1:
			GameManager.screen_shake.emit(0.1, 6)
			death_particle.emitting = true
			remove_child(death_particle)
			get_tree().current_scene.add_child(death_particle)
			death_particle.global_position = global_position
			queue_free()

func shoot():
	if held: return
	if !inventory.keys().is_empty():
		if inventory[inventory.keys()[0]] >= inputItem.values()[0]:
			inventory[inventory.keys()[0]] = inventory[inventory.keys()[0]] - inputItem.values()[0]
		else:
			return
	else:
		return
	while shotCount > 0:
		reloadTimer = 0
		if !type.shotgun:
			await get_tree().create_timer(type.shotInterval).timeout
		shotCount -= 1
		var bulletClone = bullet.instantiate()
		bulletClone.position = global_position
		bulletClone.rotation = turretTop.rotation - 1.571 + deg_to_rad(randf_range(-type.spread, type.spread))
		bulletClone.projectileLifetime = type.projectileLifetime
		bulletClone.damage = type.damage
		bulletClone.projectilePierce = type.projectilePierce
		bulletClone.projectileSpeed = type.projectileSpeed
		if(type.shotgun):
			bulletClone.projectileSpeed += randf_range(-200, 200)
		bulletClone.laser = type.laser
		bulletClone.range = type.range
		bulletClone.widthMultiplier = type.widthMultiplier
		bulletClone.knockAmount = type.knockAmount
		
		get_tree().current_scene.add_child(bulletClone)
	shotCount = type.shotCount

func pointAtEnemy(angle: float) -> void:
	turretTop.rotation = rotate_toward(turretTop.rotation, targetRotation + 1.571, 0.1)

func highlight(toggle:bool):
	if not held and toggle:
		range_outline.queue_redraw()
		range_outline.visible = true
	elif not toggle:
		range_outline.visible = false

func _on_radius_outline_draw() -> void:
	var center = Vector2.ZERO
	var total_segments = dot_count * 2
	var angle_step = 2 * PI / total_segments
	
	var dash_steps = max(1, int(total_segments * dash_length_ratio / dot_count))
	
	var points = PackedVector2Array()
	
	for i in range(total_segments + 1):
		var angle = i * angle_step
		points.append(center + Vector2(cos(angle), sin(angle)) * type.range * 64)
	
	for i in range(0, total_segments, 2):
		var start_index = i
		var end_index = min(i + dash_steps, total_segments)
		
		for j in range(start_index, end_index):
			range_outline.draw_line(points[j], points[j + 1], radius_color, line_width, true)
