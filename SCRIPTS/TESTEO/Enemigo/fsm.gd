extends Node

var enemigo: Enemigo

@onready var estado_patrulla:   Node = $EstadoPatrulla
@onready var estado_alerta:     Node = $EstadoAlerta
@onready var estado_investigar: Node = $EstadoInvestigar

var estado_activo: Node = null

func inicializar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	estado_patrulla.configurar(enemigo)
	estado_alerta.configurar(enemigo)
	estado_investigar.configurar(enemigo)
	cambiar_estado("patrulla")

func tick(delta: float):
	if estado_activo:
		estado_activo.tick(delta)

func cambiar_estado(nombre: String):
	if estado_activo and estado_activo.has_method("al_salir"):
		estado_activo.al_salir()
	match nombre:
		"patrulla":   estado_activo = estado_patrulla
		"alerta":     estado_activo = estado_alerta
		"investigar": estado_activo = estado_investigar
	if estado_activo.has_method("al_entrar"):
		estado_activo.al_entrar()
