extends Resource
class_name tutorialStats

@export_group("Highlight")
@export_enum("null", "scale", "color", "position", "rotation") var highlight_type:String
@export var highlight_value:Variant
@export_group("Action")
@export_enum("pressed", "mouse_entered", "mouse_exited") var action_type:String
@export var use_external_action:bool
@export_enum("on_object_placed", "on_object_deleted", "on_action_finised") var external_action:String
