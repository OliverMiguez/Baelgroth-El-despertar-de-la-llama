extends Node2D
class_name cueva

@onready var animaciones: AnimationPlayer = $Animaciones
@onready var conver_prohibido_salir: Area2D = $ProhidoSalir/ConverProhibidoSalir
@onready var musica_cueva: AudioStreamPlayer = $MusicaCueva
@onready var prohido_salir: StaticBody2D = $ProhidoSalir
@onready var posicion_final_vigilante: Marker2D = $PosicionFinalVigilante
@onready var goblin_vigilante: Goblin_Vigilante = $GoblinVigilante
@onready var colision_area_prohibido_salir: CollisionShape2D = $ProhidoSalir/ConverProhibidoSalir/ColisionAreaProhibidoSalir
@onready var roberto_miloss: CharacterBody2D = $RobertoMilos
@onready var primer_destino_roberto: Marker2D = $Mov1Roberto
@onready var animaciones_roberto: AnimatedSprite2D = $RobertoMilos/AnimatedSprite2D
@onready var segundo_destino_roberto: Marker2D = $Mov2Roberto
@onready var tercer_destino_roberto: Marker2D = $Mov3_Roberto

var goblin_dentro:bool = false
var transicionando:bool = false
var prohibido_salir:bool = false
var dialogo_prohibido_iniciado: bool = false
var roberto_mov_actual:int = 0
var tween
var roberto_moviendose:bool = false
var primer_mov_completado:bool = false
var segundo_mov_completado:bool = false

func _ready() -> void:
	#Ui.hide()
	#tween = create_tween()
	roberto_miloss.visible = false
	musica_cueva.play()
	Musica.stop() # Musica del bosque (autoload)

func _physics_process(_delta: float) -> void:
	comprobaciones_salida()
	manejador_roberto()
	
# Encargada del movimiento de roberto
func manejador_roberto():
	if Dialogic.VAR.roberto_entra == true and not roberto_moviendose:
		print("1 - roberto_entra es true, iniciando movimiento")
		roberto_miloss.visible = true
		roberto_moviendose = true
		# Primer mov que realiza
		roberto_mov_actual = 1
		print("2 - destino primer mov: ", primer_destino_roberto.global_position)
		movimientos_roberto(primer_destino_roberto.global_position,6.0)

# Mueve a roberto por el mapa
func movimientos_roberto(destino:Vector2, duracion:float):
	print("3 - movimientos_roberto llamado, caso: ", roberto_mov_actual, " destino: ", destino)
	match  roberto_mov_actual:
		1:
			print("4 - creando tween caso 1")
			tween = create_tween()
			tween.tween_property(roberto_miloss, "global_position", destino, duracion)
			animaciones_roberto.play("Arriba")
			tween.tween_callback(func(): # Cuando el tween acaba activa esta animacion
				print("5 - primer tween terminado")
				animaciones_roberto.play("Idle")  # cambia a la animacion que quieras
				primer_mov_completado = true
				roberto_mov_actual = 2
				# Esperamos la señal de que roberto termino de hablar
				roberto_miloss.dialogo_con_roberto_terminado.connect(func():
					movimientos_roberto(segundo_destino_roberto.global_position, 4.0)
				, CONNECT_ONE_SHOT)  # CONNECT_ONE_SHOT hace que se desconecte automaticamente tras ejecutarse
			)

		2:
			print("4 - creando tween caso 2")
			tween = create_tween()
			tween.tween_property(roberto_miloss, "global_position", segundo_destino_roberto.global_position, duracion)
			animaciones_roberto.play("Abajo")
			tween.tween_callback(func(): # Cuando el tween acaba activa esta animacion
				print("5 - segundo tween terminado")
				segundo_mov_completado = true
				roberto_mov_actual = 3
				movimientos_roberto(tercer_destino_roberto.global_position,6.0)
			)
		3: 
			print("5- creadno tween caso 3")
			tween = create_tween()
			tween.tween_property(roberto_miloss, "global_position", tercer_destino_roberto.global_position, 3.0)
			animaciones_roberto.play("Lado")
			tween.tween_callback(func(): # Cuando el tween acaba activa esta animacion
				roberto_miloss.queue_free()
			)
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
	if prohibido_salir == true and not dialogo_prohibido_iniciado and Input.is_action_just_pressed("Hablar"):
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
			if is_instance_valid(prohido_salir):
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
