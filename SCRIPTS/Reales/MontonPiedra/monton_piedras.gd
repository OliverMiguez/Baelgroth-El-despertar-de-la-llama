extends Node2D
class_name MontonPiedras

@onready var deteccion_del_monton: Area2D = $DeteccionDelMonton

var goblin_detectado:bool = false

# Deteccion del jugador
func _on_deteccion_del_monton_body_entered(body: Node2D) -> void:
	if body is goblin_principal :
		goblin_detectado = true
		ControlPiedras.recoger_piedras = goblin_detectado # Verifica si estamos sobre un monton de piedras

func _on_deteccion_del_monton_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_detectado = false
		ControlPiedras.recoger_piedras = goblin_detectado
