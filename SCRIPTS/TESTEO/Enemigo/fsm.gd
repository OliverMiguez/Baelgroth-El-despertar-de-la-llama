extends Node

# Referencia al nodo padre 
var enemigo: Enemigo 

# Cada uno de los nodos de los estados del enemigo
@onready var estado_patrulla:   Node = $EstadoPatrulla
@onready var estado_alerta:     Node = $EstadoAlerta
@onready var estado_investigar: Node = $EstadoInvestigar
@onready var estado_investigar_piedra: Node = $EstadoInvestigarPiedra

# El estado que esta activo en el momento
var estado_activo: Node = null

func inicializar(nodo_enemigo: Enemigo):
	enemigo = nodo_enemigo # Asigna al enemigo a la variable
	
	# Le pasa a todos los estados una referencia del enemigo 
	estado_patrulla.configurar(enemigo)
	estado_alerta.configurar(enemigo)
	estado_investigar.configurar(enemigo)
	estado_investigar_piedra.configurar(enemigo)
	# El primer estado que detecta
	cambiar_estado("patrulla")

# En cada frame del estado
func tick(delta: float):
	if estado_activo:
		estado_activo.tick(delta) # Mantiene el estado

# Permite cambiar de estados
func cambiar_estado(nombre: String):
	# Permite salir del estado
	if estado_activo and estado_activo.has_method("al_salir"):
		estado_activo.al_salir()
		# Registra todos los estados a los que se puede acceder
	match nombre:
		"patrulla":   estado_activo = estado_patrulla
		"alerta":     estado_activo = estado_alerta
		"investigar": estado_activo = estado_investigar
		"investigar_piedra": estado_activo = estado_investigar_piedra
		# Lo que ejecutan los estados al entrar en ellos al inicio
	if estado_activo.has_method("al_entrar"):
		estado_activo.al_entrar()
