# ============================================================
# estado_investigar.gd
# El enemigo va al último lugar donde vio al goblin.
# Si llega y no encuentra nada, vuelve a patrullar.
# ============================================================
extends Node

var enemigo: Enemigo
var agente:  NavigationAgent2D

const VELOCIDAD := 70.0

# La posición donde el goblin fue visto por última vez.
# La asigna estado_alerta.gd antes de cambiar a este estado.
var ultimo_punto_visto := Vector2.ZERO

# ── Configuración ───────────────────────────────────────────

func configurar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	agente  = enemigo.agente

func al_entrar():
	if ultimo_punto_visto == Vector2.ZERO:
		# Si no tenemos punto guardado, volvemos a patrullar directamente
		enemigo.fsm.cambiar_estado("patrulla")
		return
	print("[Investigar]: Yendo al último punto visto: ", ultimo_punto_visto)
	agente.target_position = ultimo_punto_visto

# ── Tick ────────────────────────────────────────────────────

func tick(_delta: float):
	# Si el goblin reaparece mientras investigamos, volvemos a alerta
	if enemigo.goblin_detectado and not enemigo.goblin_detectado.escondido:
		enemigo.fsm.cambiar_estado("alerta")
		return

	# Llegamos al punto — el goblin no está, volvemos a patrullar
	if agente.is_navigation_finished():
		print("[Investigar]: No encontré nada. Volviendo a patrullar.")
		ultimo_punto_visto = Vector2.ZERO
		enemigo.fsm.cambiar_estado("patrulla")
		return

	# Caminamos hacia el punto
	var siguiente_pos = agente.get_next_path_position()
	var dir = (siguiente_pos - enemigo.global_position).normalized()
	enemigo.velocity = dir * VELOCIDAD
