extends Resource
class_name blockStats

# Stats that all blocks have in common and must have

@export var icon:Texture2D
@export var scene:PackedScene

@export var size:int
@export var health:int
@export var buildCosts:Dictionary

@export var destroy_time:float
