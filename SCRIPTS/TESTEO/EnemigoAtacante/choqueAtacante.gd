# Hereda de nuestra clase base para todos los estados
extends modelo_estados

# Tiempo en segundos que durará el aturdimiento por el choque
var tiempo_aturdido: float = 1.5
# Temporizador interno para contar el tiempo restante de aturdimiento
var tiempo_restante: float = 0.0

# Función que se ejecuta al entrar al estado de choque
func on_enter() -> void:
	# Reproduce la animación de aturdimiento llamada "Atontado"
	enemigo_padre.animaciones.play("Atontado")
	# Detiene por completo el movimiento físico del enemigo
	enemigo_padre.velocity = Vector2.ZERO
	# Inicializa el temporizador restante con la duración configurada
	tiempo_restante = tiempo_aturdido


# Función de actualización física ejecutada frame a frame
func in_proccess() -> void:
	# Resta el tiempo transcurrido del frame al temporizador
	tiempo_restante -= get_physics_process_delta_time()
	# Si el tiempo de aturdimiento ha finalizado
	if tiempo_restante <= 0.0:
		# Cambia el estado actual de la FSM de vuelta al estado IDLE
		get_parent().cambiar_estado(get_parent().idle)
