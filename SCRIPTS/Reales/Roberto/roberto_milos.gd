extends CharacterBody2D
class_name roberto_milos

signal dialogo_con_roberto_terminado

@onready var deteccion: Area2D = $Deteccion
@export var dialogo_actual: int 

var goblin_entro: bool = false
var dialogando: bool = false
var hablo: bool = false
var dialogo_terminado: bool = false

func _ready() -> void:
	# ELIMINADO: Ya no conectamos la señal global aquí para evitar falsos positivos
	pass

func _physics_process(_delta: float) -> void:
	manejar_dialogos()

func dialogos():
	match dialogo_actual:
		1: 
			Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/Conocer a Roberto.dtl")
			preparar_dialogo()
			await Dialogic.timeline_ended
			finalizar_dialogo()
		2:
			Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/Entrenamiento1.dtl")
			preparar_dialogo()
			await Dialogic.timeline_ended
			finalizar_dialogo()
		3:
			Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/entrenamiento2.dtl")
			preparar_dialogo()
			await Dialogic.timeline_ended
			finalizar_dialogo()
		4:
			Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/Entrenamiento3.dtl")
			preparar_dialogo()
			await Dialogic.timeline_ended
			finalizar_dialogo()

# Función auxiliar para no repetir código al inicio de cada diálogo
func preparar_dialogo():
	ControlEscondite.dialogo_activo = true
	hablo = true

# Función auxiliar que se ejecuta SOLOS cuando el 'await' del diálogo actual termina
func finalizar_dialogo():
	hablo = false
	dialogo_terminado = true
	dialogando = false
	ControlEscondite.dialogo_activo = false
	
	# Emitimos tu señal por si la necesitas en otro lado
	dialogo_con_roberto_terminado.emit()
	
	# Ahora sí, borramos la detección de forma segura aquí adentro
	if is_instance_valid(deteccion):
		deteccion.queue_free()

func manejar_dialogos():
	if goblin_entro and Input.is_action_just_pressed("Hablar") and not dialogando:
		dialogando = true
		dialogos()

# Maneja el area de deteccion de roberto
func _on_deteccion_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_entro = true

func _on_deteccion_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_entro = false
