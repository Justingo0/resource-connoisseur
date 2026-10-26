extends Area2D

signal waveInfo(waveCount, timeForWave)

@onready var wave_spawn_timer = $WaveSpawning

@onready var gameUI = $"../CanvasLayer/BuildMenu"
@onready var enemy = preload("res://Scenes/enemy.tscn")
@onready var waveData = preload("res://Resources/Data/Wavesets/wavePreset1.tres")
@onready var waveSet = waveData.waves # Amount of Enemies
@onready var waveTimes = waveData.waveTimes # Time till next Wave
var waveCount = 0
var timeForWave:int

@onready var t1ground = preload("res://Resources/Data/Enemies/t1ground.tres")
@onready var t2ground = preload("res://Resources/Data/Enemies/t2ground.tres")
@onready var t3ground = preload("res://Resources/Data/Enemies/t3ground.tres")
@onready var t4ground = preload("res://Resources/Data/Enemies/t4ground.tres")
@onready var t1air = preload("res://Resources/Data/Enemies/t1air.tres")
@onready var t2air = preload("res://Resources/Data/Enemies/t2air.tres")
@onready var t3air = preload("res://Resources/Data/Enemies/t3air.tres")
@onready var t4air = preload("res://Resources/Data/Enemies/t4air.tres")

@onready var enemyArray = [
	t1ground,
	t2ground,
	t3ground,
	t4ground,
	t1air,
	t2air,
	t3air,
	t4air
]

func _ready() -> void:
	wave_spawn_timer.wait_time = waveTimes[0]
	timeForWave = waveTimes[0]
	wave_spawn_timer.start()
	await get_tree().create_timer(0.02).timeout
	waveInfo.emit(waveCount, timeForWave)
	gameUI.startPrematurely.connect(start_wave)

func _process(_delta: float) -> void:
	if GameManager.time_scale <= 0.0:
		wave_spawn_timer.paused = true
	else:
		wave_spawn_timer.paused = false

func spawn_wave():
	if waveCount > waveSet.size()-1: return
	
	timeForWave = waveTimes[waveCount]
	waveInfo.emit(waveCount, timeForWave)
	
	var wave = waveSet[waveCount]
	var waveIndex = 0
	for count in wave:
		var spawnCount = 0
		while count > spawnCount:
			spawn_enemy(waveIndex)
			await get_tree().create_timer(0.01).timeout
			spawnCount += 1
			waveIndex += 1

func spawn_enemy(enemyIndex) -> void:
	var enemyStats = enemyArray[enemyIndex]
	var enemyClone = enemy.instantiate()
	enemyClone.global_position = position
	enemyClone.global_position.y += randf_range(-300, 300)
	enemyClone.global_position.x += randf_range(-300, 300)
	enemyClone.get_node("AnimatedSprite2D").sprite_frames = enemyStats.frames
	enemyClone.get_node("AnimatedSprite2D").play("default")
	get_tree().current_scene.add_child(enemyClone)
	enemyClone.speed = enemyStats.speed
	enemyClone.health = enemyStats.health

func start_wave() -> void:
	spawn_wave()
	if waveCount > waveSet.size()-1:
		wave_spawn_timer.stop()
	else:
		wave_spawn_timer.wait_time = waveTimes[waveCount]
		await get_tree().create_timer(waveSet[waveCount][0]*0.01).timeout
		wave_spawn_timer.start()
		waveCount += 1

func _on_wave_spawning_timeout() -> void:
	start_wave()
