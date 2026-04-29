extends CharacterBody2D
class_name goblin_principal

# Velocidad del goblin
@export var walking_speed = 100

# Referencia de la maquina de estados del goblin
@onready var state_machine: Node = $FSM
# Animaciones del goblin
@onready var animaciones_goblin = $AnimacionesGoblin
# Colision del goblin
@onready var colision_goblin: CollisionShape2D = $Colision


# Verificaciones para saber si se puede o no esconder
var escondido = false

# Variable para rastrear la dirección de entrada actual y manejar prioridades (Primer input introducido)
var input_direction = Vector2.ZERO

# Se ejecuta al inicio del progroma
func _ready():
	print("[Test]: El personaje cargo inicialmente")

	
# Se ejecuta en cada frame del juego
func _physics_process(delta):
	
	# Activa la máquina de estados
	state_machine._physics_process(delta)
	
	# Activa el movimiento del player a traves de los inputs
	handle_movement()
	handle_animations()
	# Activa el sistema de esconderse
	handle_hide()
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
	velocity = velocity_direction * walking_speed

# Administra las animaciones basándose en la dirección priorizada
func handle_animations():
	# Si está escondido o no hay intención de movimiento, no procesamos animaciones de correr
	if escondido or input_direction == Vector2.ZERO:
		# Aquí podrías reproducir una animación de Idle si fuera necesario
		return
	
	# Determinar animación según input_direction (soporta 8 direcciones)
	if input_direction.x != 0 and input_direction.y != 0:
		# Diagonales
		if input_direction.y == -1: # Arriba
			if input_direction.x == 1: animaciones_goblin.play("correr_diagonal_wd")
			else: animaciones_goblin.play("correr_diagonal_aw")
		else: # Abajo
			if input_direction.x == 1: animaciones_goblin.play("correr_diagonal_sd")
			else: animaciones_goblin.play("correr_diagonal_as")
	
	elif input_direction.y == -1:
		animaciones_goblin.play("correr_arriba")
	elif input_direction.y == 1:
		animaciones_goblin.play("correr_abajo")
	elif input_direction.x == -1:
		animaciones_goblin.play("correr_izquierda")
	elif input_direction.x == 1:
		animaciones_goblin.play("correr_derecha")

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
