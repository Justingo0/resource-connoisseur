extends Control

signal startPrematurely
signal send_announcement(message:String, icon:Texture2D, color:Color)

@onready var camera = %Camera2D
@onready var pause_state_sign = $PauseButton/TextureRect

@onready var annoucment_label = $Annoucement
@onready var annoucement_icon = $Annoucement/Icon
@onready var hide_timer = $Annoucement/HideTimer

@onready var action_panel = $ActionPanel
@onready var action_label = $ActionPanel/Action

@onready var play_sign = preload("res://Assets/UI/play.png")
@onready var pause_sign = preload("res://Assets/UI/pause.png")

@export var tutorial_mode:bool = true
@export_range(0, 33, 1, "prefer_slider") var starting_step:int = 0

var paused = false

var ANNOUNCEMENT_DURATION = 3 #seconds

var announce_tween:Tween

var building_paused = false

func _ready() -> void:
	GameManager.core_destroyed.connect(lose_screen)
	
	action_panel.visible = false
	camera.on_action_started.connect(func(_lala):
		action_panel.visible = true)
	camera.on_action_finised.connect(func(_lala):
		action_panel.visible = false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause") and action_panel.visible:
		building_paused = not building_paused
		action_label.text = "[color={0}][b][C][/b][/color] to pause\n[b][X][/b] to cancel".format(["green" if building_paused else "white"])

func _on_pause_button_pressed() -> void:
	paused = not paused
	GameManager.time_scale = 0 if paused else 1
	pause_state_sign.texture = play_sign if paused else pause_sign

func _on_skip_wave_button_pressed() -> void:
	if GameManager.time_scale <= 0.0: return
	startPrematurely.emit()

func _on_send_announcement(message: String, icon:Texture2D=null, color:Color=Color.WHITE) -> void:
	if announce_tween and announce_tween.is_valid():
		announce_tween.kill()
	annoucment_label.offset_transform_position_ratio = Vector2(0,-1.6)
	annoucment_label.text = message
	annoucement_icon.texture = icon
	annoucment_label.modulate = color
	announce_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	announce_tween.tween_property(annoucment_label, "offset_transform_position_ratio", Vector2(0,0), 0.2)
	announce_tween.play()
	hide_timer.wait_time = ANNOUNCEMENT_DURATION
	hide_timer.start()
	#print("recieved reveal")

func _on_hide_timer_timeout() -> void:
	announce_tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	announce_tween.tween_property(annoucment_label, "offset_transform_position_ratio", Vector2(0,-1.6), 0.2)
	announce_tween.play()
	#print("recieved conceal")

func get_camera() -> Camera2D:
	return camera

func lose_screen():
	for child in get_children():
		child.visible = false
	$LoseScreen.visible = true
