extends CharacterBody2D
class_name Enemigo

@export var puntos_patrulla: Array[NodePath] = []

@onready var agente: NavigationAgent2D = $NavigationAgent2D
@onready var area_deteccion: Area2D    = $AreaDeteccion
@onready var fsm: Node                 = $FSM

var puntos_resueltos: Array[Node2D] = []
var goblin_detectado: goblin_principal = null

func _ready():
	for path in puntos_patrulla:
		puntos_resueltos.append(get_node(path))
	fsm.inicializar(self)
	area_deteccion.body_entered.connect(_on_area_body_entered)
	area_deteccion.body_exited.connect(_on_area_body_exited)

func _physics_process(delta):
	fsm.tick(delta)
	move_and_slide()

func _on_area_body_entered(body):
	if body is goblin_principal and not body.escondido:
		goblin_detectado = body
		fsm.cambiar_estado("alerta")

func _on_area_body_exited(body):
	if body is goblin_principal:
		goblin_detectado = null
		fsm.cambiar_estado("investigar")
