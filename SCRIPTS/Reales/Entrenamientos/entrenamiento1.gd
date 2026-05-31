extends Node2D

@onready var roberto_miloss: CharacterBody2D = $RobertoMilos
@onready var pos_1_roberto: Marker2D = $Pos1_roberto
@onready var animaciones_roberto: AnimatedSprite2D = $RobertoMilos/AnimatedSprite2D
@onready var pos_2_roberto: Marker2D = $Pos2_roberto
@onready var animaciones: AnimationPlayer = $AnimationPlayer
@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2


var roberto_mov_actual:int = 0
var tween
var roberto_moviendose:bool = false
var primer_mov_completado:bool = false
var segundo_mov_completado:bool = false
var transicionando:bool = false

func _ready() -> void:
	animation_player_2.play("dialogo")
	tween = create_tween()
	roberto_miloss.visible = true
	Dialogic.VAR.roberto_entra = true
	
func _physics_process(_delta: float) -> void:
	manejador_roberto()
	
func manejador_roberto():
	#print("comprobando roberto_entra: ", Dialogic.VAR.roberto_entra, " moviendose: ", roberto_moviendose)
	if Dialogic.VAR.roberto_entra == true and not roberto_moviendose:
		#print("1 - roberto_entra es true, iniciando movimiento")
		roberto_miloss.visible = true
		roberto_moviendose = true
		# Primer mov que realiza
		roberto_mov_actual = 1
		#print("2 - destino primer mov: ", pos_1_roberto.global_position)
		movimientos_roberto(pos_1_roberto.global_position,8.0)

# Mueve a roberto por el mapa
func movimientos_roberto(destino:Vector2, duracion:float):
	#print("3 - movimientos_roberto llamado, caso: ", roberto_mov_actual, " destino: ", destino)
	match  roberto_mov_actual:
		1:
			#print("4 - creando tween caso 1")
			tween = create_tween()
			tween.tween_property(roberto_miloss, "global_position", destino, 5.0)
			animaciones_roberto.play("Lado")
			tween.tween_callback(func(): # Cuando el tween acaba activa esta animacion
				#print("5 - primer tween terminado")
				primer_mov_completado = true
				roberto_mov_actual = 2
				
				roberto_miloss.dialogo_con_roberto_terminado.connect(func():
					movimientos_roberto(pos_2_roberto.global_position, 4.0)
				, CONNECT_ONE_SHOT)  # CONNECT_ONE_SHOT hace que se desconecte automaticamente tras ejecutarse
			)

		2:
			#print("4 - creando tween caso 2")
			tween = create_tween()
			tween.tween_property(roberto_miloss, "global_position", pos_2_roberto.global_position, 8.0)
			animaciones_roberto.play("Lado")
			tween.tween_callback(func(): # Cuando el tween acaba activa esta animacion
				#print("5 - segundo tween terminado")
				segundo_mov_completado = true
				roberto_miloss.queue_free()
			)

# Transiciones Area
func _on_cambio_body_entered(body: Node2D) -> void:
	transicionando = true
	if body is goblin_principal:
		transicionando = true
		if transicionando == true:
			animaciones.play("Transicion2")
			await animaciones.animation_finished
			get_tree().change_scene_to_file("res://ESCENAS/Reales/Mapas/entrenamiento_2.tscn")
