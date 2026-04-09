extends "res://SCRIPTS/Reales/GoblinPrincipal/Estados/State.gd"

# Cambio de estados
@export var walk_state:State

# Ejecuta este código cuando cambia a este estado
func on_enter():
	print("[Test]: Iniciando estado idle ")
	# Iniciar a continuación la animación del personaje

# Permite el cambio entre estados
func state_process(_delta:float) -> void:
	if !father:
		return
	
	# Permite el cambio al estado de andar (walk)
	if father.velocity != Vector2.ZERO:
		next_state = walk_state
		
