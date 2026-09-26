extends Area2D

var oreCount = 0
var mineTime = 0
var time = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	if oreCount > 0 and time > mineTime:
		print("mined")
		time = 0

func _on_area_entered(area: Area2D) -> void:
	oreCount += 1
	mineTime = 4/oreCount

func _on_area_exited(area: Area2D) -> void:
	oreCount -= 1
	if oreCount > 0: mineTime = 4/oreCount
