extends Node2D
@onready var animacion: AnimationPlayer = $AnimationPlayer

# Controla si el goblin está físicamente dentro del área del cartel
var goblin_dentro: bool = false
# Evita que el diálogo se ejecute en bucle infinito
var dialogando: bool = false

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	manejar_cartel()

func manejar_cartel():
	# Si el jugador está dentro, presiona "Hablar" y no hay otro diálogo abierto...
	if goblin_dentro and Input.is_action_just_pressed("Hablar") and not dialogando:
		dialogando = true
		ControlEscondite.dialogo_activo = true # Bloquea el movimiento si lo usas así
		
		Dialogic.start("res://DIALOGIC/DIALOGOS/Reales/Cartel.dtl")
		
		# Esperamos a que el texto termine para permitir volver a leerlo
		await Dialogic.timeline_ended
		dialogando = false
		ControlEscondite.dialogo_activo = false

# Se ejecuta cuando el jugador se para frente al cartel
func _on_cartel_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = true

# Se ejecuta cuando el jugador se aleja del cartel
func _on_cartel_body_exited(body: Node2D) -> void:
	if body is goblin_principal:
		goblin_dentro = false

func _on_playa_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		animacion.play("Transicion2")
		await  animacion.animation_finished
		get_tree().change_scene_to_file("res://ESCENAS/Reales/Mapas/playa.tscn")


func _on_castillo_body_entered(body: Node2D) -> void:
	if body is goblin_principal:
		animacion.play("Transicion2")
		await  animacion.animation_finished
		get_tree().change_scene_to_file("res://ESCENAS/Reales/Mapas/castillo_fuera.tscn")
