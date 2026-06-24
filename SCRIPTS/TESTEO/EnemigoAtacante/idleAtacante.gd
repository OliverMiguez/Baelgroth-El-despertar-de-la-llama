# Hereda de nuestra clase base para todos los estados
extends modelo_estados

# Tiempo en segundos que el enemigo permanecerá en reposo
var tiempo_espera: float = 2.0
# Temporizador interno para contar el tiempo transcurrido
var tiempo_restante: float = 0.0

# Función que se ejecuta al entrar a este estado
func on_enter() -> void:
	# Reproduce la animación de estar quieto llamada "Idle"
	enemigo_padre.animaciones.play("Idle")
	# Detiene por completo el movimiento del enemigo en física
	enemigo_padre.velocity = Vector2.ZERO
	# Resetea el contador de tiempo al valor inicial configurado
	tiempo_restante = tiempo_espera

# Función de actualización ejecutada por la FSM en cada frame físico
func in_proccess() -> void:
	# Si el jugador se encuentra cerca y no está escondido
	if detectar_jugador():
		# Cambiamos al estado de ataque inmediatamente
		get_parent().cambiar_estado(get_parent().ataque)
		# Salimos de la función actual
		return
	
	# Resta el tiempo transcurrido del frame actual al temporizador
	tiempo_restante -= get_physics_process_delta_time()
	# Si el temporizador ha llegado a cero o menos
	if tiempo_restante <= 0.0:
		# Cambia el estado actual de la FSM al estado de patrulla
		get_parent().cambiar_estado(get_parent().patrulla)

# Función interna para buscar y detectar al jugador dentro del rango
func detectar_jugador() -> bool:
	# Variable local para almacenar la referencia al jugador
	var jugador: goblin_principal = null
	# Buscamos todos los nodos en el grupo "jugador"
	var nodos = get_tree().get_nodes_in_group("jugador")
	# Si el grupo contiene al menos un nodo
	if nodos.size() > 0:
		# Obtenemos el primer elemento y lo asignamos como jugador
		jugador = nodos[0] as goblin_principal
	# Si no se encontró por grupo
	else:
		# Recorremos los nodos hijos de la escena actual activa
		for hijo in get_tree().current_scene.get_children():
			# Si el nodo hijo es del tipo de la clase goblin_principal
			if hijo is goblin_principal:
				# Guardamos el nodo hijo como jugador
				jugador = hijo
				# Terminamos de buscar al salir del bucle
				break
	
	# Si el jugador existe y no se encuentra oculto en un arbusto
	if jugador != null and not jugador.escondido:
		# Calculamos la distancia en píxeles hacia él
		var distancia = enemigo_padre.global_position.distance_to(jugador.global_position)
		# Si está dentro del rango de visión de 150 píxeles
		if distancia < 150.0:
			# Retornamos verdadero indicando que fue detectado
			return true
	
	# Retornamos falso si no se cumple ninguna condición
	return false
