extends Node

@onready var animaciones: AnimatedSprite2D = $"../../AnimatedSprite2D"

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
	# Si el goblin reaparece visible, volvemos a perseguirlo
	if enemigo.goblin_detectado and not enemigo.goblin_detectado.escondido:
		enemigo.fsm.cambiar_estado("alerta")
		return

	if agente.is_navigation_finished():
		ultimo_punto_visto = Vector2.ZERO
		animaciones.play("Idle")
		enemigo.fsm.cambiar_estado("patrulla")
		return

	var siguiente_pos = agente.get_next_path_position()
	var dir = (siguiente_pos - enemigo.global_position).normalized()
	enemigo.velocity = dir * VELOCIDAD
	_tratar_animaciones(dir)

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
