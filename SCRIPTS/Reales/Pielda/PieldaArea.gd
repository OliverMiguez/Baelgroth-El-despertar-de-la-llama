extends RigidBody2D
class_name pielda

signal piedra_detenida

@export var velocidad: float = 150.0
@export var dist_max: float = 160.0

var direction: Vector2 = Vector2.ZERO
var distancia_viajada: float = 0.0
var deteccion_enemigo: bool = false

func _ready() -> void:
	freeze = true

func _physics_process(delta: float) -> void:
	if velocidad == null: velocidad = 150.0
	if direction == Vector2.ZERO: return

	var distancia_a_moverse = velocidad * delta
	var movimiento_real = direction * distancia_a_moverse

	var colision = move_and_collide(movimiento_real)
	if colision:
		tratar_piedra()
		return

	distancia_viajada += distancia_a_moverse

	if distancia_viajada >= dist_max:
		tratar_piedra()

func tratar_piedra():
	direction = Vector2.ZERO
	piedra_detenida.emit()
	# Esperamos un momento y eliminamos el area de deteccion
	await get_tree().create_timer(3.0).timeout
	_eliminar_area()

func _eliminar_area():
	var area = $DeteccionPielda
	if is_instance_valid(area):
		area.queue_free()
	# Eliminamos la piedra entera despues de otro momento
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(self):
		queue_free()

func _on_deteccion_pielda_body_entered(body: Node2D) -> void:
	if body is Enemigo:
		deteccion_enemigo = true
		ManejadorDeDeteccion.deteccion_enemigo = deteccion_enemigo

func _on_deteccion_pielda_body_exited(body: Node2D) -> void:
	if body is Enemigo:
		deteccion_enemigo = false
		ManejadorDeDeteccion.deteccion_enemigo = deteccion_enemigo
