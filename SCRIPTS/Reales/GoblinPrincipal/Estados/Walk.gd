extends "res://SCRIPTS/Reales/GoblinPrincipal/Estados/State.gd"

# Cambio de estados
@export var idle_state:State
@export var rock_state:State
@export var run_state:State

# Ejecuta este código cuando cambia a este estado
func on_enter():
	father.velocidad_andar = father.velocidad_andar_base
	if father.esta_corriendo == true:
		father.esta_corriendo = false
	#print("[Test]: Iniciando estado walk ")

# Permite el cambio entre estados
func state_process(_delta:float) -> void:
	# Manejo de animaciones de movimiento (antes en GoblinPrincipal.gd)
	actualizar_animacion_movimiento()

	# Cambia al estado rock
	#if Input.is_action_just_pressed("LanzarRecoger") and father.velocity == Vector2.ZERO and father.activar_lanzar_piedra == true:
		#next_state = rock_state
	if Input.is_action_just_pressed("LanzarRecoger") and father.activar_lanzar_piedra == true:
		next_state = rock_state
	
	if Input.is_action_pressed("correr"):
		next_state = run_state
	
	# CORREGIDO: usamos input_direction en lugar de velocity
	elif father.input_direction == Vector2.ZERO:
		next_state = idle_state

func actualizar_animacion_movimiento():
	var input_direction = father.input_direction
	
	if input_direction.x != 0 and input_direction.y != 0:
		if input_direction.y == -1: # Arriba
			if input_direction.x == 1:
				animation_player.play("correr_diagonal_wd")
				animation_player.flip_h = false
				father.last_input = "diagonal_derecha_arrbia"
			else:
				animation_player.play("correr_diagonal_aw")
				animation_player.flip_h = false
				father.last_input = "diagonal_izquierda_arriba"
		else: # Abajo
			if input_direction.x == 1:
				animation_player.play("correr_diagonal_sd")
				animation_player.flip_h = false
				father.last_input = "diagonal_derecha_abajo"
			else:
				animation_player.play("correr_diagonal_as")
				animation_player.flip_h = false
				father.last_input = "diagonal_izquierda_abajo"
	
	elif input_direction.y == -1:
		animation_player.play("correr_arriba")
		animation_player.flip_h = false
		father.last_input = "arriba"
	elif input_direction.y == 1:
		animation_player.play("correr_abajo")
		animation_player.flip_h = false
		father.last_input = "abajo"
	elif input_direction.x == -1:
		animation_player.play("correr_izquierda")
		animation_player.flip_h = false
		father.last_input = "izquierda"
	elif input_direction.x == 1:
		animation_player.play("correr_derecha")
		animation_player.flip_h = false
		father.last_input = "derecha"
	
