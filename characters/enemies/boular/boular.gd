extends CharacterBody3D

signal killed

const SPEED = 2.5
var HEALTH = 10

var time_since_last_hit = 0.0

var grape_scene : PackedScene = preload("res://collectibles/loots/boular_grape.tscn")
var damage_number_scene: PackedScene = preload("res://characters/enemies/boular/damage_number.tscn")
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer
@onready var mesh = $BodyMesh/MeshInstance3D
 
@export var player: Node3D 

func _ready() -> void:
	mesh.material_overlay = mesh.material_overlay.duplicate()
	if player and player.has_method("on_ennemy_killed"):
		killed.connect(player.on_ennemy_killed)

func _physics_process(delta: float):
	time_since_last_hit += delta
	if player:
		# Update agent target
		agent.target_position = player.global_position
		# Move along the path given by the agent
		if not agent.is_navigation_finished():
			var next_pos = agent.get_next_path_position()
			var dir = next_pos - global_position
			dir.y = 0  # Ignore vertical for rotation
			var distance = dir.length()
			if distance > 0.1:
				dir = dir.normalized()
				# Use velocity vector based on SPEED
				velocity.x = dir.x * SPEED
				velocity.z = dir.z * SPEED
				# Smooth rotation toward movement direction
				var target_rot_y = atan2(-dir.x, -dir.z)
				rotation.y = lerp_angle(rotation.y, target_rot_y, 5.0 * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
		else:
			# Stop if path finished
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	# Apply gravity if in the air
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func expose_to_light(delta: float, damage_per_tick: float, damage_cooldown: float):
	# Only take damage if cooldown passed
	if time_since_last_hit >= damage_cooldown :
		HEALTH -= damage_per_tick
		time_since_last_hit = 0.0  # reset cooldown
		_show_damage_number(damage_per_tick)
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
	audio_player.play()
	animation_player.play("damage_hit")


func _show_damage_number(amount: float):
	if not damage_number_scene:
		return
	var dmg = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg)
	var offset = Vector3(randf_range(-0.3,0.3),0,randf_range(-0.3,0.3))
	dmg.global_position = global_position + Vector3(0,1,0) + offset
	dmg.setup(amount)
