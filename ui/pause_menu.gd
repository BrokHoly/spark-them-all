extends Control

signal resume_pressed
signal settings_pressed
signal quit_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func _on_resume_button_pressed() -> void:
	resume_pressed.emit()

func _on_settings_button_pressed() -> void:
	settings_pressed.emit()
	pass # Replace with function body.

func _on_quit_button_pressed() -> void:
	quit_pressed.emit()
