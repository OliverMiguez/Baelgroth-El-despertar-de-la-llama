extends Node
class_name ControladorMovimientoRoberto

# Referencias que se configuran desde el inspector de cada escena
@export var roberto: CharacterBody2D
@export var animaciones: AnimatedSprite2D
@export var puntos_movimiento: Array[Marker2D] = []  # arrastra aqui los markers en orden
@export var duraciones: Array[float] = []            # duracion de cada tramo en segundos
@export var animaciones_por_tramo: Array[String] = [] # nombre de animacion para cada tramo
@export var eliminar_al_terminar: bool = false        # si true hace queue_free al acabar
@export var esperar_dialogo_entre_tramos: bool = false # si true espera señal de roberto

var _mov_actual: int = 0
var _moviendose: bool = false
var _tween: Tween

func _ready() -> void:
	pass

func iniciar(visible_al_empezar: bool = true):
	if _moviendose:
		return
	_moviendose = true
	_mov_actual = 0
	if roberto:
		roberto.visible = visible_al_empezar
	_siguiente_movimiento()

func _siguiente_movimiento():
	# Si ya recorrimos todos los puntos terminamos
	if _mov_actual >= puntos_movimiento.size():
		if eliminar_al_terminar and is_instance_valid(roberto):
			roberto.queue_free()
		return

	var destino = puntos_movimiento[_mov_actual].global_position
	var duracion = duraciones[_mov_actual] if _mov_actual < duraciones.size() else 3.0
	var anim = animaciones_por_tramo[_mov_actual] if _mov_actual < animaciones_por_tramo.size() else "Idle"

	_tween = create_tween()
	animaciones.play(anim)
	_tween.tween_property(roberto, "global_position", destino, duracion)
	_tween.tween_callback(func():
		animaciones.play("Idle")
		_mov_actual += 1

		# Si hay que esperar dialogo antes del siguiente tramo
		if esperar_dialogo_entre_tramos and roberto.has_signal("dialogo_con_roberto_terminado"):
			roberto.dialogo_con_roberto_terminado.connect(func():
				_siguiente_movimiento()
			, CONNECT_ONE_SHOT)
		else:
			_siguiente_movimiento()
	)
