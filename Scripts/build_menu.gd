extends Control

signal startPrematurely

@onready var camera = %Camera2D
@onready var pause_state_sign = $PauseButton/TextureRect

@onready var miner = preload("res://Scenes/miner.tscn")
@onready var conveyor = preload("res://Scenes/conveyor.tscn")
@onready var home = preload("res://Scenes/home.tscn")
@onready var router = preload("res://Scenes/router.tscn")
@onready var turrent = preload("res://Scenes/turret.tscn")

@onready var play_sign = preload("res://Assets/UI/play.png")
@onready var pause_sign = preload("res://Assets/UI/pause.png")

var paused = false

func _on_pause_button_pressed() -> void:
	paused = not paused
	GameManager.time_scale = 0 if paused else 1
	pause_state_sign.texture = play_sign if paused else pause_sign

func _on_skip_wave_button_pressed() -> void:
	if GameManager.time_scale <= 0.0: return
	startPrematurely.emit()
