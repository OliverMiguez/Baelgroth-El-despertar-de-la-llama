extends AudioStreamPlayer
func _ready() -> void:
	play()

func _physics_process(_delta: float) -> void:
	if not is_playing():
		play()
