extends "res://SCRIPTS/Reales/GoblinPrincipal/Estados/State.gd"

# Cambio de estados
@export var walk_state:State
@export var idle_state:State

# Ejecuta este código cuando cambia a este estado
func on_enter():
	
	print("[Test]: Iniciando estado Rock ")
	# Iniciar a continuación la animación del personaje
	animation_player.play("Lanzar")
	await animation_player.animation_finished


# Permite el cambio entre estados
func state_process(_delta:float) -> void:
	if !father:
		return
		# Cambia a Idle
	if father.velocity != Vector2.ZERO and not Input.is_action_just_pressed("Lanzar"):
		next_state = idle_state
			
	# Permite el cambio al estado de andar (walk)
	elif father.velocity != Vector2.ZERO and not Input.is_action_just_pressed("Lanzar"):
		next_state = walk_state
