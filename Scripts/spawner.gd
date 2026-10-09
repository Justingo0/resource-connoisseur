extends Area2D

@onready var enemy = preload("res://Scenes/enemy.tscn")
@onready var waveData = preload("res://Resources/Data/wavePreset1.tres")
@onready var waveSet = waveData.waves
@onready var waveTimes = waveData.waveTimes
var timer = 0
var waveCount = 0

@onready var t1ground = preload("res://Resources/Data/t1ground.tres")
#var t2ground:
#var t3ground:
#var t1air:
#var t2air:
#var t3air:

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_waves()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta


func spawn_waves() -> void:
	while waveCount < waveSet.size():
		var timeForWave = waveTimes[waveCount]
		await get_tree().create_timer(timeForWave).timeout
		var wave = waveSet[waveCount]
		var index = 0
		for count in wave:
			var spawnCount = 0
			while count > spawnCount:
				print(count)
				spawn_enemy()
				await get_tree().create_timer(0.01).timeout
				spawnCount += 1
			index += 1
		waveCount += 1

func spawn_enemy() -> void:
	var enemyClone = enemy.instantiate()
	enemyClone.global_position = position
	get_tree().current_scene.add_child(enemyClone)
	enemyClone.speed = t1ground.speed
