extends CanvasLayer
@onready var label: Label = $"Control/VBoxContainer/Piedras Totales"


func _physics_process(_sdelta: float) -> void:
	label.text = str(ControlPiedras.piedras_jugador)
