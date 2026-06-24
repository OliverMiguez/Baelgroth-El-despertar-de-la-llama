# Hereda de nuestra clase base para todos los estados
extends modelo_estados

# Función que se ejecuta al entrar al estado de ataque
func on_enter() -> void:
	# No reproducimos animación aquí directamente, se actualizará dinámicamente en in_proccess
	pass

# Función de actualización física ejecutada en cada frame
func in_proccess() -> void:
	# Obtenemos la referencia al jugador en la escena
	var jugador = obtener_jugador()
	
	# Si encontramos al jugador y este no se encuentra escondido
	if jugador != null and not jugador.escondido:
		# Calculamos el vector de dirección normalizado hacia el jugador
		var direccion = (jugador.global_position - enemigo_padre.global_position).normalized()
		# Asignamos la velocidad de física multiplicada por la velocidad de ataque
		enemigo_padre.velocity = direccion * enemigo_padre.attack_speed
		# Reproducimos la animación de embestida adecuada según la dirección del ataque
		enemigo_padre.reproducir_animacion_embestida(direccion)
		# Ejecuta el movimiento de físicas de Godot y desliza por colisiones
		enemigo_padre.move_and_slide()

		
		# Si durante el movimiento chocó con algo (paredes, jugador, etc.)
		if enemigo_padre.get_slide_collision_count() > 0:
			# Cambiamos al estado de choque (aturdido)
			get_parent().cambiar_estado(get_parent().choque)
	# Si el jugador se ha escondido o ya no está en la escena
	else:
		# Cambiamos de vuelta al estado IDLE
		get_parent().cambiar_estado(get_parent().idle)

# Función interna para buscar y obtener la referencia al jugador
func obtener_jugador() -> goblin_principal:
	# Buscamos todos los nodos en el grupo "jugador"
	var nodos = get_tree().get_nodes_in_group("jugador")
	# Si el grupo contiene al menos un nodo
	if nodos.size() > 0:
		# Devolvemos el primer nodo del grupo casteado al tipo de jugador
		return nodos[0] as goblin_principal
	# Si no se encuentra por grupo
	else:
		# Recorremos los nodos hijos de la escena actual activa
		for hijo in get_tree().current_scene.get_children():
			# Si el nodo hijo es del tipo de la clase goblin_principal
			if hijo is goblin_principal:
				# Devolvemos el nodo hijo como jugador encontrado
				return hijo
	
	# Retornamos nulo si no se encontró en ninguna parte
	return null
