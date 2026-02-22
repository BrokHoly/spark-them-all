extends StaticBody3D
class_name Interactable

signal activated(state: bool)

enum TriggerMode {
	ONCE,          # only on click (default)
	CONTINUOUS     # while held
}

@export var trigger_mode: TriggerMode = TriggerMode.ONCE

@export var targets: Array[Affected]
@export var toggle_mode: bool = true
var INTERACTION_TEXT : String = "Press [F]/(X)/(□) to interact"
@export var enable: bool = true
@export var repeat_rate : float = 0.2

var repeat_timer : float = 0.0

var is_pressed := false
var is_being_pressed := false
var is_hovered := false

	
func handle_input(player, pressed: bool, delta: float):
	if not enable:
		return
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
	
	_trigger_targets()
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
	# Children override this
	pass  

func _trigger_targets():
	for target in targets:
		target.affect(is_pressed)
