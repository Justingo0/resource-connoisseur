extends Control

signal startPrematurely
signal send_announcement(icon:Texture2D, message:String)

@onready var camera = %Camera2D
@onready var pause_state_sign = $PauseButton/TextureRect

@onready var miner = preload("res://Scenes/miner.tscn")
@onready var conveyor = preload("res://Scenes/conveyor.tscn")
@onready var home = preload("res://Scenes/home.tscn")
@onready var router = preload("res://Scenes/router.tscn")
@onready var turrent = preload("res://Scenes/turret.tscn")

@onready var annoucment_label = $Annoucement
@onready var annoucement_icon = $Annoucement/Icon
@onready var hide_timer = $Annoucement/HideTimer

@onready var play_sign = preload("res://Assets/UI/play.png")
@onready var pause_sign = preload("res://Assets/UI/pause.png")

@export var tutorial_mode:bool = true
@export_range(0, 33, 1, "prefer_slider") var starting_step:int = 0

var paused = false

var ANNOUNCEMENT_DURATION = 3 #seconds

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("Delete"):
		#print("Sent off")
		#send_announcement.emit(null, "OMG HIII")

func _on_pause_button_pressed() -> void:
	paused = not paused
	GameManager.time_scale = 0 if paused else 1
	pause_state_sign.texture = play_sign if paused else pause_sign

func _on_skip_wave_button_pressed() -> void:
	if GameManager.time_scale <= 0.0: return
	startPrematurely.emit()

func _on_send_announcement(icon: Texture2D, message: String) -> void:
	annoucment_label.offset_transform_pivot_ratio = Vector2(0,-1.5)
	annoucment_label.text = message
	annoucement_icon.texture = icon
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(annoucment_label, "offset_transform_position_ratio", Vector2(0,0), 0.3)
	tween.play()
	hide_timer.wait_time = ANNOUNCEMENT_DURATION
	hide_timer.start()
	print("recieved reveal")

func _on_hide_timer_timeout() -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT_IN).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(annoucment_label, "offset_transform_position_ratio", Vector2(0,-1.5), 0.3)
	tween.play()
	print("recieved conceal")

func get_camera() -> Camera2D:
	return camera
