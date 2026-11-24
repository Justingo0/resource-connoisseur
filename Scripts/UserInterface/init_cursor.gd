extends Control

var default_cursor = preload("res://Assets/UI/Cursors/Cursor1.png")
var interact_cursor = preload("res://Assets/UI/Cursors/Cursor2.png")
var mine_cursor = preload("res://Assets/UI/Cursors/Cursor3.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(default_cursor, Input.CURSOR_ARROW, Vector2(0, 0))
	Input.set_custom_mouse_cursor(interact_cursor, Input.CURSOR_POINTING_HAND, Vector2(8, 8))
	Input.set_custom_mouse_cursor(mine_cursor, Input.CURSOR_DRAG, Vector2(0, 0))
