extends Node
class_name  FSM

@export var father : Node #el tipo del padre
@export var animation_player:AnimatedSprite2D
@export var current_state:State

var array_states: Array[State]

func _ready(): 
	for child in self.get_children():
		if child is State:
			child.father= father
			child.animation_player = animation_player
			array_states.append(child)
	
	# Posible solucion al error de que no activa el print del estado idle
	if current_state:
		current_state.on_enter()

func _physics_process(_delta):
	current_state.state_process(_delta) # Comprueba lo que el estado actual esta ejecutando
	if current_state.next_state!= null:				#Si hay un estado nuevo 
		change_state(current_state.next_state)		#ejecuto la función para cambiar al siguiente estado

func change_state(new_state:State):
	current_state.on_exit()				#ejecuto función de salida
	current_state.next_state=null		#reseteo next_state
	current_state = new_state			#asigno al estado actual el nuevo estado
	#father.get_node("Label").text=new_state.name
	current_state.on_enter()			#ejecuto función de entrada 
