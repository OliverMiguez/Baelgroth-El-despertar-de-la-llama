extends Node
@onready var animaciones: AnimatedSprite2D = $"../../AnimatedSprite2D"

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
	# Si no se ha visto o perdido al goblin principal
	if _pausando_perdida:
		enemigo.velocity = Vector2.ZERO
		_timer_perdida -= delta
		if _timer_perdida <= 0.0:
			enemigo.fsm.estado_investigar.ultimo_punto_visto = _ultimo_punto_visto
			enemigo.fsm.cambiar_estado("investigar")
		return

# Referencia del goblin
	var goblin = enemigo.goblin_detectado

# Si no se detecto al goblin
	if not goblin:
		_iniciar_pausa_perdida(enemigo.global_position)
		return

# Si el goblin esta escondido
	if goblin.escondido:
		_iniciar_pausa_perdida(goblin.global_position)
		enemigo.goblin_detectado = null
		return
# Perseguimos al goblin
	_timer_recalculo -= delta
	if _timer_recalculo <= 0.0:
		agente.target_position = goblin.global_position # posicion del goblin
		_timer_recalculo = INTERVALO_RECALCULO
		

	if not agente.is_navigation_finished():
		var siguiente_pos = agente.get_next_path_position()
		var dir = (siguiente_pos - enemigo.global_position).normalized()
		enemigo.velocity = dir * VELOCIDAD
		
		_tratar_animaciones(dir)

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
