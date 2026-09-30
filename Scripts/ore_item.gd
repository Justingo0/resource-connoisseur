extends CharacterBody2D
@export var itemType = ""
@onready var sprite2D = $Sprite2D

func _ready() -> void:
	setProperties()

func setProperties() -> void:
	if itemType == "ruby":
		sprite2D.texture = load("res://Assets/Conveyor/Conveyer1.png")
		print("it's ruby alright")

func _physics_process(_delta: float) -> void:
	move_and_slide()
