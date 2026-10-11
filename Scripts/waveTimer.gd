extends Label

@onready var waveTime = $"../../../Spawner"

var timeForWave:int
var waveCount:int

var time:float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	waveTime.waveInfo.connect(set_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta
	if time > 1:
		timeForWave -= 1
		if timeForWave >= 60:
			var minutes = str(floor(timeForWave/60))
			var seconds = max(0, timeForWave%60)
			if seconds < 10:
				seconds = "0" + str(seconds)
			seconds = str(seconds)
			text = "Next wave coming in " + minutes + ":" + seconds
		else:
			text = "Next wave coming in " + str(max(0, timeForWave%60))
		time = 0

func set_timer(newWaveCount, newTimeForWave) -> void:
	timeForWave = newTimeForWave
	waveCount = newWaveCount
	text = "Next wave coming in " + str(floor(timeForWave/60)) + ":" + str(max(0, timeForWave%60))
	text = "Next wave coming in " + str(max(0, timeForWave%60))
