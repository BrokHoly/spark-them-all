extends CharacterBody3D

signal killed

const SPEED = 3.0
var HEALTH = 10

var time_since_last_hit = 0.0

@export var player: Node3D   # Assign player in inspector or dynamically

func _ready() -> void:
	killed.connect(player.on_ennemy_killed)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	time_since_last_hit += delta
	
	if player:
		var to_player = (player.global_position - global_position)
		to_player.y = 0  # Ignore vertical differences for flat movement
		if to_player.length() > 0.1:
			var direction = to_player.normalized()
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func expose_to_light(delta: float, damage_per_tick: int, damage_cooldown: float):
	# Only take damage if cooldown passed
	if time_since_last_hit >= damage_cooldown:
		HEALTH -= damage_per_tick
		time_since_last_hit = 0.0  # reset cooldown
		print("Boular hit! Health:", HEALTH)
		if HEALTH <= 0:
			emit_signal("killed")
			queue_free()
