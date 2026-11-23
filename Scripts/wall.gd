extends Area2D

@onready var death_particle = $DeathParticle

@export var max_destroy_time:float
@export var destroy_time:float = 0.0

@export var held:bool = false

@export var max_health:int
@export var health = 1500

@export var type:wallStats

func _ready() -> void:
	if type:
		max_destroy_time = type.destroy_time
		health = type.health
		max_health = health
		$Sprite2D.texture = type.icon
		
		$CollisionShape2D.scale *= type.size
		$StaticBody2D.scale *= type.size
		$Sprite2D.scale *= type.size
		
		if type.size % 2 == 0:
			$Sprite2D.position = Vector2(-32, -32)
			$CollisionShape2D.position = Vector2(-32, -32)
			$StaticBody2D.position = Vector2(-32, -32)

func take_damage(damage: int) -> void:
	health -= damage
	if health < 1:
		GameManager.screen_shake.emit(0.1, 6)
		death_particle.emitting = true
		remove_child(death_particle)
		get_tree().current_scene.add_child(death_particle)
		death_particle.global_position = global_position
		queue_free()
