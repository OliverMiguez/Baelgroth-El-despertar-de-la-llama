extends Node2D

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var goblin_dentro:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.play()

func _physics_process(_delta: float) -> void:
	if not  audio_stream_player.playing:
		audio_stream_player.play()
	
	if goblin_dentro:
		#Iniciar transicion
		get_tree().change_scene_to_file("res://ESCENAS/Reales/Mapas/salida_bosque.tscn")


func _on_salida_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = true

func _on_salida_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = false
