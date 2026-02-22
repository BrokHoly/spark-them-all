extends CanvasLayer
class_name HUD

signal dev_quit

var is_stat = false

@onready var pause_menu = $OverlayLayer/PauseMenu
@onready var stat_menu = $OverlayLayer/StatMenu
@onready var help_text = $BaseHUD/HelpText

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.visible = get_tree().paused
	

func toggle_pause():
	var new_state = !get_tree().paused
	get_tree().paused = new_state
	pause_menu.visible = new_state
	Input.set_mouse_mode(
		Input.MOUSE_MODE_VISIBLE if new_state
		else Input.MOUSE_MODE_CAPTURED
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func _on_pause_menu_resume_pressed() -> void:
	toggle_pause()

func _on_pause_menu_quit_pressed() -> void:
	# Later, should redirect to the main menu etc....
	dev_quit.emit()
	
func show_help_text(text: String):
	help_text.text = text
	help_text.visible = true	

func hide_help_text():
	help_text.visible = false
