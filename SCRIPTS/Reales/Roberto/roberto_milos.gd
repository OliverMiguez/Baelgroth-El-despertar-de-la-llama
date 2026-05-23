extends CharacterBody2D
class_name roberto_milos

signal dialogo_con_roberto_terminado

@export var dialogo_actual:int 

var goblin_entro:bool = false
var dialogando:bool = false
var hablo:bool = false
var dialogo_terminado:bool = false

func _physics_process(_delta: float) -> void:
	manejar_dialogos()

func dialogos():
	match dialogo_actual:
		1: 
			Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/Conocer a Roberto.dtl")
			hablo = true
			await  Dialogic.timeline_ended
			hablo = false
			dialogo_terminado = true
			dialogo_con_roberto_terminado.emit()
func manejar_dialogos():
	if goblin_entro and Input.is_action_just_pressed("Hablar") and not dialogando:
		print("iniciando dialogo, dialogo_actual vale: ", dialogo_actual)
		dialogando = true
		dialogos()
		
# Maneja el area de deteccion de roberto
func _on_deteccion_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		print("goblin detectado")
		goblin_entro = true

func _on_deteccion_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_entro = false
