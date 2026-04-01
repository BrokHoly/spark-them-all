extends ButtonEffect
class_name IncreaseCollectRange

var cost = 5.0

func apply(_player:Player):
	if Game.collect_range_upgrade > 0 and _player.stats.get_stat("run_grapes") >= cost:
		Game.collect_range_upgrade -= 1
		_player.stats.add_multiplier("collectible_range", 0.2)
		_player.stats.add_flat("run_grapes", -cost)
		_player.success_audio.play()
		
	else :
		_player.fail_audio.play()
