extends CharacterBody3D

signal killed

const SPEED = 2.5
var HEALTH = 10

var time_since_last_hit = 0.0

var grape_scene : PackedScene = preload("res://collectibles/loots/boular_grape.tscn")
@onready var animation_player : AnimationPlayer = $AnimationPlayer

@export var player: Node3D 

func _ready() -> void:
	killed.connect(player.on_ennemy_killed)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	time_since_last_hit += delta
	
	if player:
		var to_player = (player.global_position - global_position)
		to_player.y = 0  # Ignore vertical differences
		if to_player.length() > 0.1:
			var direction = to_player.normalized()
			
			# Movement
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
			
			# Smooth rotation toward player
			var target_rotation = Vector3(0, atan2(-direction.x, -direction.z), 0)
			rotation.y = lerp_angle(rotation.y, target_rotation.y, 5.0 * delta)
		else:
			# Slow down if close
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
	
func expose_to_light(delta: float, damage_per_tick: float, damage_cooldown: float):
	# Only take damage if cooldown passed
	if time_since_last_hit >= damage_cooldown :
		print(time_since_last_hit, " >= ", damage_cooldown, " : ", (time_since_last_hit >= damage_cooldown))
		HEALTH -= damage_per_tick
		time_since_last_hit = 0.0  # reset cooldown
		damage_animation()
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


func damage_animation() -> void :
	animation_player.play("damage_hit")
	pass
