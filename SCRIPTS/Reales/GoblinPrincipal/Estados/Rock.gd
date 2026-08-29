extends "res://SCRIPTS/Reales/GoblinPrincipal/Estados/State.gd"

# Cambio de estados
@export var walk_state:State
@export var idle_state:State

# Diccionario que recoge el input y la acción que debe ejecutar
const LANZAMIENTOS = {
	"arriba": "Lanzar_arriba",
	"abajo" :  "Lanzar_abajo"
}


# Ejecuta este código cuando cambia a este estado
func on_enter():
	if father.esta_corriendo == true:
		father.esta_corriendo = false
	
	print("[Test]: Iniciando estado Rock ")
	father.lanzar_piedra()
	# Conectamos la señal para saber cuando termina de lanzar
	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)
	
	# Iniciar a continuación la animación del personaje
	if ControlPiedras.recoger_piedras == false:
		var dir = father.last_input
		animation_player.flip_h = "izquierda" in dir
		# El .get lo que hace es si el input que se busca es arriba o abajo
		# accede al diccionario si no ejecuta  lanzamiento lateral
		animation_player.play(LANZAMIENTOS.get(dir, "Lanzar_lateral")) 
		
		## DEPRECADO ( versión antigua )
		#if father.last_input == "arriba":
			#animation_player.flip_h = false
			#animation_player.play("Lanzar_arriba")
		#elif father.last_input == "abajo":
			#animation_player.flip_h = false
			#animation_player.play("Lanzar_abajo")
		#elif father.last_input == "izquierda":
			#animation_player.flip_h = true
			#animation_player.play("Lanzar_lateral")
		#elif father.last_input == "derecha":
			#animation_player.flip_h = false
			#animation_player.play("Lanzar_lateral")
		#elif father.last_input == "diagonal_derecha_arrbia":
			#animation_player.flip_h = false
			#animation_player.play("Lanzar_lateral")
		#elif father.last_input == "diagonal_izquierda_arriba":
			#animation_player.flip_h = true
			#animation_player.play("Lanzar_lateral")
		#elif father.last_input == "diagonal_derecha_abajo":
			#animation_player.flip_h = false
			#animation_player.play("Lanzar_lateral")
		#elif father.last_input == "diagonal_izquierda_abajo":
			#animation_player.flip_h = true
			#animation_player.play("Lanzar_lateral")

func on_exit():
	# Desconectamos la señal al salir para evitar problemas
	if animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished():
	# Cuando la animación de lanzar termina, volvemos a Idle
	next_state = idle_state

# Permite el cambio entre estados
func state_process(_delta:float) -> void:
	if !father:
		return
	
	# Si el jugador se mueve mientras lanza, cancelamos y vamos a caminar
	if father.velocity != Vector2.ZERO:
		next_state = walk_state
	#elif father.total_piedras <= 0: # Cuando no tenemos piedra, cambiar a un estado en el que ejecute una animacion de error no tienes mas piedras
		#next_state = idle_state
