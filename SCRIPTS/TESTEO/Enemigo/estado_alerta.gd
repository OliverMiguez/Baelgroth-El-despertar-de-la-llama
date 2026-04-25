# ============================================================
# estado_alerta.gd
# El enemigo persigue al goblin mientras lo vea.
# Si el goblin se esconde, guarda su última posición
# y manda a la FSM al estado Investigar.
# ============================================================
extends Node

var enemigo: Enemigo
var agente:  NavigationAgent2D

# Velocidad de persecución (más rápido que la patrulla)
const VELOCIDAD := 110.0

# Cada cuántos segundos recalculamos el destino hacia el goblin.
# Recalcular cada frame es innecesario y algo costoso.
const INTERVALO_RECALCULO := 0.15

var _timer_recalculo := 0.0

# ── Configuración ───────────────────────────────────────────

func configurar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	agente  = enemigo.agente

func al_entrar():
	_timer_recalculo = 0.0
	print("[Alerta]: ¡Goblin detectado! Persiguiendo.")

# ── Tick ────────────────────────────────────────────────────

func tick(delta: float):
	var goblin = enemigo.goblin_detectado

	# Si no tenemos referencia al goblin algo fue mal; volvemos a patrullar
	if not goblin:
		enemigo.fsm.cambiar_estado("patrulla")
		return

	# Si el goblin se escondió estando dentro del área de detección
	if goblin.escondido:
		# Guardamos dónde lo vimos por última vez antes de perderlo
		enemigo.fsm.estado_investigar.ultimo_punto_visto = goblin.global_position
		enemigo.goblin_detectado = null
		enemigo.fsm.cambiar_estado("investigar")
		return

	# Recalculamos el destino periódicamente (no cada frame)
	_timer_recalculo -= delta
	if _timer_recalculo <= 0.0:
		agente.target_position = goblin.global_position
		_timer_recalculo = INTERVALO_RECALCULO

	# Nos movemos hacia el siguiente paso de la ruta
	if not agente.is_navigation_finished():
		var siguiente_pos = agente.get_next_path_position()
		var dir = (siguiente_pos - enemigo.global_position).normalized()
		enemigo.velocity = dir * VELOCIDAD
