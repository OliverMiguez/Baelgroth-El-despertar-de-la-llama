# ============================================================
# estado_patrulla.gd
# El enemigo camina en bucle entre los Marker2D definidos
# en el Inspector del nodo Enemigo.
# NavigationAgent2D calcula la ruta y evita obstáculos solo.
# ============================================================
extends Node

var enemigo: Enemigo
var agente:  NavigationAgent2D

# Velocidad de movimiento en patrulla (píxeles/segundo)
const VELOCIDAD := 60.0

# Distancia en píxeles para considerar que llegó al punto destino
const DISTANCIA_LLEGADA := 10.0

# Índice del punto de patrulla actual
var _indice := 0

# ── Configuración ───────────────────────────────────────────

func configurar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	agente  = enemigo.agente

# Se llama al entrar en este estado
func al_entrar():
	if enemigo.puntos_resueltos.is_empty():
		push_warning("[EstadoPatrulla]: No hay puntos de patrulla asignados.")
		return
	# Retomamos desde el punto más cercano para no hacer teleports raros
	_indice = _punto_mas_cercano()
	_ir_al_punto(_indice)

# ── Tick (se ejecuta cada physics frame) ───────────────────

func tick(_delta: float):
	if enemigo.puntos_resueltos.is_empty():
		return

	# Esperamos a que el agente tenga la ruta calculada
	if not agente.is_target_reachable():
		return

	# ¿Llegamos al punto actual?
	var dist = enemigo.global_position.distance_to(
		enemigo.puntos_resueltos[_indice].global_position
	)
	if agente.is_navigation_finished() or dist < DISTANCIA_LLEGADA:
		_avanzar_punto()
		return

	# Calculamos la dirección hacia el siguiente paso de la ruta
	var siguiente_pos = agente.get_next_path_position()
	var dir = (siguiente_pos - enemigo.global_position).normalized()
	enemigo.velocity = dir * VELOCIDAD

# ── Helpers ─────────────────────────────────────────────────

func _ir_al_punto(indice: int):
	agente.target_position = enemigo.puntos_resueltos[indice].global_position

func _avanzar_punto():
	# Bucle circular: 0 → 1 → 2 → 3 → 0 → ...
	_indice = (_indice + 1) % enemigo.puntos_resueltos.size()
	_ir_al_punto(_indice)

func _punto_mas_cercano() -> int:
	var menor_dist := INF
	var mejor := 0
	for i in enemigo.puntos_resueltos.size():
		var d = enemigo.global_position.distance_to(
			enemigo.puntos_resueltos[i].global_position
		)
		if d < menor_dist:
			menor_dist = d
			mejor = i
	return mejor
