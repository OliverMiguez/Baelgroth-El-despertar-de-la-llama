extends "res://SCRIPTS/Reales/GoblinPrincipal/Estados/State.gd"
#
## PROCEDIMIENTO DE ESTADO: LANZAR
## Este estado se encarga de sincronizar la animación del personaje 
## con la activación física de la piedra.
#
func on_enter() -> void:
	pass
	## PROCEDIMIENTO DE ENTRADA:
	## 1. Reproducir la animación de lanzamiento.
	## 2. Nota: La animación debe tener un "Evento de Método" o señal 
	##    para saber cuándo soltar la piedra físicamente.
	#if animation_player:
		#animation_player.play("lanzar")
	#
	## Si el personaje tiene una referencia a la piedra que recogió:
	## (Suponiendo que el 'father' tiene una variable 'piedra_cargada')
	#if father.piedra_cargada:
		## Conectamos con el final de la animación para salir de este estado
		#if not animation_player.animation_finished.is_connected(_on_lanzamiento_finalizado):
			#animation_player.animation_finished.connect(_on_lanzamiento_finalizado)
#
func state_process(_delta: float) -> void:
	pass
	## PROCEDIMIENTO DE ACTUALIZACIÓN:
	## Durante el lanzamiento, solemos querer que el personaje no se mueva.
	## Por lo tanto, no aplicamos lógica de movimiento aquí.
	#pass
#
## Esta función debe ser llamada por un evento en el frame exacto de la animación
func ejecutar_disparo_fisico() -> void:
	pass
	## PROCEDIMIENTO DE ACCIÓN:
	## 1. Validar que exista una piedra para lanzar.
	## 2. Llamar al método 'lanzar' de la piedra pasando dirección y fuerza.
	#if father.piedra_cargada:
		#var direccion = Vector2.RIGHT # O la dirección hacia donde mire el father
		#var fuerza = 600.0
		#
		#father.piedra_cargada.lanzar(direccion, fuerza)
		#father.piedra_cargada = null # Limpiamos la referencia en el padre
#
func _on_lanzamiento_finalizado(_anim_name: String) -> void:
	pass
	## PROCEDIMIENTO DE SALIDA/TRANSICIÓN:
	## Una vez terminada la animación de lanzar, volvemos a Idle.
	#if _anim_name == "lanzar":
		#next_state = father.get_node("FSM/Idle")
#
func on_exit() -> void:
	pass
	## PROCEDIMIENTO DE CIERRE:
	## Desconectamos señales para evitar errores en memoria.
	#if animation_player.animation_finished.is_connected(_on_lanzamiento_finalizado):
		#animation_player.animation_finished.disconnect(_on_lanzamiento_finalizado)
