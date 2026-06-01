extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func reproducir(nombre: String) -> void:
	print("reproducir llamado: ", nombre)
	print("animaciones disponibles: ", animation_player.get_animation_list())
	animation_player.play(nombre)
	print("animacion iniciada, duracion: ", animation_player.current_animation_length)
	await animation_player.animation_finished
	print("animacion terminada")
