extends ButtonEffect
class_name IncreaseRange

const MAX_INCREASE = 5
const STAT_NAME = "range_multiplier"

func apply(player:Player):
	if not player.STATS.get(STAT_NAME):
		player.STATS.set(STAT_NAME, 1)
	else :
		player.STATS.set(STAT_NAME,player.STATS.get(STAT_NAME)+1)
	print("Increase " + STAT_NAME + " to " + player.get(STAT_NAME))
