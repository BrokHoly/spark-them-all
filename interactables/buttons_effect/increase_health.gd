extends ButtonEffect
class_name IncreaseHealth

var cost = 10.0
@export var success_sound: AudioStream
@export var fail_sound: AudioStream
func apply(_player:Player):
	if Game.max_health_upgrade > 0 and _player.stats.get_stat("run_grapes") >= cost:
		Game.max_health_upgrade -= 1
		_player.stats.add_flat("max_health", 3.0)
		_player.stats.add_flat("run_grapes", -cost)
		_player.success_audio.play()
		
	else :
		_player.fail_audio.play()
