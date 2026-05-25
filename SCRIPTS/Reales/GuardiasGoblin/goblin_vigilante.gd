extends CharacterBody2D
class_name  Goblin_Vigilante
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var goblin_p: goblin_principal
var goblin_detectado: bool = false
var dialogando:bool = false

@export var flip_vigilante:bool = false
@export var numero_goblin:int
@export_range(0.0,3.0) var retraso_animacion: float = 0.0

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogo_terminado)
	if retraso_animacion > 0.0:
		animated_sprite_2d.pause()  # la dejamos parada hasta que pase el tiempo
		await get_tree().create_timer(retraso_animacion).timeout
	
	animated_sprite_2d.play("Idle") # arrancamos la animacion tras el retraso


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
		ControlEscondite.dialogo_activo = true
		match numero_goblin:
			1:
				Dialogic.start("res://DIALOGIC/DIALOGOS/Prueba 1.dtl")
			2:  Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/Cueva_Guardia1timeline.dtl")
			3:  Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/Cueva_guardia3.dtl")
			4:  Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/cueva_guardia4.dtl")
			_:
				print("No habla")

func _on_dialogo_terminado():
	dialogando = false
	ControlEscondite.dialogo_activo = false  # AÑADIDO

# Controlador de dialogos de los enemigos
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_detectado = true
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_detectado = false
