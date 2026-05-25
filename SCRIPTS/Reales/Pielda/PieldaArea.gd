extends RigidBody2D
class_name pielda

signal piedra_detenida  # avisamos cuando la piedra termino su recorrido

@export var velocidad: float = 150.0 
@export var dist_max: float = 160.0
@onready var colision_area_pielda: CollisionShape2D = $DeteccionPielda/ColisionAreaPielda

var direction: Vector2 = Vector2.ZERO # Aseguramos tipo Vector2
var distancia_viajada: float = 0.0

# Test con el enemmigo
var deteccion_enemigo:bool = false

# Permite quitar la colision a la piedra
var quitar_colision:bool = false
# Para evitar mov raros
func _ready() -> void:
	freeze = true

func _physics_process(delta: float) -> void:
	# Si pasaron 3 segundos(lo que dura el timer) y el enemigo no detecto la piedra, o ya salio de su area , quita la colision a la piedra
	if quitar_colision == true:
		if deteccion_enemigo == false:
			manage_colision()
			quitar_colision = false
	
	# Doble comprobación: si por algún motivo externo velocidad es nula, le damos valor
	if velocidad == null: velocidad = 150.0
	
	if direction == Vector2.ZERO: return


	var distancia_a_moverse = velocidad * delta
	var movimiento_real = direction * distancia_a_moverse
	
	# 1. Intentamos mover y ver si choca contra una pared
	var colision = move_and_collide(movimiento_real)
	if colision:
		tratar_piedra()
		return
	
	# 2. ¡DESCOMENTADO! Si no choca, sumamos la distancia manualmente
	distancia_viajada += distancia_a_moverse
	
	# 3. ¡DESCOMENTADO! Si ya superó la distancia máxima, la detenemos
	if distancia_viajada >= dist_max:
		tratar_piedra()
#
	## Si el error persiste en la línea de abajo, es que 'velocidad' sigue siendo nula desde el inspector
	#var distancia_a_moverse = velocidad * delta
	#var movimiento_real = direction * distancia_a_moverse
	#
	#var colision = move_and_collide(movimiento_real)
	#if colision:
		#tratar_piedra()
		#return
	#
	##position += movimiento_real
	##distancia_viajada += distancia_a_moverse
	##
	##if distancia_viajada >= dist_max:
		##tratar_piedra()


func tratar_piedra():
	direction = Vector2.ZERO
	piedra_detenida.emit()  # Avisamos al enemigo/mundo
	

	
	# Opción B (Si necesitas que la piedra se quede tirada en el suelo visible):
	# freeze = true
	# set_physics_process(false) # Apaga este script para que deje de calcular movimiento
#func tratar_piedra():
	#direction = Vector2.ZERO
	#piedra_detenida.emit()  # avisamos al mundo que ya paramos

# Permite apagar la colision de la piedra para que no se detecte más
func _on_eliminar_area_timeout() -> void:
	quitar_colision = true

# Elimina el area si esta piedra no se detecto al cabo de un tiempo
func manage_colision():
	colision_area_pielda.queue_free()


func _on_deteccion_pielda_body_entered(body: Node2D) -> void:
	if body is Enemigo:
		deteccion_enemigo = true # Detecta al enemigo y envia una señal al global para indicarle al enemigo
		ManejadorDeDeteccion.deteccion_enemigo = deteccion_enemigo


func _on_deteccion_pielda_body_exited(body: Node2D) -> void:
	if body is Enemigo:
		deteccion_enemigo = false # Deja de detectar al enemigo
		ManejadorDeDeteccion.deteccion_enemigo = deteccion_enemigo # Envia señal al global para indicarle al enemigo
