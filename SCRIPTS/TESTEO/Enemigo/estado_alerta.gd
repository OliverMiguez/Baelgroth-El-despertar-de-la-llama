extends Node
@onready var animaciones: AnimatedSprite2D = $"../../AnimatedSprite2D"

var enemigo: Enemigo
var agente:  NavigationAgent2D

const VELOCIDAD            := 90.0
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

	var objetivo = enemigo.goblin_detectado

	if not objetivo:
		_iniciar_pausa_perdida(enemigo.global_position)
		return

	# Comprobamos si el objetivo es el goblin o algo sin escondido (como una piedra)
	# Las piedras no tienen .escondido, asi que solo aplicamos esa logica al goblin
	if objetivo is goblin_principal:
		if objetivo.escondido:
			if enemigo.goblin_fue_visto:
				_perseguir(objetivo, delta)
				return
			else:
				_iniciar_pausa_perdida(objetivo.global_position)
				return

	# Perseguimos el objetivo (goblin visible o piedra)
	_perseguir(objetivo, delta)

	if objetivo is goblin_principal:
		var distancia = enemigo.global_position.distance_to(objetivo.global_position)
		if distancia < 10.0:
			# TODO: aqui llamar a la escena o funcion de muerte del goblin
			pass
		
func _perseguir(goblin: Node2D, delta: float):
	_timer_recalculo -= delta
	if _timer_recalculo <= 0.0:
		agente.target_position = goblin.global_position
		_timer_recalculo = INTERVALO_RECALCULO
	if not agente.is_navigation_finished():
		var siguiente_pos = agente.get_next_path_position()
		var dir = (siguiente_pos - enemigo.global_position).normalized()
		enemigo.velocity = dir * VELOCIDAD
		_tratar_animaciones(dir)
		enemigo.actualizar_area_deteccion(dir) 
		

func _tratar_animaciones(dir:Vector2):
	# Si la velocidad es casi 0, aseguramos que esté en Idle
	if dir.length() < 0.1:
		animaciones.play("Idle")
		return

	# Determinamos la dirección principal (Horizontal o Vertical)
	if abs(dir.x) > abs(dir.y):
		# Movimiento Horizontal
		animaciones.play("Lateral")
		animaciones.flip_h = dir.x < 0 # True si va a la izquierda
	else:
		# Movimiento Vertical
		if dir.y > 0:
			animaciones.play("Abajo")
		else:
			animaciones.play("Arriba")
	

func _iniciar_pausa_perdida(punto: Vector2):
	_pausando_perdida   = true
	_timer_perdida      = TIEMPO_PAUSA_PERDIDA
	_ultimo_punto_visto = punto
	enemigo.velocity    = Vector2.ZERO
