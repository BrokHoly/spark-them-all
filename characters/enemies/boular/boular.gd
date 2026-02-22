extends CharacterBody3D

signal killed

const SPEED = 2.5
var HEALTH = 5

var time_since_last_hit = 0.0

var grape_scene : PackedScene = preload("res://collectibles/loots/boular_grape.tscn")

func _ready() -> void:
	killed.connect(player.on_ennemy_killed)

func expose_to_light(delta: float, damage_per_tick: int, damage_cooldown: float):
	# Only take damage if cooldown passed
	if time_since_last_hit >= damage_cooldown:
		HEALTH -= damage_per_tick
		time_since_last_hit = 0.0  # reset cooldown
		if HEALTH <= 0:
			_drop_grapes()
			emit_signal("killed")
			queue_free()
		
func _drop_grapes():
	if not grape_scene:
		return
	
	var count = randi() % 3 + 1  # 1 to 3 grapes
	
	for i in count:
		var grape = grape_scene.instantiate() as RigidBody3D
		get_parent().add_child(grape)
		
		# Spawn slightly above Boular and slightly offset to reduce initial collision
		var offset = Vector3(randf() - 0.5, 0, randf() - 0.5) * 0.5  # small horizontal jitter
		grape.global_transform.origin = global_transform.origin + Vector3(0, 1.0, 0) + offset
		
		grape.sleeping = false
		var horizontal_angle = randf() * TAU
		var horizontal_radius = randf_range(0.3, 0.7)
		var direction = Vector3(sin(horizontal_angle) * horizontal_radius, 1.0, cos(horizontal_angle) * horizontal_radius).normalized()
		
		var force_magnitude = randf_range(6.0, 10.0)
		grape.apply_impulse(Vector3.ZERO, direction * force_magnitude)
		
		grape.angular_velocity = Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5)
