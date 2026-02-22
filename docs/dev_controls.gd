extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("dev_quit"):
		hard_quit()


func _on_hud_dev_quit() -> void:
	hard_quit()

func hard_quit():
	get_tree().quit()
	
