# Hereda del nodo básico de Godot
extends Node
# Define el nombre de esta clase para poder instanciarla o tiparla
class_name fsm_enemigo_atacante

# Obtiene la referencia del nodo IDLE
@onready var idle: modelo_estados = $IDLE
# Obtiene la referencia del nodo PATRULLA
@onready var patrulla: modelo_estados = $PATRULLA
# Obtiene la referencia del nodo ATAQUE
@onready var ataque: modelo_estados = $ATAQUE
# Obtiene la referencia del nodo CHOQUE
@onready var choque: modelo_estados = $CHOQUE

# Variable para almacenar el estado que se encuentra en ejecución
var estado_actual: modelo_estados = null
# Almacenará la referencia al enemigo que es padre de esta FSM
var enemigo_padre: EnemigoAtacante = null

# Función inicial de Godot
func _ready() -> void:
	# Obtenemos al enemigo padre casteado a su tipo correspondiente
	enemigo_padre = get_parent() as EnemigoAtacante
	# Si el enemigo padre aún no ha completado su inicialización
	if not enemigo_padre.is_node_ready():
		# Esperamos a que el enemigo padre emita su señal de listo (ready)
		await enemigo_padre.ready
	
	# Recorremos todos los hijos de la máquina de estados
	for hijo in get_children():
		# Si el hijo hereda de nuestra clase base modelo_estados
		if hijo is modelo_estados:
			# Le inyectamos la referencia del enemigo padre
			hijo.enemigo_padre = enemigo_padre
	
	# Iniciamos con el estado de reposo (IDLE) por defecto
	cambiar_estado(idle)


# Función de físicas que se ejecuta en cada frame
func _physics_process(_delta: float) -> void:
	# Si hay un estado activo asignado
	if estado_actual != null:
		# Ejecutamos la lógica de actualización de ese estado activo
		estado_actual.in_proccess()

# Función para realizar el cambio seguro entre estados
func cambiar_estado(nuevo_estado: modelo_estados) -> void:
	# Si el nuevo estado es el mismo que ya está activo, no hacemos nada
	if nuevo_estado == estado_actual:
		# Salimos de la función
		return
	
	# Si tenemos un estado activo ejecutándose actualmente
	if estado_actual != null:
		# Llamamos a su lógica de salida del estado
		estado_actual.on_exit()
	
	# Reemplazamos el estado actual por el nuevo estado asignado
	estado_actual = nuevo_estado
	
	# Si el nuevo estado no es nulo
	if estado_actual != null:
		# Ejecutamos su lógica de entrada al estado
		estado_actual.on_enter()
