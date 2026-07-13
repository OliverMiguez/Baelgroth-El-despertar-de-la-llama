extends "res://SCRIPTS/Reales/GoblinPrincipal/Estados/State.gd"

# Cambio de estados
@export var walk_state:State
@export var rock_state:State
@export var run_state:State

# Ejecuta este código cuando cambia a este estado
func on_enter():
	if father.esta_corriendo == true:
		father.esta_corriendo = false
	#print("[Test]: Iniciando estado idle ")
	
	# Seleccionamos la animación de Idle correcta según la última dirección
	match father.last_input:
		"arriba":
			animation_player.flip_h = false
			animation_player.play("Idle_arriba")
		"abajo":
			animation_player.flip_h = false
			animation_player.play("Idle_abajo")
		"izquierda":
			animation_player.flip_h = true
			animation_player.play("Idle")
		"derecha":
			animation_player.flip_h = false
			animation_player.play("Idle")
		"diagonal_derecha_arrbia":
			animation_player.flip_h = false
			animation_player.play("Idle")
		"diagonal_izquierda_arriba":
			animation_player.flip_h = true
			animation_player.play("Idle")
		"diagonal_derecha_abajo":
			animation_player.flip_h = false
			animation_player.play("Idle")
		"diagonal_izquierda_abajo":
			animation_player.flip_h = true
			animation_player.play("Idle")
		_:
			animation_player.play("Idle")

# Permite el cambio entre estados
func state_process(_delta:float) -> void:
	if !father:
		return
		
	# Cambia al estado rock
	if Input.is_action_just_pressed("LanzarRecoger") and father.velocity == Vector2.ZERO and father.activar_lanzar_piedra == true:
		next_state = rock_state
	elif father.velocity != Vector2.ZERO and Input.is_action_pressed("correr"):
		next_state = run_state
	# Permite el cambio al estado de andar (walk)
	elif father.velocity != Vector2.ZERO:
		next_state = walk_state
		
