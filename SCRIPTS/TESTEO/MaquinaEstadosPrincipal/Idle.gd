extends "res://SCRIPTS/TESTEO/MaquinaEstadosPrincipal/State.gd"

# Ejecuta este código cuando cambia a este estado
func on_enter():
	print("[Test]: Iniciando estado idle ")
	# Iniciar a continuación la animación del personaje

# Permite el cambio entre estados
func state_process(_delta:float) -> void:
	pass
