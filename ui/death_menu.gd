extends CanvasLayer

signal retry_pressed
signal quit_pressed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_retry_pressed() -> void:
	retry_pressed.emit()

func _on_quit_pressed() -> void:
	quit_pressed.emit()
