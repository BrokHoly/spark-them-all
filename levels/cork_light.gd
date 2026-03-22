extends Affected

var isOpen: bool = false
var speed = 3.0
var target = Vector3(0, -5, 0)
var finished: bool = false

func _process(delta: float):
	if isOpen and not finished:
		var direction = (target - global_transform.origin).normalized()
		if direction == Vector3.ZERO:
			finished = true
		global_transform.origin += direction * speed * delta
	
func affect(_state: bool):
	isOpen = true
