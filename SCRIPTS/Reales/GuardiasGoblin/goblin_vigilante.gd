extends CharacterBody2D
class_name  Goblin_Vigilante
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var goblin_p: goblin_principal

@export var flip_vigilante:bool = false
@export var numero_goblin:int

func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_dialogo_terminado)

func _physics_process(_delta: float) -> void:
	if flip_vigilante == false:
		animated_sprite_2d.flip_h = false
	else:
		animated_sprite_2d.flip_h = true
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	if  body is goblin_principal and Input.is_action_pressed("Hablar"):
		goblin_p.walking_speed = 0
		Dialogic.start("res://DIALOGIC/DIALOGOS/ConversacionTest.dtl")


func _on_dialogo_terminado():
	goblin_p.walking_speed = 100
