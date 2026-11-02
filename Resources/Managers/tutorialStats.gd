extends Resource
class_name tutorialStats

@export_group("Highlight")
@export_enum("size", "color", "position", "rotation") var highlight_type:String
@export var highlight_value:Variant
@export_group("Action")
@export_enum("pressed", "mouse_entered", "mouse_exited") var action_type:String
