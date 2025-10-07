extends Control
@onready var close_button:Button = $Panel/Button

func _ready() -> void:
	close_button.pressed.connect(queue_free)
