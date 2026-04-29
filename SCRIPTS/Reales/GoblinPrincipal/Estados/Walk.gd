extends "res://SCRIPTS/Reales/GoblinPrincipal/Estados/State.gd"

# Cambio de estados
@export var idle_state:State
@export var rock_state:State

# Ejecuta este código cuando cambia a este estado
func on_enter():
	print("[Test]: Iniciando estado walk ")
	## Iniciar a continuación la animación del personaje
	## Los Inputs que se detectan
	#var up = Input.is_action_pressed("Arriba")
	#var down = Input.is_action_pressed("Abajo")
	#var left = Input.is_action_pressed("Izquierda")
	#var right = Input.is_action_pressed("Derecha")
	#
		## Diagonales
	#if up and right:
		#animation_player.play("correr_diagonal_wd")
	#elif up and left:
		#animation_player.play("correr_diagonal_aw")
	#elif down and right:
		#animation_player.play("correr_diagonal_sd")
	#elif down and left:
		#animation_player.play("correr_diagonal_as")
	#
	## Normales
	#elif up:
		#animation_player.play("correr_arriba")
	#elif down:
		#animation_player.play("correr_abajo")
	#elif left:
		#animation_player.play("correr_izquierda")
	#elif right:
		#animation_player.play("correr_derecha")

# Permite el cambio entre estados
func state_process(_delta:float) -> void:
	# Permite el cambio al estado de andar (walk)
		# Cambia al estado rock
	if Input.is_action_just_pressed("Lanzar") and father.velocity == Vector2.ZERO:
		next_state = rock_state
	
	elif father.velocity == Vector2.ZERO:
		next_state = idle_state
	
