extends Node2D
class_name Test_Arbusto

@onready var deteccion_jugador: Area2D = $DeteccionJugador
@onready var colision_deteccion_juegador: CollisionShape2D = $DeteccionJugador/ColisionDeteccionJuegador
@onready var arbusto_v_21: Sprite2D = $ArbustoV21 

var goblin_detected = false # Comprueba si el goblin entro en el area

func _physics_process(_delta: float) -> void:
	goblin_detection()

# Cuando se detecta un cuerpo en el area  del arbusto
func _on_deteccion_jugador_body_entered(body: Node2D) -> void:
	if body.has_method("goblin"):
		goblin_detected = true

# Cuando sale un cuerpo en el area  del arbusto
func _on_deteccion_jugador_body_exited(body: Node2D) -> void:
	if body.has_method("goblin"):
		goblin_detected = false

# Se ejecuta tras comprobar los cuerpos que entraron en el area del arbusto
func goblin_detection():
	if goblin_detected == true:
		ControlEscondite.goblin_en_arbusto = true
	else:
		ControlEscondite.goblin_en_arbusto = false




#func _physics_process(_delta: float) -> void:
	#if goblin_detectado == true:
		#print("[Arbusto]: Jugador detectado")
	#
## Deteccion de un "BODY" al entrar en el area
#func _on_deteccion_jugador_body_entered(body):
	## Si se detecta el "class_name" de nuestro goblin_principal
	#if body.name is goblin_principal:
		#goblin_detectado = true # Para verificar la deteccion el el arbusto
		#body.goblin_cerca_arbusto = true # Para verificar en el goblin principal
		#body.enter_a_brush()
#
## Deteccion de un "BODY" al salir del area 
#func _on_deteccion_jugador_body_exited(body):
	## Si se detecta el "class_name" de nuestro goblin_principal
	#if body.name is goblin_principal:
		#body.goblin_cerca_arbusto = false
		#goblin_detectado = false
		#body.exit_a_brush()
