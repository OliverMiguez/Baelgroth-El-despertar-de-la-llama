extends CharacterBody2D
class_name goblin_principal

signal escondido_cambiado # Permite que el player se esconada

@onready var state_machine: Node = $FSM
@onready var animaciones_goblin = $AnimacionesGoblin
@onready var colision_goblin: CollisionShape2D = $Colision
@onready var piedra_spawn_point: Marker2D = $PiedraSpawnPoint
@onready var pasos_audio: AudioStreamPlayer2D = $PasosAudio
@onready var cooldown_piedras: Timer = $CooldownPiedras

@export var velocidad_andar_base:float = 50.0
@export var velocidad_carrera:float = 100
@export var sonido_pasos:AudioStreamPlayer2D
@export var activar_lanzar_piedra:bool = false# Permite que el jugador lance piedras solo cuando este sepa
@export var pitch_min: float = 0.75
@export var pitch_max: float = 1.25
@export var frames_pasos: Array[int] = [1, 3]
@export var max_piedras:float = 3.0

var instancia_piedra_packed = preload("res://ESCENAS/Reales/Pielda/pielda.tscn")
var last_input # Recoge el ultimo input introducido ( se usa en la máquina de estados)
var escondido: bool = false: # Verificaciones para saber si se puede o no esconder
	set(valor):
		escondido = valor
		escondido_cambiado.emit()
var input_direction = Vector2.ZERO # Variable para rastrear la dirección de entrada actual y manejar prioridades (Primer input introducido)
var direccion_actual:Vector2 = Vector2.RIGHT
var paso_alternado: bool = false # Para ajustar audio
var esta_corriendo:bool = false # Verifica si esta corriendo 
var velocidad_andar:float = 50.0
var total_piedras:float = 0.0
#var quiere_piedra:bool = false
var modo_lanzar:bool = false # Comprueba si se entró en modo lanzar piedra


func _ready():
	velocidad_andar = velocidad_andar_base
	print("Modo lanzar: ",modo_lanzar)

	#print("[READY] velocidad_andar_base: ", velocidad_andar_base)
	#print("[READY] velocidad_andar: ", velocidad_andar)
	
func _physics_process(delta):
	#quiere_piedra = ControlPiedras.recoger_piedras

	
	state_machine._physics_process(delta)	# Activa la máquina de estados
	manejar_movimiento()	# Activa el movimiento del player a traves de los inputs
	manejar_esconderse()	# Activa el sistema de esconderse
	lanzar_piedra() # Lanza una piedra
	correr() # Permite que pueda moverse más rápido
	recoger_piedras()
	move_and_slide() # Permite que el personaje se mueva(MUY IMPORTANTE!)
	modo_lanzamiento_piedras() # Revisa si se activo el modo lanzamiento

# Administra los inputs de moviento del jugador y aplica velocidades con prioridad al primer input
func manejar_movimiento():
	if ControlEscondite.dialogo_activo or modo_lanzar:
		velocity = Vector2.ZERO
		input_direction = Vector2.ZERO  # AÑADIDO: reseteamos el input
		return
		
# Manejo del eje horizontal con prioridad al primer input
	if input_direction.x == 0:
		if Input.is_action_pressed("Izquierda"): 
			input_direction.x = -1
		elif Input.is_action_pressed("Derecha"): 
			input_direction.x = 1
	else:
		# Si ya hay una dirección activa, verificamos si se soltó la tecla
		var current_h_action = "Izquierda" if input_direction.x == -1 else "Derecha"
		if not Input.is_action_pressed(current_h_action):
			input_direction.x = 0
			# Al soltar, verificamos si la otra tecla está presionada para cambiar inmediatamente
			if Input.is_action_pressed("Izquierda"): input_direction.x = -1
			elif Input.is_action_pressed("Derecha"): input_direction.x = 1

	# Manejo del eje vertical con prioridad al primer input
	if input_direction.y == 0:
		if Input.is_action_pressed("Arriba"): 
			input_direction.y = -1
		elif Input.is_action_pressed("Abajo"): 
			input_direction.y = 1
	else:
		# Si ya hay una dirección activa, verificamos si se soltó la tecla
		var current_v_action = "Arriba" if input_direction.y == -1 else "Abajo"
		if not Input.is_action_pressed(current_v_action):
			input_direction.y = 0
			# Al soltar, verificamos si la otra tecla está presionada
			if Input.is_action_pressed("Arriba"): input_direction.y = -1
			elif Input.is_action_pressed("Abajo"): input_direction.y = 1
	
	# Normalizamos el vector para que la velocidad diagonal sea consistente
	var velocity_direction = input_direction.normalized() if input_direction != Vector2.ZERO else Vector2.ZERO
	
	if velocity_direction != Vector2.ZERO: # formato desado por mi, actualiza la direccion solo si hay movimiento para no perder el ultimo input al estar quieto
		direccion_actual = velocity_direction # formato desado por mi, guarda la direccion normalizada para el proyectil
		
	velocity = velocity_direction * velocidad_andar
	
