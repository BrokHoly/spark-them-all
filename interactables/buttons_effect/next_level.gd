extends Resource
class_name ButtonEffect

const MAX = 3

func apply(_player:Player):
	if Game.cave_level < 3:
		Game.cave_level += 1
