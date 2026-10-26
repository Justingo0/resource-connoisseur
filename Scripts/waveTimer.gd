extends Label

@onready var waveTime = $"../../../../Spawner"
@onready var waveCounter = $"../WaveCounter"

var timeForWave:int
var waveCount:int

var time:float

var starting_text = "Next Wave In... "

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	waveTime.waveInfo.connect(set_timer)
	if waveCounter:
		waveCounter.text = str(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += delta*GameManager.time_scale
	if time > 1:
		timeForWave -= 1
		if timeForWave >= 60:
			var minutes = str(floor(timeForWave/60))
			var seconds = max(0, timeForWave%60)
			if seconds < 10:
				seconds = "0" + str(seconds)
			seconds = str(seconds)
			text = starting_text + minutes + ":" + seconds
		else:
			text = starting_text + str(max(0, timeForWave%60))
		time = 0

func set_timer(newWaveCount, newTimeForWave) -> void:
	timeForWave = newTimeForWave
	waveCounter.text = str(newWaveCount+1)
	waveCount = newWaveCount
	text = starting_text + str(floor(timeForWave/60)) + ":" + str(max(0, timeForWave%60))
	text = starting_text + str(max(0, timeForWave%60))
