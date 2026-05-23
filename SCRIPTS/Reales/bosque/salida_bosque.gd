extends Node2D
class_name salida_bosque

# Nodo de animaciones
@onready var animaciones: AnimationPlayer = $AnimationPlayer

# Revisa si el jugador esta en el area
var transicionando:bool = false

func _ready() -> void:
	Musica.play()

# Envia una señal para cambiar de escena
func _on_cambio_entrenamiento_body_entered(body: Node2D) -> void:
	transicionando = true
	if body is goblin_principal:
		transicionando = true
		if transicionando == true:
			animaciones.play("Transicion2")
			await animaciones.animation_finished
			get_tree().change_scene_to_file("res://ESCENAS/Reales/Mapas/entrenamiento.tscn")
