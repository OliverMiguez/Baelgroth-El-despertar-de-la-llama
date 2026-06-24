# Hereda de la clase base Node de Godot
extends Node
# Registra esta clase globalmente para heredar de ella en otros estados
class_name modelo_estados

# Referencia al enemigo principal que será controlado por el estado
var enemigo_padre: CharacterBody2D

# Método que se llama al entrar en el estado (inicialización)
func on_enter() -> void:
	# Por defecto no realiza ninguna acción
	pass
	
# Método que se llama en el bucle principal de actualización física
func in_proccess() -> void:
	# Por defecto no realiza ninguna acción
	pass
	
# Método que se llama al salir del estado (limpieza o transición)
func on_exit() -> void:
	# Por defecto no realiza ninguna acción
	pass
