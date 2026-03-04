extends StaticBody3D
class_name Interactable

signal activated(state: bool)

enum TriggerMode {
	ONCE,
	CONTINUOUS
}

const INTERACTION_TEXT : String = "Press [F]/(X)/(□) to interact"

@export var trigger_mode: TriggerMode = TriggerMode.ONCE
@export var toggle_mode: bool = true
@export var effect: ButtonEffect
@export var targets: Array[Affected]
@export var enable: bool = true
@export var repeat_rate: float = 0.2
@export var auto_reset_time: float = 0.0

var reset_timer := 0.0
var repeat_timer := 0.0

var is_pressed := false
var is_being_pressed := false
var is_hovered := false

var current_player: Player = null


func _process(delta: float):
	if auto_reset_time > 0.0 and not toggle_mode and is_pressed:
		reset_timer -= delta
		if reset_timer <= 0.0:
			reactivate()


func reactivate():
	is_pressed = false
	is_being_pressed = false
	_update_visual()


func handle_input(player: Player, pressed: bool, delta: float):
	if not enable:
		return

	current_player = player

	match trigger_mode:

		TriggerMode.ONCE:
			if pressed and not is_being_pressed:
				is_being_pressed = true
				_activate()
			elif not pressed:
				is_being_pressed = false

		TriggerMode.CONTINUOUS:
			is_being_pressed = pressed
			if pressed:
				repeat_timer -= delta
				if repeat_timer <= 0.0:
					_activate()
					repeat_timer = repeat_rate
			else:
				repeat_timer = 0.0

	_update_visual()


func _activate():

	if trigger_mode == TriggerMode.CONTINUOUS and toggle_mode:
		return

	if toggle_mode:
		is_pressed = !is_pressed
	else:
		is_pressed = true
		if auto_reset_time > 0.0:
			reset_timer = auto_reset_time

	# Affect scene objects
	for target in targets:
		target.affect(is_pressed)

	# Apply player effect
	if effect and current_player:
		effect.apply(current_player)

	emit_signal("activated", is_pressed)
	_update_visual()


func on_hover_enter():
	if not enable:
		return
	is_hovered = true
	_update_visual()


func on_hover_exit():
	is_hovered = false
	_update_visual()


func _update_visual():
	pass
