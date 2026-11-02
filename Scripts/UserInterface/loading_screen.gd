extends Control

@onready var loading_bar = $LoadingBar
@export_file() var next_scene:String

var progress: Array[float] = []

func _ready() -> void:
	ResourceLoader.load_threaded_request(next_scene)
	loading_bar.value = 0.0

func _process(delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(next_scene, progress)
	
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var prog = progress[0] * 100
			loading_bar.value = prog
		ResourceLoader.THREAD_LOAD_LOADED:
			var scene = ResourceLoader.load_threaded_get(next_scene)
			get_tree().change_scene_to_packed(scene)
