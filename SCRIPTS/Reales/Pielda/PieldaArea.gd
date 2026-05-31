extends RigidBody2D
class_name pielda

signal piedra_detenida

@onready var deteccion_pielda: Area2D = $DeteccionPielda

@export var velocidad: float = 150.0
@export var dist_max: float = 160.0
@export var tiempo_desaparicion: float = 3.0
@export var tiempo_eliminar_piedra:float = 1.0

var direction: Vector2 = Vector2.ZERO
var distancia_viajada: float = 0.0
var deteccion_enemigo: bool = false

func _ready() -> void:
	freeze = true # Le quita las fisicas de gravedad

func _physics_process(delta: float) -> void:
	if velocidad == null: velocidad = 150.0 # Asigna velocidad siempre a la piedra
	if direction == Vector2.ZERO: return # Si no se esta moviendo, detiene la accion
	
	# Calcula los movimientos que realizará la piedra
	var distancia_a_moverse = velocidad * delta
	var movimiento_real = direction * distancia_a_moverse

	var colision = move_and_collide(movimiento_real) # Intenta mover el cuerpo físico en base al vector movimiento_real
	if colision: # Comprueba si el objeto colisionó con algo
		tratar_piedra() #Si es asi llama a la funcion y detiene la ejecucion
		return
	
	# Si no calcula la distancia a viajar
	distancia_viajada += distancia_a_moverse
	
	# Si la distancia es mayor o igual a la maxima que puede recoger activa la funcion
	if distancia_viajada >= dist_max:
		tratar_piedra()

# Detiene a la piedra, lanza una señal y espera un tiempo antes de eliminarla
func tratar_piedra():
	direction = Vector2.ZERO
	piedra_detenida.emit()
	# MODIFICADO: esperamos mas tiempo antes de eliminar el area
	# para dar tiempo al enemigo de llegar y reaccionar
	await get_tree().create_timer(tiempo_desaparicion).timeout 
	_eliminar_area()

# Elimina el area de deteccion de la piedra
func _eliminar_area():
	# Revisa si esta guardada en memoria el area
	if is_instance_valid(deteccion_pielda):
		# La elimina si esta guardada
		deteccion_pielda.queue_free()
	# Eliminamos la piedra entera despues de otro momento
	await get_tree().create_timer(tiempo_eliminar_piedra).timeout
	if is_instance_valid(self):
		queue_free()

# Si el que entra en el area es un enemigo, guardamos un valor que recoja esa info
func _on_deteccion_pielda_body_entered(body: Node2D) -> void:
	if body is Enemigo:
		deteccion_enemigo = true
		ManejadorDeDeteccion.deteccion_enemigo = deteccion_enemigo

# Si el enemigo sale , reestablecemos valores
func _on_deteccion_pielda_body_exited(body: Node2D) -> void:
	if body is Enemigo:
		deteccion_enemigo = false
		ManejadorDeDeteccion.deteccion_enemigo = deteccion_enemigo
