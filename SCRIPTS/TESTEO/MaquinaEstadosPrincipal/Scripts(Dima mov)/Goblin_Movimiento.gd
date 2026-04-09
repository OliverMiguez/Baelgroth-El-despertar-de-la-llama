extends CharacterBody2D

# Usamos export para ajustar la velocidad desde el editor si es necesario
@export var rapidez_metros : float = 5.0
var pixeles_por_metro : float = 12

# Calculamos la rapidez final
@onready var rapidez_real : float = rapidez_metros * pixeles_por_metro
@onready var anim_goblin: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta):
	movimiento()
	asignar_animacion()
	
func asignar_animacion():
	# Referencia al nodo Sprite (ajusta el nombre si es necesario)
	# 1. Determinar la animación según el movimiento
	if velocity.length() > 0:
		# Si se está moviendo, podrías reproducir una animación de "caminar"
		anim_goblin.play("correr")
	else:
		# Si está quieto
		anim_goblin.play("Idle")
	# 2. Voltear el sprite (Mirroring) según la dirección en X
	if velocity.x > 0:
		anim_goblin.flip_h = false # Mirando a la derecha
	elif velocity.x < 0:
		anim_goblin.flip_h = true  # Mirando a la izquierda (espejo)
func movimiento():
	# 1. Obtener la dirección de entrada
	var direccion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	# 2. Asignar la velocidad directamente a la propiedad del nodo
	# get_vector ya devuelve un vector normalizado automáticamente
	velocity = direccion * rapidez_real
	move_and_slide()
