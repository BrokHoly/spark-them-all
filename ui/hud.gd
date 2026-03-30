extends CanvasLayer
class_name HUD

signal dev_quit

var is_stat = false

@onready var pause_menu = $OverlayLayer/PauseMenu
@onready var stat_menu = $OverlayLayer/StatMenu
@onready var help_text = $BaseHUD/HelpText
@onready var damage_flash: ColorRect = $BaseHUD/ColorRect
var damage_intensity := 0.0

@export var player: Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.visible = get_tree().paused
	
	pause_menu.resume_pressed.connect(_on_pause_menu_resume_pressed)
	pause_menu.settings_pressed.connect(_on_pause_menu_setting_pressed)
	pause_menu.quit_pressed.connect(_on_pause_menu_quit_pressed)
	
	if player and player.stats:
		player.stats.connect("stat_changed", Callable(self, "_on_stat_changed"))
		
		# Update HUD immediately
		_on_stat_changed("grapes_collected", player.stats.get_stat("grapes_collected"))
		_on_stat_changed("enemies_killed", player.stats.get_stat("enemies_killed"))
	
	
func _process(delta):
	if damage_intensity > 0.0:
		damage_intensity = max(damage_intensity - delta * 2.0, 0.0)
		damage_flash.material.set("intensity", damage_intensity)

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
	
func _on_pause_menu_setting_pressed() -> void:
	print("No settings for now hihi")
	pass

func _on_pause_menu_quit_pressed() -> void:
	# Later, should redirect to the main menu etc....
	dev_quit.emit()
	
func show_help_text(text: String):
	help_text.text = text
	help_text.visible = true	

func hide_help_text():
	help_text.visible = false
	
func update_grape_count(count: int):
	$BaseHUD/Metrics/TopLeft/GrapeScore/Text.text = str(count)
	
func update_enemy_count(count: int):
	$BaseHUD/Metrics/TopLeft/EnemyRemaining/Text.text = str(count)

func _on_stat_changed(stat_name: String, value: float):
	match stat_name:
		"grapes_collected":
			$BaseHUD/Metrics/TopLeft/GrapeScore/Text.text = str(int(value))
		"enemies_killed":
			$BaseHUD/Metrics/TopLeft/EnemyRemaining/Text.text = str(int(value))
			

func show_damage():
	damage_intensity = 0.6
	damage_flash.material.set("intensity", damage_intensity)

func show_death_screen():
	$OverlayLayer/DeathMenu.visible = true
	#get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
