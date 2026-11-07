extends Resource
class_name tutorialStats

@export var use_next:bool
@export_group("Highlight")
@export_enum("null", "scale", "color", "position", "rotation") var highlight_type:String = "null"
@export var highlight_value:Variant
@export_group("Action")
@export_enum("pressed", "mouse_entered", "mouse_exited") var action_type:String = "pressed"
@export_subgroup("External")
@export_enum("GameManager", "Camera") var private_recieving_object:String = "Camera"
@export var public_recieving_object:NodePath
@export_enum("on_object_placed", "on_object_deleted", "on_action_finised", "on_inventory_changed", "on_body_entered") var external_action:String = "on_object_placed"
@export var expected_value:Variant
@export_group("Guide")
@export var use_guide_arrow:bool = false
@export var guide_node:String
