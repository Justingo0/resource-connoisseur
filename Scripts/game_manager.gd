extends Node

# Loaded Values
static var times_logged:int = 0

# Game Values
static var tutorial_mode:bool = false

static var time_scale:float = 1
static var conveyor_frame:int = 0

static var core_inventory:Dictionary = {}

func _ready() -> void:
	times_logged += 1
	print(times_logged)
