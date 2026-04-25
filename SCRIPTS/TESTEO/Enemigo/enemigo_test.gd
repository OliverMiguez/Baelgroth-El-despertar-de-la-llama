# ============================================================
# enemigo.gd
# Nodo raíz del enemigo. Se encarga de:
#   - Guardar referencias a sus componentes
#   - Pasar los puntos de patrulla a la FSM
#   - Llamar a la FSM cada frame
#   - Mover al personaje con move_and_slide()
# ============================================================
extends CharacterBody2D
class_name Enemigo

# Array de rutas (NodePath) a los Marker2D del nivel.
# Lo rellenas desde el Inspector arrastrando cada Marker2D.
@export var puntos_patrulla: Array[NodePath] = []

# Referencias a los nodos hijos
@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var area_deteccion: Area2D    = $AreaDeteccion
@onready var fsm: Node                 = $FSM

# Lista resuelta de nodos reales (se llena en _ready)
var puntos_resueltos: Array[Node2D] = []

# El goblin que el enemigo ha detectado (null si no ve a nadie)
var goblin_detectado: goblin_principal = null

func _ready():
	# Convertimos los NodePath exportados en referencias reales a Node2D
	for path in puntos_patrulla:
		puntos_resueltos.append(get_node(path))

	# Inicializamos la FSM pasándole el enemigo y los puntos
	fsm.inicializar(self)


func _physics_process(delta):
	# La FSM decide la velocidad cada frame
	fsm.tick(delta)
	# Aplicamos el movimiento (NavigationAgent2D ya esquiva obstáculos)
	move_and_slide()

# ── Señales del área de detección ──────────────────────────

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	# El goblin salió del área (o se escondió dentro de ella — eso lo
	# gestiona el estado Alerta directamente comprobando body.escondido)
	if body is goblin_principal:
		goblin_detectado = null
		fsm.cambiar_estado("investigar")


func _on_area_deteccion_body_entered(body: Node2D) -> void:
	# Solo reaccionamos al goblin_principal y solo si no está escondido
	if body is goblin_principal and not body.escondido:
		goblin_detectado = body
		fsm.cambiar_estado("alerta")
