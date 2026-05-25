extends Node2D
class_name Test_Arbusto

@onready var deteccion_jugador: Area2D = $DeteccionJugador
@onready var colision_deteccion_juegador: CollisionShape2D = $DeteccionJugador/ColisionDeteccionJuegador
@onready var arbusto_v_21: Sprite2D = $ArbustoV21 

# Cuando se detecta un cuerpo en el area  del arbusto
func _on_deteccion_jugador_body_entered(body: Node2D) -> void:
	print("entro en arbusto: ", body.name)
	if body is goblin_principal:
		ControlEscondite.goblin_en_arbusto = true  # DIRECTO al autoload	
			#print("goblin detectado en arbusto")


# Cuando sale un cuerpo en el area  del arbusto
func _on_deteccion_jugador_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		ControlEscondite.goblin_en_arbusto = false  # DIRECTO al autoload
