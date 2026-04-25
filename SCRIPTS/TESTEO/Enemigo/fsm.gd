# ============================================================
# fsm_enemigo.gd
# Máquina de estados finita del enemigo.
# Gestiona qué estado está activo y delega el tick a ese estado.
# ============================================================
extends Node

# Referencia al CharacterBody2D padre
var enemigo: Enemigo

# Referencias a cada estado hijo
@onready var estado_patrulla:   Node = $EstadoPatrulla
@onready var estado_alerta:     Node = $EstadoAlerta
@onready var estado_investigar: Node = $EstadoInvestigar

# El estado activo en este momento
var estado_activo: Node = null

func inicializar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo

	# Pasamos la referencia del enemigo a cada estado
	estado_patrulla.configurar(enemigo)
	estado_alerta.configurar(enemigo)
	estado_investigar.configurar(enemigo)

	# Empezamos en patrulla
	cambiar_estado("patrulla")

func tick(delta: float):
	if estado_activo:
		estado_activo.tick(delta)

func cambiar_estado(nombre: String):
	# Salida del estado anterior
	if estado_activo and estado_activo.has_method("al_salir"):
		estado_activo.al_salir()

	# Seleccionamos el nuevo estado
	match nombre:
		"patrulla":   estado_activo = estado_patrulla
		"alerta":     estado_activo = estado_alerta
		"investigar": estado_activo = estado_investigar

	print("[FSM Enemigo]: Cambia a → ", nombre)

	# Entrada al nuevo estado
	if estado_activo.has_method("al_entrar"):
		estado_activo.al_entrar()
