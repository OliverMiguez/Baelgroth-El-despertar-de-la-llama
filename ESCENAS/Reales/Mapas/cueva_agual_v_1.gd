extends Node2D

@onready var musica_cueva: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	Musica.stop()
	musica_cueva.play()

func _on_audio_stream_player_finished() -> void:
	pass
