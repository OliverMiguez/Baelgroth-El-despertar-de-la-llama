# Hereda de nuestra clase base para todos los estados
extends modelo_estados

# Dirección de respaldo a la que se moverá si no hay puntos configurados
var direccion_respaldo: Vector2 = Vector2.RIGHT
# Tiempo total que durará la patrulla si no hay puntos (en segundos)
var tiempo_patrulla: float = 2.0
# Temporizador interno para contar el tiempo restante sin puntos
var tiempo_restante: float = 0.0
# Índice del punto de patrulla actual al que se dirige el enemigo
var indice_punto_actual: int = 0

# Función que se ejecuta al entrar a este estado
func on_enter() -> void:
	# Verificamos si hay puntos de patrulla configurados en el enemigo padre
	if enemigo_padre.puntos_patrulla.size() > 0:
		# Si el índice se salió de los límites por algún cambio, lo reiniciamos
		if indice_punto_actual >= enemigo_padre.puntos_patrulla.size():
			# Reseteamos el índice al primer punto
			indice_punto_actual = 0
		# Obtenemos la posición global del punto de patrulla objetivo
		var objetivo = enemigo_padre.puntos_patrulla[indice_punto_actual].global_position
		# Calculamos el vector de dirección hacia ese punto
		var direccion = (objetivo - enemigo_padre.global_position).normalized()
		# Reproducimos la animación de movimiento según la dirección calculada
		enemigo_padre.reproducir_animacion_movimiento(direccion)
	# Si no hay puntos configurados, usamos el comportamiento de respaldo básico
	else:
		# Asigna el tiempo de patrulla restante al valor configurado
		tiempo_restante = tiempo_patrulla
		# Reproduce la animación de movimiento con la dirección de respaldo
		enemigo_padre.reproducir_animacion_movimiento(direccion_respaldo)

# Función de actualización física ejecutada frame a frame
func in_proccess() -> void:
	# Si detectamos al jugador cerca y no está oculto
	if detectar_jugador():
		# Cambiamos al estado de ataque de inmediato
		get_parent().cambiar_estado(get_parent().ataque)
		# Salimos de la función actual
		return
	
	# Verificamos si hay puntos de patrulla configurados en el enemigo padre
	if enemigo_padre.puntos_patrulla.size() > 0:
		# Obtenemos la posición global del punto de patrulla objetivo
		var objetivo = enemigo_padre.puntos_patrulla[indice_punto_actual].global_position
		# Calculamos el vector de dirección hacia ese punto
		var direccion = (objetivo - enemigo_padre.global_position).normalized()
		# Asignamos la velocidad de patrulla al cuerpo físico en esa dirección
		enemigo_padre.velocity = direccion * enemigo_padre.speed
		# Reproducimos la animación de movimiento adecuada según la dirección
		enemigo_padre.reproducir_animacion_movimiento(direccion)
		# Realiza el movimiento físico del enemigo y maneja colisiones
		enemigo_padre.move_and_slide()
		
		# Si la distancia física hacia el objetivo es menor a 10 píxeles
		if enemigo_padre.global_position.distance_to(objetivo) < 10.0:
			# Avanzamos al siguiente punto en el array de forma circular
			indice_punto_actual = (indice_punto_actual + 1) % enemigo_padre.puntos_patrulla.size()
			# Cambiamos al estado IDLE para pausar brevemente en el punto
			get_parent().cambiar_estado(get_parent().idle)
	# Comportamiento de respaldo si no hay ningún Marker2D asignado
	else:
		# Asigna la velocidad de patrulla de respaldo
		enemigo_padre.velocity = direccion_respaldo * enemigo_padre.speed
		# Reproduce la animación de movimiento según la dirección de respaldo
		enemigo_padre.reproducir_animacion_movimiento(direccion_respaldo)
		# Mueve físicamente al enemigo en el mapa
		enemigo_padre.move_and_slide()
		# Resta el tiempo transcurrido en el frame al temporizador
		tiempo_restante -= get_physics_process_delta_time()
		# Si el temporizador de patrulla ha finalizado
		if tiempo_restante <= 0.0:
			# Cambia el estado actual de la FSM de vuelta al estado IDLE
			get_parent().cambiar_estado(get_parent().idle)


# Función que se ejecuta al salir de este estado
func on_exit() -> void:
	# Si no hay puntos de patrulla (estamos en el modo de respaldo)
	if enemigo_padre.puntos_patrulla.size() == 0:
		# Invierte la dirección de respaldo para que patrulle en sentido opuesto
		direccion_respaldo = -direccion_respaldo

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
