extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var goblin_dentro:bool = false
var transicionando:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.play()
	Musica.stop()

func _physics_process(_delta: float) -> void:
	Musica.stop()
	if not  audio_stream_player.playing:
		audio_stream_player.play()
	
	if goblin_dentro and not transicionando:
		transicionando = true
		# Primero apagamos el audio con su animacion
		animation_player.play("audio_salida")
		await animation_player.animation_finished
		#Iniciar transicion
		animation_player.play("trans2")
		await  animation_player.animation_finished

		get_tree().change_scene_to_file("res://ESCENAS/Reales/Mapas/salida_bosque.tscn")
		

func _on_salida_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = true

func _on_salida_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = false
