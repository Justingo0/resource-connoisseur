extends Area2D

signal waveInfo(waveCount, timeForWave)

@onready var gameUI = $"../CanvasLayer/BuildMenu"
@onready var enemy = preload("res://Scenes/enemy.tscn")
@onready var waveData = preload("res://Resources/Data/wavePreset1.tres")
@onready var waveSet = waveData.waves
@onready var waveTimes = waveData.waveTimes
var waveCount = 0
var timeForWave:int
var skipWave = false

@onready var t1ground = preload("res://Resources/Data/t1ground.tres")
#var t2ground:
#var t3ground:
#var t1air:
#var t2air:
#var t3air:

func _ready() -> void:
	spawn_waves()
	await get_tree().create_timer(0.02).timeout
	waveInfo.emit(waveCount, timeForWave)
	gameUI.startPrematurely.connect(start_wave)

func _process(delta: float) -> void:
	pass
func spawn_waves() -> void:
	while waveCount < waveSet.size():
		timeForWave = waveTimes[waveCount]
		waveInfo.emit(waveCount, timeForWave)
		var timer = get_tree().create_timer(timeForWave)
		while not skipWave:
			await get_tree().create_timer(0.01).timeout
			if timer.time_left <= 0:
				break
		skipWave = false
		var wave = waveSet[waveCount]
		var index = 0
		for count in wave:
			var spawnCount = 0
			while count > spawnCount:
				spawn_enemy()
				await get_tree().create_timer(0.01).timeout
				spawnCount += 1
			index += 1
		waveCount += 1

func spawn_enemy() -> void:
	var enemyClone = enemy.instantiate()
	enemyClone.global_position = position
	enemyClone.global_position.y += randf_range(-300, 300)
	enemyClone.global_position.x += randf_range(-300, 300)
	get_tree().current_scene.add_child(enemyClone)
	enemyClone.speed = t1ground.speed

func start_wave() -> void:
	print("received")
	skipWave = true
