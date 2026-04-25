extends Node

var enemigo: Enemigo
var agente:  NavigationAgent2D

const VELOCIDAD := 70.0

var ultimo_punto_visto := Vector2.ZERO

func configurar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo
	agente  = enemigo.agente

func al_entrar():
	if ultimo_punto_visto == Vector2.ZERO:
		enemigo.fsm.cambiar_estado("patrulla")
		return
	agente.target_position = ultimo_punto_visto

func tick(_delta: float):
	if enemigo.goblin_detectado and not enemigo.goblin_detectado.escondido:
		enemigo.fsm.cambiar_estado("alerta")
		return

	if agente.is_navigation_finished():
		ultimo_punto_visto = Vector2.ZERO
		enemigo.fsm.cambiar_estado("patrulla")
		return

	var siguiente_pos = agente.get_next_path_position()
	var dir = (siguiente_pos - enemigo.global_position).normalized()
	enemigo.velocity = dir * VELOCIDAD
