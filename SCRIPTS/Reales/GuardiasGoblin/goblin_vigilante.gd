extends CharacterBody2D
class_name  Goblin_Vigilante
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var goblin_p: goblin_principal
var goblin_detectado: bool = false
var dialogando:bool = false

@export var flip_vigilante:bool = false
@export var numero_goblin:int

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogo_terminado)

func _physics_process(_delta: float) -> void:
	iniciar_dialogo()
	if flip_vigilante == false:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true

# Inicia dialogos
func iniciar_dialogo():
	if Input.is_action_just_pressed("Hablar") and goblin_detectado and not dialogando:
		dialogando = true
		match numero_goblin:
			1:
				Dialogic.start("res://DIALOGIC/DIALOGOS/Prueba 1.dtl")
			_:
				print("No habla")

func _on_dialogo_terminado():
	dialogando = false

# Controlador de dialogos de los enemigos
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_detectado = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_detectado = false
