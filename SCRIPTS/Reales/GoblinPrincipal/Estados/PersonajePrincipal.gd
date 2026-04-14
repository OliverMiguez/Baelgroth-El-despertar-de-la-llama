extends CharacterBody2D
class_name goblin_principal

# Velocidad del goblin
const WALKING_SPEED = 100

# Referencia de la maquina de estados del goblin
@onready var state_machine: Node = $FSM

@onready var animaciones_goblin = $AnimacionesGoblin

# Se ejecuta al inicio del progroma
func _ready():
	print("[Test]: El personaje cargo inicialmente")
	
# Se ejecuta en cada frame del juego
func _physics_process(delta):
	
	# Activa la máquina de estados
	state_machine._physics_process(delta)
	
	# Activa el movimiento del player a traves de los inputs
	handle_directions()
	handle_animations()
	# Permite que el personaje se mueva
	move_and_slide()

# Administra los inputs de moviento del jugador y aplica velocidades
func handle_directions():
	# Administra los inputs horizontales y verticales (direcciones)
	var h_direction  = Input.get_axis("Izquierda","Derecha")
	var v_direction  = Input .get_axis("Arriba","Abajo")
	
	# Combina las "direcciones" en una sola
	var direction = Vector2(h_direction, v_direction)
	
	# Normalizamos para que no corra más en diagonal
	if direction.length() > 1:
		direction = direction.normalized() 
	
	# Aplicamos la velocidad al goblin
	velocity = direction * WALKING_SPEED

# Administra las animaciones que realiza el goblin
func handle_animations():
	# Los Inputs que se detectan
	var up = Input.is_action_pressed("Arriba")
	var down = Input.is_action_pressed("Abajo")
	var left = Input.is_action_pressed("Izquierda")
	var right = Input.is_action_pressed("Derecha")
	var lanzar = Input.is_action_pressed("Lanzar")
	
	
	# Diagonales
	if up and right:
		animaciones_goblin.play("correr_diagonal_wd")
	elif up and left:
		animaciones_goblin.play("correr_diagonal_aw")
	elif down and right:
		animaciones_goblin.play("correr_diagonal_sd")
	elif down and left:
		animaciones_goblin.play("correr_diagonal_as")
	
	# Normales
	elif up:
		animaciones_goblin.play("correr_arriba")
	elif down:
		animaciones_goblin.play("correr_abajo")
	elif left:
		animaciones_goblin.play("correr_izquierda")
	elif right:
		animaciones_goblin.play("correr_derecha")
	elif lanzar:
		animaciones_goblin.play("lanzar")
	# Idle
	else:
		# Aquí podrías poner una lógica para mantener la última dirección mirada
		animaciones_goblin.play("Idle")
