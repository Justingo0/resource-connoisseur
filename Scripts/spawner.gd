extends Area2D

@onready var enemy = preload("res://Scenes/enemy.tscn")
@onready var enemyProperties = preload("res://Resources/Data/basicEnemy.tres")
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta

func _on_mouse_entered() -> void:
	var enemyClone = enemy.instantiate()
	enemyClone.global_position = position
	get_tree().current_scene.add_child(enemyClone)
	enemyClone.speed = enemyProperties.speed
