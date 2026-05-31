extends CharacterBody2D
class_name Enemigo

# Array que recoge todos los puntos en los que se podrá mover el enemigo
@export var puntos_patrulla: Array[NodePath] = []
# Distancia a la que se coloca el area por delante del enemigo
@export var distancia := 15.0  # ajusta segun el tamaño de tu enemigo

# Nodo que hace referencia al objeto que permite mover al enemigo entre los puntos de manera inteligentee
@onready var agente: NavigationAgent2D = $NavigationAgent2D
# Area de deteccion del enemigo(detectar al personaje principal)
@onready var area_deteccion: Area2D = $AreaDeteccion
# Referencia al manejador de la máquina de estados
@onready var fsm: Node = $FSM
# COlision del area de detecib
@onready var colision_enemigo: CollisionShape2D = $ColisionEnemigo

# Puntos por los que ya pasó
var puntos_resueltos: Array[Node2D] = []

# Objetivo actual hacia el que reacciona el enemigo
var goblin_detectado: Node2D = null

 # Permite que si el goblin fue detectado y no salió del area del enemigo, que a pesar de que se esconda sea perseguido igualmente
var goblin_fue_visto:bool = false

# Guarda los objetos que entraron en el area del enemigo
var goblin_en_area:goblin_principal = null
var piedras_en_area:Array = [] # Para poder recoger todas las piedras

# Referencia a la señal que envia la piedra
var señal_piedra

func _ready():
	# Recorre el array de los Marker2D
	for path in puntos_patrulla:
		puntos_resueltos.append(get_node(path)) # Añade el primer punto al array de putos por los que se han pasado
	fsm.inicializar(self) # Inicia la maquina de estados
	
	 # Conectamos tambien las señales de area para detectar Area2D como la piedra
	area_deteccion.area_entered.connect(_on_area_deteccion_area_entered)
	area_deteccion.area_exited.connect(_on_area_deteccion_area_exited)
	
func _physics_process(delta):
	# Asignamos el valor que nos envia el global de la señal de la piedra
	# Si es true -> enemigo viaja a la pos de la piedra SIEMPRE QUE EL GOBLIN NO ESTE O ESCONDIDO O CERCA DEL AREA DE DETECCION
	# SI es false -> no se hará caso a la piedra
	#señal_piedra = ManejadorDeDeteccion.deteccion_enemigo
	
	fsm.tick(delta)
	move_and_slide() # Permite el movimiento del enemigo

# Detecta cuando el goblin entra en el area del enemigo
func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_en_area = body # Marcamos que entro el goblin en el area 
		# Conectamos la señal para reaccionar cuando cambie escondido
		if not body.escondido_cambiado.is_connected(_evaluar_objetivo):
			body.escondido_cambiado.connect(_evaluar_objetivo)
	elif body is pielda:
		piedras_en_area.append(body)

	_evaluar_objetivo()

# Cuando el goblin sale del enemigo
func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_en_area = null
		goblin_fue_visto = false
		if body.escondido_cambiado.is_connected(_evaluar_objetivo):
			body.escondido_cambiado.disconnect(_evaluar_objetivo)
	elif body is pielda:
		piedras_en_area.erase(body)
		# MODIFICADO: misma proteccion
		if fsm.estado_activo != fsm.estado_investigar_piedra:
			_evaluar_objetivo()
			return

	_evaluar_objetivo()
	
# Permite ver a que objetivo perseguir o si hay ambos darle prioridad de persecucion al goblin principal
func _evaluar_objetivo():
	# Si estamos investigando una piedra solo interrumpimos si aparece el goblin visible
	if fsm.estado_activo == fsm.estado_investigar_piedra:
		if goblin_en_area != null and not goblin_en_area.escondido:
			goblin_fue_visto = true
			goblin_detectado = goblin_en_area
			fsm.cambiar_estado("alerta")
		return  # en cualquier otro caso no interrumpimos

	# Caso 1: el goblin esta en el area y no esta escondido
	if goblin_en_area != null and not goblin_en_area.escondido:
		goblin_fue_visto = true
		goblin_detectado = goblin_en_area
		fsm.cambiar_estado("alerta")
		return

	# Caso 2: el goblin esta en el area, esta escondido,
	# pero ya lo habiamos visto antes, lo seguimos persiguiendo
	if goblin_en_area != null and goblin_en_area.escondido and goblin_fue_visto:
		goblin_detectado = goblin_en_area
		fsm.cambiar_estado("alerta")
		return

	# Caso 3: no hay goblin visible ni recordado, pero hay piedras
	if piedras_en_area.size() > 0:
		goblin_detectado = piedras_en_area[0]
		fsm.cambiar_estado("investigar_piedra")
		return

	# Caso 4: el area esta vacia de objetivos relevantes
	goblin_detectado = null
	fsm.cambiar_estado("patrullar")

# Deteccion de la piedra cuando entra en el area del enemigo 
func _on_area_deteccion_area_entered(area: Area2D) -> void:
	# Subimos al nodo padre del area para comprobar si es una piedra
	# porque el area que entra es el hijo DeteccionPielda, no la piedra en si
	var padre = area.get_parent()
	if padre is pielda:
		piedras_en_area.append(padre)
		_evaluar_objetivo()

# Deteccion de la piedra cuando sale del area del enemigo
func _on_area_deteccion_area_exited(area: Area2D) -> void:
	var padre = area.get_parent()
	if padre is pielda:
		piedras_en_area.erase(padre)
		# No interrumpimos si ya estamos investigando esa piedra
		if fsm.estado_activo != fsm.estado_investigar_piedra:
			_evaluar_objetivo()

#  Mueve el area en base al movimiento del enemigo
func actualizar_area_deteccion(direccion: Vector2):
	if direccion == Vector2.ZERO:
		return  # si no se mueve no cambiamos nada
	
	area_deteccion.position = direccion.normalized() * distancia
	# Rota el area para que apunte en la direccion de movimiento
	area_deteccion.rotation = direccion.angle()
