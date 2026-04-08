extends CharacterBody2D
class_name prueba_goblin

# Velocidad del goblin
const WALKING_SPEED = 100

# Referencia de la maquina de estados del goblin
@onready var state_machine: Node = $FSM

# Se ejecuta al inicio del progroma
func _ready():
	print("[Test]: El personaje cargo inicialmente")
	
# Se ejecuta en cada frame del juego
func _physics_process(delta):
	
	# Activa la máquina de estados
	state_machine._physics_process(delta)
	
	# Activa el movimiento del player a traves de los inputs
	handle_directions()
	
	# Permite que el personaje se mueva
	move_and_slide()

# Administra los inputs de moviento del jugador
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
