extends Node

var enemigo: Enemigo
var agente:  NavigationAgent2D

const VELOCIDAD         := 60.0
const DISTANCIA_LLEGADA := 10.0
const TIEMPO_PAUSA      := 1.2

var _indice   := 0
var _pausando := false
var _timer    := 0.0

func configurar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	agente  = enemigo.agente

func al_entrar():
	if enemigo.puntos_resueltos.is_empty():
		push_warning("[Patrulla]: no hay puntos asignados.")
		return
	_pausando = false
	_timer    = 0.0
	_indice   = _punto_mas_cercano()
	_ir_al_punto(_indice)

func tick(delta: float):
	if enemigo.puntos_resueltos.is_empty():
		return

	if _pausando:
		_timer -= delta
		if _timer <= 0.0:
			_pausando = false
			_avanzar_punto()
		return

	if not agente.is_target_reachable():
		return

	var dist_al_punto = enemigo.global_position.distance_to(
		enemigo.puntos_resueltos[_indice].global_position
	)
	if agente.is_navigation_finished() or dist_al_punto < DISTANCIA_LLEGADA:
		_iniciar_pausa()
		return

	var siguiente_pos = agente.get_next_path_position()
	var dir = (siguiente_pos - enemigo.global_position).normalized()
	enemigo.velocity = dir * VELOCIDAD

func _iniciar_pausa():
	_pausando = true
	_timer    = TIEMPO_PAUSA
	enemigo.velocity = Vector2.ZERO

func _ir_al_punto(indice: int):
	agente.target_position = enemigo.puntos_resueltos[indice].global_position

func _avanzar_punto():
	_indice = (_indice + 1) % enemigo.puntos_resueltos.size()
	_ir_al_punto(_indice)

func _punto_mas_cercano() -> int:
	var menor_dist   := INF
	var mejor_indice := 0
	for i in enemigo.puntos_resueltos.size():
		var d = enemigo.global_position.distance_to(
			enemigo.puntos_resueltos[i].global_position
		)
		if d < menor_dist:
			menor_dist   = d
			mejor_indice = i
	return mejor_indice
