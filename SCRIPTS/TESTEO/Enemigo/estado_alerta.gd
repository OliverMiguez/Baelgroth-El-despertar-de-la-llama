extends Node

var enemigo: Enemigo
var agente:  NavigationAgent2D

const VELOCIDAD            := 110.0
const INTERVALO_RECALCULO  := 0.15
const TIEMPO_PAUSA_PERDIDA := 1.8

var _timer_recalculo    := 0.0
var _pausando_perdida   := false
var _timer_perdida      := 0.0
var _ultimo_punto_visto := Vector2.ZERO

func configurar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	agente  = enemigo.agente

func al_entrar():
	_pausando_perdida = false
	_timer_perdida    = 0.0
	_timer_recalculo  = 0.0

func al_salir():
	_pausando_perdida = false
	_timer_perdida    = 0.0

func tick(delta: float):
	if _pausando_perdida:
		enemigo.velocity = Vector2.ZERO
		_timer_perdida -= delta
		if _timer_perdida <= 0.0:
			enemigo.fsm.estado_investigar.ultimo_punto_visto = _ultimo_punto_visto
			enemigo.fsm.cambiar_estado("investigar")
		return

	var goblin = enemigo.goblin_detectado

	if not goblin:
		_iniciar_pausa_perdida(enemigo.global_position)
		return

	if goblin.escondido:
		_iniciar_pausa_perdida(goblin.global_position)
		enemigo.goblin_detectado = null
		return

	_timer_recalculo -= delta
	if _timer_recalculo <= 0.0:
		agente.target_position = goblin.global_position
		_timer_recalculo = INTERVALO_RECALCULO

	if not agente.is_navigation_finished():
		var siguiente_pos = agente.get_next_path_position()
		var dir = (siguiente_pos - enemigo.global_position).normalized()
		enemigo.velocity = dir * VELOCIDAD

func _iniciar_pausa_perdida(punto: Vector2):
	_pausando_perdida   = true
	_timer_perdida      = TIEMPO_PAUSA_PERDIDA
	_ultimo_punto_visto = punto
	enemigo.velocity    = Vector2.ZERO