#ajusta el spawn point de la piedra segun la direccion horizontal
	if direccion_actual.x > 0:
		piedra_spawn_point.position.x = abs(piedra_spawn_point.position.x)  # lado derecho
	elif direccion_actual.x < 0:
		piedra_spawn_point.position.x = -abs(piedra_spawn_point.position.x)  # lado izquierdo

# Revisa si se puede esconder o no el goblin principal
func manejar_esconderse():
	if Input.is_action_just_pressed("hide"):
		if  escondido:
			salir_de_arbusto()
		elif ControlEscondite.goblin_en_arbusto:
			print("intentando esconderse, escondido vale: ", escondido)
			entrar_en_arbusto()

# Se ejecuta cuando el goblin principal QUIERE entrar en el arbusto
func entrar_en_arbusto():
	velocidad_andar = 0
	animaciones_goblin.play("esconderse")
	await  animaciones_goblin.animation_finished
	escondido = true
	animaciones_goblin.visible = false
	colision_goblin.set_deferred("disabled", true)
	#print(" [Enter a brush()]:El jugador esta escondido")


# Se ejecuta cuando el goblin principal sale QUIERE salir del arbusto
func salir_de_arbusto():
	anim()
	velocidad_andar = velocidad_andar_base
	escondido = false
	animaciones_goblin.visible = true
	colision_goblin.set_deferred("disabled", false)
	#print("[Exit a brush ()]: El jugado salió de su escondite ")
func anim():
	animaciones_goblin.play("salir_esconderse")
	await  animaciones_goblin.animation_finished
	
# Instancia la piedra y la mueve a la direccion correspondiente
func lanzar_piedra():
	if activar_lanzar_piedra and total_piedras > 0 and modo_lanzar:
		if Input.is_action_just_pressed("LanzarRecoger") and ControlPiedras.recoger_piedras == false:
				print("Ejecutando lanzamiento")
				var piedra_scene = instancia_piedra_packed.instantiate()
				get_parent().add_child(piedra_scene)
				piedra_scene.global_position = piedra_spawn_point.global_position
				piedra_scene.direction = direccion_actual
				total_piedras -= 1
				ControlPiedras.piedras_jugador = total_piedras
				activar_lanzar_piedra = false # Evita que se pueda volver a lanzar otra piedra

				cooldown_piedras.start() # Cooldown para poder lanzar otra

# Administrar el sonido de los pasos
func _on_animaciones_goblin_frame_changed() -> void:
	if animaciones_goblin.frame in frames_pasos:
		if velocity != Vector2.ZERO:
			sonido_pasos.pitch_scale = randf_range(pitch_min,pitch_max)
			sonido_pasos.play()

# Aumenta la velocidad del goblin si este se encuentra en el estado correr
func correr():
	if escondido:
		velocidad_andar = 0  # si esta escondido siempre velocidad 0
		return
	if esta_corriendo == true:
		velocidad_andar = velocidad_carrera
	else: 
		velocidad_andar = velocidad_andar_base
		#print("[CORRER] velocidad cambiada a: ", velocidad_andar)


func _on_cooldown_piedras_timeout() -> void:
	# Permite volver a lanzar piedras
	activar_lanzar_piedra = true
	
func recoger_piedras():
	if ControlPiedras.recoger_piedras == true and Input.is_action_just_pressed("LanzarRecoger") and modo_lanzar == false:
		print("Recogiendo piedras")
		total_piedras = 3
		#print("Piedras recogidas: " ,total_piedras)
		if total_piedras < max_piedras:
			if total_piedras == 0:
				total_piedras += 3
			else:
				total_piedras = total_piedras
		else:
			total_piedras = 3
			ControlPiedras.piedras_jugador = total_piedras
			# MODIFICADO: activamos siempre al recoger, no solo cuando total es 1
			activar_lanzar_piedra = true
			#print("piedras: ", total_piedras)

## Permite entrar en el modo lanzamiento de piedras
func modo_lanzamiento_piedras():
	if Input.is_action_just_pressed("ActivarLanzamiento"):
		if modo_lanzar == true:
			print("Modo lanzar: ",modo_lanzar)
			modo_lanzar = false
		else:
			print("Modo lanzar: ",modo_lanzar)
			modo_lanzar = true
