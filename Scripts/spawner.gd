extends Area2D

signal waveInfo(waveCount, timeForWave)

@onready var wave_spawn_timer = $WaveSpawning

@onready var gameUI = $"../CanvasLayer/BuildMenu"
@onready var enemy = preload("res://Scenes/enemy.tscn")
@onready var waveData = preload("res://Resources/Data/wavePreset1.tres")
@onready var waveSet = waveData.waves # Amount of Enemies
@onready var waveTimes = waveData.waveTimes # Time till next Wave
var waveCount = 0
var timeForWave:int
var skipWave = false#:
	#set(new_val):
		#skipWave = new_val
		#if skipWave:
			#print("HURRAY")
			#start_wave()
			#wave_spawn_timer.start()
	#get:
		#return skipWave

@onready var t1ground = preload("res://Resources/Data/t1ground.tres")
#var t2ground:
#var t3ground:
#var t1air:
#var t2air:
#var t3air:

func _ready() -> void:
	#spawn_waves()
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

#func spawn_waves() -> void:
	#while waveCount < waveSet.size():
		#timeForWave = waveTimes[waveCount]
		#waveInfo.emit(waveCount, timeForWave)
		#var timer = get_tree().create_timer(timeForWave)
		#while not skipWave:
			#await get_tree().create_timer(0.01).timeout
			#if timer.time_left <= 0:
				#break
		#skipWave = false
		#var wave = waveSet[waveCount]
		#var index = 0
		#for count in wave:
			#var spawnCount = 0
			#while count > spawnCount:
				#spawn_enemy()
				#await get_tree().create_timer(0.01).timeout
				#spawnCount += 1
			#index += 1
		#waveCount += 1

func spawn_wave():
	if waveCount > waveSet.size()-1: return
	
	timeForWave = waveTimes[waveCount]
	waveInfo.emit(waveCount, timeForWave)
	
	skipWave = false
	var wave = waveSet[waveCount]
	#var index = 0
	for count in wave:
		var spawnCount = 0
		while count > spawnCount:
			spawn_enemy()
			await get_tree().create_timer(0.01).timeout
			spawnCount += 1
		#index += 1
	waveCount += 1

func spawn_enemy() -> void:
	var enemyClone = enemy.instantiate()
	enemyClone.global_position = position
	enemyClone.global_position.y += randf_range(-300, 300)
	enemyClone.global_position.x += randf_range(-300, 300)
	get_tree().current_scene.add_child(enemyClone)
	enemyClone.speed = t1ground.speed

func start_wave() -> void:
	spawn_wave()
	if waveCount > waveSet.size()-1:
		wave_spawn_timer.stop()
	else:
		wave_spawn_timer.wait_time = waveTimes[waveCount]

func _on_wave_spawning_timeout() -> void:
	spawn_wave()
	if waveCount > waveSet.size()-1:
		wave_spawn_timer.stop()
	else:
		wave_spawn_timer.wait_time = waveTimes[waveCount]
		
