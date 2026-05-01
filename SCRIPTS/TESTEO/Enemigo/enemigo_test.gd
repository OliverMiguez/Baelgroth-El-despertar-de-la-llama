extends CharacterBody2D
class_name Enemigo

# Array que recoge todos los puntos en los que se podrá mover el enemigo
@export var puntos_patrulla: Array[NodePath] = []
# Nodo que hace referencia al objeto que permite mover al enemigo entre los puntos de manera inteligentee
@onready var agente: NavigationAgent2D = $NavigationAgent2D
# Area de deteccion del enemigo(detectar al personaje principal)
@onready var area_deteccion: Area2D = $AreaDeteccion
# Referencia al manejador de la máquina de estados
@onready var fsm: Node = $FSM

# Puntos por los que ya pasó
var puntos_resueltos: Array[Node2D] = []
# Verifica si el goblin fué detectado
var goblin_detectado: goblin_principal = null

func _ready():
	# Recorre el array de los Marker2D
	for path in puntos_patrulla:
		puntos_resueltos.append(get_node(path)) # Añade el primer punto al array de putos por los que se han pasado
	fsm.inicializar(self) # Inicia la maquina de estados
	
	# Conexiones del area2D
	area_deteccion.body_entered.connect(_on_area_body_entered)
	area_deteccion.body_exited.connect(_on_area_body_exited)

func _physics_process(delta):
	fsm.tick(delta)
	move_and_slide() # Permite el movimiento del enemigo

# Verifica si se detecto el goblin y no esta escondido
func _on_area_body_entered(body):
	if body is goblin_principal and not body.escondido:
		goblin_detectado = body
		# Cambia de estado a alerta
		fsm.cambiar_estado("alerta")

# Si el jugador sale de su area activa el estado de investigacion
func _on_area_body_exited(body):
	if body is goblin_principal:
		goblin_detectado = null
		fsm.cambiar_estado("investigar")
