# Hereda de CharacterBody2D para usar físicas en 2D
extends CharacterBody2D
# Define el nombre de la clase para ser usada en otros scripts
class_name EnemigoAtacante

# Obtiene la referencia al nodo de animaciones de la escena
@onready var animaciones: AnimatedSprite2D = $Animaciones
# Obtiene la referencia al nodo de colisión de la escena
@onready var colisionEnemigo: CollisionShape2D = $ColisionEnemigo

# Velocidad de movimiento cuando patrulla (ajustable desde el editor)
@export var speed: float = 100.0
# Velocidad de movimiento al atacar (ajustable desde el editor)
@export var attack_speed: float = 150.0
# Puntos de patrulla configurables desde el inspector mediante Marker2D
@export var puntos_patrulla: Array[Marker2D] = []

# Función que se ejecuta cuando el nodo entra al árbol de la escena
func _ready() -> void:
	# No realizamos ninguna acción inicial aquí por el momento
	pass

# Función para reproducir la animación de movimiento según la dirección del movimiento
func reproducir_animacion_movimiento(direccion: Vector2) -> void:
	# Si la dirección es principalmente vertical (Y es mayor que X en valor absoluto)
	if abs(direccion.y) > abs(direccion.x):
		# Si se mueve hacia abajo (Y positivo)
		if direccion.y > 0:
			# Reproduce la animación de caminar hacia abajo
			animaciones.play("Mov.Abajo")
		# Si se mueve hacia arriba (Y negativo)
		else:
			# Reproduce la animación de caminar hacia arriba
			animaciones.play("Mov.Arriba")
	# Si la dirección es principalmente horizontal
	else:
		# Reproduce la animación de caminar lateralmente
		animaciones.play("Mov.Lateral")
		# Voltea el sprite a la izquierda si el movimiento en X es negativo
		animaciones.flip_h = (direccion.x < 0)

# Función para reproducir la animación de embestida según la dirección del ataque
func reproducir_animacion_embestida(direccion: Vector2) -> void:
	# Si la dirección de ataque es principalmente vertical
	if abs(direccion.y) > abs(direccion.x):
		# Si ataca hacia abajo (Y positivo)
		if direccion.y > 0:
			# Reproduce la animación de embestir hacia abajo
			animaciones.play("Embestida.Abajo")
		# Si ataca hacia arriba (Y negativo)
		else:
			# Reproduce la animación de embestir hacia arriba
			animaciones.play("Embestida.Arriba")
	# Si la dirección de ataque es principalmente horizontal
	else:
		# Reproduce la animación de embestir lateralmente
		animaciones.play("Embestida.Lateral")
		# Voltea el sprite a la izquierda si el ataque en X es negativo
		animaciones.flip_h = (direccion.x < 0)
