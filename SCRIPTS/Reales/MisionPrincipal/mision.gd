extends CharacterBody2D
class_name MisionPrincipal

var goblin_detectado:bool = false
var dialogando:bool = false

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogo_terminado)
	
func _physics_process(delta: float) -> void:
	iniciar_dialogo()

# Inicia dialogos
func iniciar_dialogo():
	if Input.is_action_just_pressed("Hablar") and goblin_detectado and not dialogando:
		dialogando = true
		Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/MisionPrincipal.dtl")

func _on_dialogo_terminado():
	dialogando = false

func _on_deteccion_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_detectado = true

func _on_deteccion_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_detectado = false
