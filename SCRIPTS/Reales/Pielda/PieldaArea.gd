extends Area2D

@export var velocidad: float = 150.0 
@export var dist_max: float = 100.0

var direction: Vector2 = Vector2.ZERO # Aseguramos tipo Vector2
var distancia_viajada: float = 0.0

func _physics_process(delta: float) -> void:
	# Doble comprobación: si por algún motivo externo velocidad es nula, le damos valor
	if velocidad == null: velocidad = 150.0
	
	if direction == Vector2.ZERO: return

	# Si el error persiste en la línea de abajo, es que 'velocidad' sigue siendo nula desde el inspector
	var distancia_a_moverse = velocidad * delta
	var movimiento_real = direction * distancia_a_moverse
	
	position += movimiento_real
	distancia_viajada += distancia_a_moverse
	
	if distancia_viajada >= dist_max:
		tratar_piedra()

func tratar_piedra():
	queue_free()
