extends ButtonEffect
class_name IncreaseDamage

var cost = 15.0

@export var success_sound: AudioStream
@export var fail_sound: AudioStream

func apply(_player:Player):
	if Game.lamp_damage_upgrade > 0 and _player.stats.get_stat("run_grapes") >= cost:
		Game.lamp_damage_upgrade -= 1
		_player.stats.add_multiplier("lamp_idle_damage_amount", 0.5)
		_player.stats.add_multiplier("lamp_focus_damage_amount", 0.5)
		_player.stats.add_flat("run_grapes", -cost)
		_player.success_audio.play()
		
	else :
		_player.fail_audio.play()
