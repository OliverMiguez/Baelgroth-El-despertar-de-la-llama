extends RigidBody2D
class_name pielda

signal piedra_detenida

@onready var deteccion_pielda:Area2D = $DeteccionPielda
@onready var sprite_pielda: Sprite2D = $PieldaSprite
@onready var sprite_sombra: Sprite2D = $PieldaSombra

@export var velocidad: float = 150.0
@export var dist_max: float = 160.0
@export var tiempo_desaparicion: float = 3.0
@export var tiempo_eliminar_piedra:float = 1.0

var direction: Vector2 = Vector2.ZERO
var distancia_viajada: float = 0.0
var deteccion_enemigo: bool = false

## Variables calculo parábola
@export var tiempo_duracion:float = 2.0  # Duracion total de la caida de la piedra
@export var altura_pixel:float = 40.0    # Altura maxima que alcanzará la 

var pos_final_X:float = 0.0
var pos_ini_x:float   = 0.0
var pos_final_y:float = 0.0
var pos_ini_y:float   = 0.0

var tiempo_transcurrido:float = 0.0 # Tiempo que transcurre antes de llegar al objetivo
var gravedad:float = 0.0
var impulso:float = 0.0   # Velocidad Inicial Y
var punto_final:Vector2

func _ready() -> void:
	freeze = true 		# Le quita las fisicas de gravedad
	calcular_gravedad() # Obtiene la gravedad perfecta para X movimiento
	calcular_impulso()  # Obtiene el impulso perfecto para X altura
	
func _physics_process(delta: float) -> void:
	
	# Asigna velocidad siempre a la piedra
	if velocidad == null: velocidad = 150.0 
	# Si no se esta moviendo, detiene la accion
	if direction == Vector2.ZERO: return    
	
	# Obtiene el tiempo que tarda el completar el movimiento la piedra
	tiempo_transcurrido += delta
	
	# MOVIMIENTOS TIERRA PIEDRA
	var distancia_a_moverse = velocidad * delta
	var movimiento_real = direction * distancia_a_moverse

	var colision = move_and_collide(movimiento_real) # Intenta mover el cuerpo físico en base al vector movimiento_reall
	if colision: 									 # Comprueba si el objeto colisionó con algo
		tratar_piedra() 							 # Si es asi llama a la funcion y detiene la ejecucion
		return
	
	# MOVIMIENTO PARÁBOLA (Solo afecta visualmente a la piedra, NO a la sombra)
	obtener_parabola_y()
	sprite_pielda.position.y = pos_final_y 
	
	# MANTENER SOMBRA EN EL SUELO 
	# Al no modificar su position.y, se mantendrá en 0 (el centro del RigidBody que se mueve por el suelo)
	sprite_sombra.position.y = 0 
	
	# Si no calcula la distancia a viajar
	distancia_viajada += distancia_a_moverse
	
	# Si la distancia es mayor a la máxima O el tiempo de vuelo terminó, aterriza
	if distancia_viajada >= dist_max or tiempo_transcurrido >= tiempo_duracion:
		tratar_piedra()

# Calcula la gravedad perfecta para la parabola para T tiempo
func calcular_gravedad():
	gravedad = (8 * altura_pixel) / pow(tiempo_duracion,2)

func calcular_impulso():
	impulso = (4 * altura_pixel) / tiempo_duracion
	impulso = -impulso # Lo hacemos negativo para que suba

# Calcula las posiciones a las que se moverá la piedra en la parábola en x
func obtener_parabola_x():
	pos_final_X = pos_ini_x + velocidad * tiempo_transcurrido
	
# Calcula las posiciones a las que se moverá la piedra en la parábola en x
func obtener_parabola_y():
	pos_final_y = pos_ini_y + (impulso * tiempo_transcurrido) + (0.5 * gravedad * tiempo_transcurrido**2)
	
func obtener_punto_final():
	punto_final.x = pos_final_X
	punto_final.y = pos_final_y

# Detiene a la piedra, lanza una señal y espera un tiempo antes de eliminarla
func tratar_piedra():
	direction = Vector2.ZERO
	# Bajamos el sprite al suelo (0) para que no se quede flotando si choca con una pared
	sprite_pielda.position.y = 0 
	#Activamos el Area2D solo al aterrizar/chocar
	deteccion_pielda.monitoring = true 
	
	piedra_detenida.emit()
	# Esperamos mas tiempo antes de eliminar el area
	await get_tree().create_timer(tiempo_desaparicion).timeout 
	eliminar_area()

# Elimina el area de deteccion de la piedra
func eliminar_area():
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
