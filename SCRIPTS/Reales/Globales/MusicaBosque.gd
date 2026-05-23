extends	Node

@export var volumen:float = -20.0 

var musica: AudioStreamPlayer
var pausada: bool = false  # AÑADIDO

func _ready() -> void:
	musica = AudioStreamPlayer.new()
	add_child(musica)
	musica.stream = preload("res://Musica/Test/forestV2.wav")
	musica.volume_db = volumen
	musica.play()

func _process(_delta: float) -> void:
	# MODIFICADO: solo reinicia si no esta pausada manualmente
	if not musica.is_playing() and not pausada:
		musica.play()

func stop():
	pausada = true  # MODIFICADO: marcamos que no queremos que suene
	musica.stop()

func play():
	pausada = false  # AÑADIDO: al reanudar quitamos el bloqueo
	musica.volume_db = volumen
	musica.play()
