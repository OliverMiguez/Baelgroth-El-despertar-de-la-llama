extends Node

@onready var animaciones: AnimatedSprite2D = $"../../AnimatedSprite2D"

var enemigo: Enemigo
var agente:  NavigationAgent2D

const VELOCIDAD        := 70.0
const MARGEN_LLEGADA   := 20.0  # pixeles de distancia minima a la piedra
const TIEMPO_REACCION  := 2.5   # segundos esperando en el sitio

# Fases internas del estado
enum Fase { ESPERANDO, VIAJANDO, REACCIONANDO }

var _fase:            Fase    = Fase.VIAJANDO
var _timer_reaccion:  float   = 0.0
var _posicion_piedra: Vector2 = Vector2.ZERO
var _piedra_ref:	Node2D = null # Guardamos referencia para desconectar la señal de la piedra

func configurar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	agente  = enemigo.agente

func al_entrar():
	print("Estado investigar piedra")
	_fase = Fase.ESPERANDO  
	_timer_reaccion = 0.0
	enemigo.velocity = Vector2.ZERO

	var piedra = enemigo.goblin_detectado
	if not piedra or not piedra is pielda:
		enemigo.fsm.cambiar_estado("patrulla")
		return

	_piedra_ref = piedra

	if piedra.direction == Vector2.ZERO:
		# Ya parada, viajamos directamente
		_iniciar_viaje(piedra.global_position)
	else:
		# Aun moviéndose, esperamos la señal
		if not piedra.piedra_detenida.is_connected(_on_piedra_detenida):
			piedra.piedra_detenida.connect(_on_piedra_detenida)
		
func al_salir():
	_fase = Fase.ESPERANDO
	# Limpiamos la señal si quedó conectada
	if _piedra_ref and _piedra_ref.piedra_detenida.is_connected(_on_piedra_detenida):
		_piedra_ref.piedra_detenida.disconnect(_on_piedra_detenida)
	_piedra_ref = null

func tick(delta: float):
	# Si mientras viajamos a la piedra aparece el goblin, cancelamos esto
	if enemigo.goblin_en_area != null and not enemigo.goblin_en_area.escondido:
		enemigo.fsm.cambiar_estado("alerta")
		return

	match _fase:
		Fase.ESPERANDO:
			# El enemigo se queda quieto, la señal se encarga de avanzar
			enemigo.velocity = Vector2.ZERO
			animaciones.play("Idle")
		Fase.VIAJANDO:
			_tick_viajando()
		Fase.REACCIONANDO:
			_tick_reaccionando(delta)
			
# Se llama automaticamente cuando la señal de la piedra avisa que paro
func _on_piedra_detenida():
	if _piedra_ref:
		_iniciar_viaje(_piedra_ref.global_position)

func _iniciar_viaje(posicion: Vector2):
	_posicion_piedra = posicion
	_fase = Fase.VIAJANDO

	# Calculamos el destino con margen para no quedarnos encima
	var direccion_al_enemigo = (enemigo.global_position - _posicion_piedra).normalized()
	var destino = _posicion_piedra + direccion_al_enemigo * MARGEN_LLEGADA
	agente.target_position = destino

func _tick_viajando():
	if agente.is_navigation_finished():
		# Llegamos al punto, ahora reaccionamos
		_fase           = Fase.REACCIONANDO
		_timer_reaccion = TIEMPO_REACCION
		enemigo.velocity = Vector2.ZERO
		animaciones.play("Idle")

		# TODO: aqui reproducir la animacion de confusion o reaccion del enemigo
		# ejemplo: animaciones.play("Confusion") o animaciones.play("Sorpresa")
		return

	var siguiente_pos = agente.get_next_path_position()
	var dir = (siguiente_pos - enemigo.global_position).normalized()
	enemigo.velocity = dir * VELOCIDAD
	_tratar_animaciones(dir)

func _tick_reaccionando(delta: float):
	enemigo.velocity = Vector2.ZERO
	_timer_reaccion -= delta
	if _timer_reaccion <= 0.0:
		# Terminamos la reaccion, volvemos a patrullar
		enemigo.fsm.cambiar_estado("patrulla")

func _tratar_animaciones(dir: Vector2):
	if dir.length() < 0.1:
		animaciones.play("Idle")
		return
	if abs(dir.x) > abs(dir.y):
		animaciones.play("Lateral")
		animaciones.flip_h = dir.x < 0
	else:
		if dir.y > 0:
			animaciones.play("Abajo")
		else:
			animaciones.play("Arriba")
