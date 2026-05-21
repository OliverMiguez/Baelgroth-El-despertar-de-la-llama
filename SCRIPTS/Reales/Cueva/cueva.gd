extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var conver_prohibido_salir: Area2D = $ProhidoSalir/ConverProhibidoSalir
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var goblin_dentro:bool = false
var transicionando:bool = false
var prohibido_salir:bool = false
var dialogo_prohibido_iniciado: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.play()
	Musica.stop()

func _physics_process(_delta: float) -> void:
	if Dialogic.VAR.mis_activ == true and is_instance_valid($ProhidoSalir):
		$ProhidoSalir.queue_free()
	
	if Dialogic.VAR.mov_guard == true:
		$GoblinVigilante.global_position = $Marker2D.global_position
	
	prohibido_salir_sin_mision()
	
	if not audio_stream_player.playing:
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
		

func prohibido_salir_sin_mision():
	if prohibido_salir == true and not dialogo_prohibido_iniciado:
		dialogo_prohibido_iniciado = true
		print("1 - iniciando dialogo")
		$ProhidoSalir/ConverProhibidoSalir/CollisionShape2D.queue_free() # elimina colision de dialogo
		Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/ProhibidoSalir.dtl") # inicia dialogo
		await Dialogic.timeline_ended
		print("2 - dialogo terminado")
		print("3 - mis_activ vale: ", Dialogic.VAR.mis_activ)
		print("4 - ProhidoSalir existe: ", is_instance_valid($ProhidoSalir))
		print("5 - GoblinVigilante existe: ", is_instance_valid($GoblinVigilante))
		#paramos al goblin
		
		if Dialogic.VAR.mis_activ == true:
			print("6 - entrando al if, borrando y moviendo")
			$ProhidoSalir.queue_free()  # mision activa, quitamos el bloqueo
		else:
			print("6 - entrando al else, mision no activa")
			# mision no activa, el bloqueo se queda
			dialogo_prohibido_iniciado = false  # permitimos que se repita si vuelve


func _on_conver_prohibido_salir_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		prohibido_salir = true

func _on_conver_prohibido_salir_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		prohibido_salir = false
