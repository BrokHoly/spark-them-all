extends CanvasLayer

signal loading_screen_read

@export var animation_player: AnimationPlayer


func _ready() -> void:
	await animation_player.animation_finished
	loading_screen_read.emit()

func _on_load_finished() -> void:
	animation_player.play_backwards("transition")
	await animation_player.animation_finished
	queue_free()

func _on_progress_changed(value: float) -> void:
	print(value)
