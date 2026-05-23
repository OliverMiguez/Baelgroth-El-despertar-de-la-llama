extends Node2D
class_name cueva

@onready var animaciones: AnimationPlayer = $Animaciones
@onready var conver_prohibido_salir: Area2D = $ProhidoSalir/ConverProhibidoSalir
@onready var musica_cueva: AudioStreamPlayer = $MusicaCueva
@onready var prohido_salir: StaticBody2D = $ProhidoSalir
@onready var posicion_final_vigilante: Marker2D = $PosicionFinalVigilante
@onready var goblin_vigilante: Goblin_Vigilante = $GoblinVigilante
@onready var colision_area_prohibido_salir: CollisionShape2D = $ProhidoSalir/ConverProhibidoSalir/ColisionAreaProhibidoSalir

var goblin_dentro:bool = false
var transicionando:bool = false
var prohibido_salir:bool = false
var dialogo_prohibido_iniciado: bool = false

func _ready() -> void:
	musica_cueva.play()
	Musica.stop() # Musica del bosque (autoload)

func _physics_process(_delta: float) -> void:
	comprobaciones_salida()

# Revisa si se puede salir de la cueva
func comprobaciones_salida():
	if Dialogic.VAR.mis_activ == true and is_instance_valid(prohido_salir):
		prohido_salir.queue_free()
	
	if Dialogic.VAR.mov_guard == true:
		goblin_vigilante.global_position = posicion_final_vigilante.global_position
	
	prohibido_salir_sin_mision()
	
	if not musica_cueva.playing:
		musica_cueva.play()
	
	if goblin_dentro and not transicionando:
		transicionando = true
		# Primero apagamos el audio con su animacion
		animaciones.play("audio_salida")
		await animaciones.animation_finished
		#Iniciar transicion
		animaciones.play("trans2")
		await  animaciones.animation_finished

		get_tree().change_scene_to_file("res://ESCENAS/Reales/Mapas/salida_bosque.tscn")

# Area de salida, permite cambiar de escena
func _on_salida_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = true

func _on_salida_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = false

func prohibido_salir_sin_mision():
	if prohibido_salir == true and not dialogo_prohibido_iniciado:
		dialogo_prohibido_iniciado = true
		#print("1 - iniciando dialogo")
		colision_area_prohibido_salir.queue_free() # elimina colision de dialogo
		Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/ProhibidoSalir.dtl") # inicia dialogo
		await Dialogic.timeline_ended
		#print("2 - dialogo terminado")
		#print("3 - mis_activ vale: ", Dialogic.VAR.mis_activ)
		#print("4 - ProhidoSalir existe: ", is_instance_valid(prohido_salir))
		#print("5 - GoblinVigilante existe: ", is_instance_valid(goblin_vigilante))
		#paramos al goblin
		
		if Dialogic.VAR.mis_activ == true:
			#print("6 - entrando al if, borrando y moviendo")
			prohido_salir.queue_free()  # mision activa, quitamos el bloqueo
		else:
			#print("6 - entrando al else, mision no activa")
			# mision no activa, el bloqueo se queda
			dialogo_prohibido_iniciado = false  # permitimos que se repita si vuelve

# Area de la conversacion de prohibido salir
func _on_conver_prohibido_salir_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		prohibido_salir = true

func _on_conver_prohibido_salir_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		prohibido_salir = false
