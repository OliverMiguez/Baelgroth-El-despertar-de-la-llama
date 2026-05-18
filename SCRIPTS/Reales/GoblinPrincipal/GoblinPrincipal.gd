extends CharacterBody2D
class_name goblin_principal


signal escondido_cambiado

# Velocidad del goblin
@export var walking_speed:float = 100.0

# Referencia de la maquina de estados del goblin
@onready var state_machine: Node = $FSM
# Animaciones del goblin
@onready var animaciones_goblin = $AnimacionesGoblin
# Colision del goblin
@onready var colision_goblin: CollisionShape2D = $Colision

@onready var piedra_spawn_point: Marker2D = $PiedraSpawnPoint

@onready var pasos_audio: AudioStreamPlayer2D = $PasosAudio


# Packed Scene de la piedra
var instancia_piedra_packed = preload("res://ESCENAS/Reales/Pielda/pielda.tscn")

# Recoge el ultimo input introducido
var last_input

# Verificaciones para saber si se puede o no esconder
var escondido: bool = false:
	set(valor):
		escondido = valor
		escondido_cambiado.emit()

# Variable para rastrear la dirección de entrada actual y manejar prioridades (Primer input introducido)
var input_direction = Vector2.ZERO
var direccion_actual:Vector2 = Vector2.RIGHT

var paso_alternado: bool = false

# Permite que el jugador lance piedras solo cuando este sepa
@export var activar_lanzar_piedra:bool = false

# Se ejecuta al inicio del progroma
func _ready():
	print("[Test]: El personaje cargo inicialmente")
	
# Se ejecuta en cada frame del juego
func _physics_process(delta):
	
	# Activa la máquina de estados
	state_machine._physics_process(delta)
	
	# Activa el movimiento del player a traves de los inputs
	handle_movement()
	# Activa el sistema de esconderse
	handle_hide()
	lanzar_piedra()
	
	# Permite que el personaje se mueva
	move_and_slide()
	
func goblin():
	pass

# Administra los inputs de moviento del jugador y aplica velocidades con prioridad al primer input
func handle_movement():
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
		
	velocity = velocity_direction * walking_speed
	
#ajusta el spawn point de la piedra segun la direccion horizontal
	if direccion_actual.x > 0:
		piedra_spawn_point.position.x = abs(piedra_spawn_point.position.x)  # lado derecho
	elif direccion_actual.x < 0:
		piedra_spawn_point.position.x = -abs(piedra_spawn_point.position.x)  # lado izquierdo

# Revisa si se puede esconder o no el goblin principal
func handle_hide():
	if ControlEscondite.goblin_en_arbusto == true and Input.is_action_just_pressed("hide"):
		if not escondido:
			enter_a_brush()
		else:
			exit_a_brush()

# Se ejecuta cuando el goblin principal QUIERE entrar en el arbusto
func enter_a_brush():
	walking_speed = 0
	escondido = true
	colision_goblin.visible = false
	animaciones_goblin.visible = false
	print(" [Enter a brush()]:El jugador esta escondido")

# Se ejecuta cuando el goblin principal sale QUIERE salir del arbusto
func exit_a_brush():
	walking_speed = 100
	escondido = false
	colision_goblin.visible = true
	animaciones_goblin.visible = true
	print("[Exit a brush ()]: El jugado salió de su escondite ")

# Instancia la piedra y la mueve a la direccion correspondiente
func lanzar_piedra():
	if activar_lanzar_piedra == true:
		if Input.is_action_just_pressed("Lanzar"):
			var piedra_scene = instancia_piedra_packed.instantiate() # Instancia la escena de la piedra
			get_parent().add_child(piedra_scene) # La añade al arbol de nodos
			piedra_scene.global_position = piedra_spawn_point.global_position # La coloca en la posicion del marker 2d
			piedra_scene.direction = direccion_actual

# Administrar el sonido de los pasos
func _on_animaciones_goblin_frame_changed() -> void:
	if animaciones_goblin.frame in [1, 3]:
		if velocity != Vector2.ZERO:
			pasos_audio.pitch_scale = randf_range(0.75, 1.25)
			pasos_audio.play()
