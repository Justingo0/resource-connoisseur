extends Node

signal on_inventory_changed(eh:bool)
signal core_destroyed
signal game_won

signal screen_shake(duration:float, magnitude:float)

# Loaded Values
static var times_logged:int = 0

# Game Values
static var tutorial_mode:bool = false
static var peacful_mode:bool = false

static var enemy_count:int = 0

static var time_scale:float = 1
static var conveyor_frame:int = 0

static var levels_completed:int = 0
static var next_scene:String

@export var core_inventory:Dictionary = {}:
	set(new_val):
		core_inventory = new_val
		on_inventory_changed.emit(true)

func _ready() -> void:
	times_logged += 1
	#if times_logged == 1:
		#tutorial_mode = true
	#print(times_logged)
