extends Node2D
@onready var musica: AudioStreamPlayer = $"."

func _physics_process(_delta: float) -> void:
	musica.play()

	if !musica.is_playing():
		musica.play()
