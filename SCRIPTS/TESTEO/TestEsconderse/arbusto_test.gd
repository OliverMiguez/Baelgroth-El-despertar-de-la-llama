extends Node2D
class_name Test_Arbusto

# Area2D del arbusto
@onready var deteccion_jugador = $DeteccionJugador
# Collision2D asignada al area del arbusto
@onready var colisison_deteccion_jugador = $DeteccionJugador/ColisisonDeteccionJugador

# Booleano para comprobar si el goblin principal fue detectado
var goblin_detectado = false


func _physics_process(_delta: float) -> void:
	if goblin_detectado == true:
		print("[Arbusto]: Jugador detectado")
	
# Deteccion de un "BODY" al entrar en el area
func _on_deteccion_jugador_body_entered(body):
	# Si se detecta el "class_name" de nuestro goblin_principal
	if body.name is goblin_principal:
		goblin_detectado = true # Para verificar la deteccion el el arbusto
		body.goblin_cerca_arbusto = true # Para verificar en el goblin principal
		body.enter_a_brush()

# Deteccion de un "BODY" al salir del area 
func _on_deteccion_jugador_body_exited(body):
	# Si se detecta el "class_name" de nuestro goblin_principal
	if body.name is goblin_principal:
		body.goblin_cerca_arbusto = false
		goblin_detectado = false
		body.exit_a_brush()
