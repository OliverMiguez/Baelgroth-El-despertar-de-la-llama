extends Node2D
@onready var musica_playa: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	Musica.stop()
	musica_playa.play()


func _on_audio_stream_player_finished() -> void:
	musica_playa.play()
