extends CharacterBody2D
@export var itemType = ""
@onready var sprite2D = $Sprite2D

func _ready() -> void:
	setProperties()

func setProperties() -> void:
	if isOre(itemType):
		var ItemStats = load("res://Resources/Data/Items/Raw%s.tres"%[itemType])
		sprite2D.texture = ItemStats.icon

func _physics_process(_delta: float) -> void:
	move_and_slide()

func isOre(item):
	if item == "Coal" or item == "Fluorite" or item == "Quartz" or item == "Ruby" or item == "Titanium" or item == "Topaz" or item == "Tungsten":
		return true
