extends CharacterBody3D
class_name Player

signal grape_collected(new_count: int)
signal enemy_killed(new_count: int)

@export var stats: Stats

# Relative to player control
const LOOK_SENSITIVITY = 0.002
const JOYSTICK_SENSITIVITY = 3.0
const JOYSTICK_DEADZONE = 0.15

const BASE_FOV = 75.0
const SPRINT_FOV = 85.0
const FOCUS_FOV = 70.0

var health : float

var boular_grapes = 0
var kill_score = 0
var run_grapes = 0
var run_kills = 0
var light_on = true
var time_since_last_hurt_hit = 0.0

var isFPS: bool = true
var is_focusing := false
var is_dead = false

var current_hovered: Interactable = null

@onready var fps_anchor: Node3D = $FPSAnchor
@onready var camera: Camera3D = $FPSAnchor/Camera3D
@onready var lamp_anchor: Node3D = $LampAnchor
@onready var lamp_spotlight: SpotLight3D = $LampAnchor/SpotLight3D
@onready var collectible_area: Area3D = $CollectibleRange
@onready var spot_area: Area3D = $LampAnchor/SpotArea
@onready var spot_collide_sphere: CollisionShape3D = $LampAnchor/SpotArea/SphereShape
@onready var raycast: RayCast3D = $FPSAnchor/RayCast3D
@onready var hud: HUD = $Hud
@onready var hurt_area: Area3D = $HurtArea

@onready var glowstick_scene: PackedScene = preload("res://models/props/glow_stick.tscn")

func _ready() -> void:
	health = stats.get_stat("max_health")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	collectible_area.body_entered.connect(_on_collectible_entered)


func _physics_process(delta: float) -> void:
	if stats == null:
		return
	
	time_since_last_hurt_hit += delta
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = stats.get_stat("jump_velocity")
		
	if Input.is_action_just_pressed("throw"):
		throw_glowstick()

	_handle_movement(delta)

	move_and_slide()

	handle_joystick_look(delta)

	_handle_lamp_burn(delta)
	_handle_interaction()
	_update_lamp_area()
	
	handle_hurt()


func _handle_movement(delta: float) -> void:

	var input_dir := Input.get_vector("move_left","move_right","move_forward","move_backward")
	var direction := (transform.basis * Vector3(input_dir.x,0,input_dir.y)).normalized()

	is_focusing = Input.is_action_pressed("focus")
	var is_sprinting := Input.is_action_pressed("sprint") and not is_focusing

	var speed_multiplier := 1.0
	var target_fov := BASE_FOV
	var lamp_angle := stats.get_stat("lamp_idle_angle")
	var lamp_range := stats.get_stat("lamp_idle_range")

	if is_focusing:
		target_fov = FOCUS_FOV
		lamp_angle = stats.get_stat("lamp_focus_angle")
		lamp_range = stats.get_stat("lamp_focus_range")

	elif is_sprinting:
		speed_multiplier = stats.get_stat("sprint_multiplier")
		target_fov = SPRINT_FOV

	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)

	lamp_spotlight.spot_angle = lerp(lamp_spotlight.spot_angle, lamp_angle, 8.0 * delta)
	lamp_spotlight.spot_range = lerp(lamp_spotlight.spot_range, lamp_range, 8.0 * delta)

	spot_collide_sphere.shape.radius = lamp_range

	var speed := stats.get_stat("speed") * speed_multiplier

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


# Mouse look
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		fps_anchor.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
		fps_anchor.rotation.x = clamp(fps_anchor.rotation.x,-PI/2,PI/2)
		update_lamp_rotation()
		
	# Toggle spotlight
	if event.is_action_pressed("toggle_light"):
		light_on = !light_on
		lamp_spotlight.visible = light_on
		spot_area.visible = light_on


# Gamepad look
func handle_joystick_look(delta: float) -> void:

	var look_input := Input.get_vector("look_left","look_right","look_up","look_down")

	if look_input.length() < JOYSTICK_DEADZONE:
		return

	rotate_y(-look_input.x * JOYSTICK_SENSITIVITY * delta)
	fps_anchor.rotate_x(-look_input.y * JOYSTICK_SENSITIVITY * delta)

	fps_anchor.rotation.x = clamp(fps_anchor.rotation.x,-PI/2,PI/2)

	update_lamp_rotation()


func update_lamp_rotation() -> void:
	var target_lamp_x = clamp(fps_anchor.rotation.x,-PI/4,PI/4)
	lamp_anchor.rotation.x = lerp(lamp_anchor.rotation.x,target_lamp_x,0.15)


# Check if body inside cone
func _is_in_spotlight(body: Node3D) -> bool:
	if not light_on:
		return false

	# Position relative
	var to_body = body.global_position - lamp_spotlight.global_position
	var distance = to_body.length()

	# Choisir les stats selon le mode
	var lamp_range = stats.get_stat("lamp_idle_range")
	var lamp_angle = stats.get_stat("lamp_idle_angle")

	if is_focusing:
		lamp_range = stats.get_stat("lamp_focus_range")
		lamp_angle = stats.get_stat("lamp_focus_angle")

	# Vérifier la distance
	if distance > lamp_range:
		return false

	# Vérifier l'angle du cône
	var forward = -lamp_spotlight.global_transform.basis.z
	var cos_angle = forward.dot(to_body.normalized())
	var angle_limit = cos(deg_to_rad(lamp_angle * 1.1))
	
	return cos_angle > angle_limit


# Lamp damage system
func _handle_lamp_burn(delta: float) -> void:
	var damage := stats.get_stat("lamp_idle_damage_amount")
	var cooldown := stats.get_stat("lamp_idle_damage_cooldown")

	if is_focusing:
		damage = stats.get_stat("lamp_focus_damage_amount")
		cooldown = stats.get_stat("lamp_focus_damage_cooldown")

	# Parcourir les corps dans la zone de la lampe
	for body in spot_area.get_overlapping_bodies():
		if body.is_in_group("ennemy"):
			# Vérifier s'ils sont dans le cône exact
			if _is_in_spotlight(body):
				body.expose_to_light(delta, damage, cooldown)

# Collectibles
func _on_collectible_entered(body: Node3D):
	if body.is_in_group("collectible"):
		collect_item(body)


func collect_item(body: Node3D):
	stats.add_flat("run_grapes", 1)
	stats.add_flat("grapes_collected", 1) # total global += 1
	emit_signal("grape_collected", boular_grapes)
	body.queue_free()


func on_ennemy_killed():
	stats.add_flat("run_kills", 1)
	stats.add_flat("enemies_killed", 1) # total global
	emit_signal("enemy_killed",kill_score)


func _handle_interaction():

	if not raycast.is_colliding():
		_clear_hover()
		return

	var collider = raycast.get_collider()

	if collider is Interactable and collider.enable:

		if current_hovered != collider:
			_clear_hover()
			current_hovered = collider
			current_hovered.on_hover_enter()
			hud.show_help_text(current_hovered.INTERACTION_TEXT)

		current_hovered.handle_input(
			self,
			Input.is_action_pressed("interact"),
			get_physics_process_delta_time()
		)

	else:
		_clear_hover()


func _update_lamp_area() -> void:
	var lamp_range = stats.get_stat("lamp_idle_range")
	if is_focusing:
		lamp_range = stats.get_stat("lamp_focus_range")

	# Sphere radius = range
	spot_collide_sphere.shape.radius = lamp_range
	# On peut aussi ajuster la position ou le shape si nécessaire
	spot_area.visible = light_on


func _clear_hover():
	if current_hovered:
		current_hovered.is_being_pressed = false
		current_hovered.on_hover_exit()
		current_hovered = null

	hud.hide_help_text()

func handle_hurt():
	if is_dead:
		return
	for body in hurt_area.get_overlapping_bodies():
		if body.is_in_group("ennemy"):
			if time_since_last_hurt_hit < 1.0:
				return
			else:
				print("HIT")
				time_since_last_hurt_hit = 0.0
				health -= 1.0
				hud.show_damage()
				if health <= 0.0:
					die()
				return

func die():
	if is_dead:
		return
	is_dead = true
	print("DEAD")
	set_physics_process(false)
	set_process(false)
	
	camera.fov = 60.0
	velocity = Vector3.ZERO
	Engine.time_scale = 0.3

	hud.show_death_screen()

func throw_glowstick():
	var glowstick = glowstick_scene.instantiate()

	var origin = camera.global_transform.origin
	var forward = -camera.global_transform.basis.z
	
	glowstick.global_position = origin + forward * 1.5
	glowstick.rotation = Vector3(
		randf_range(0, TAU),
		randf_range(0, TAU),
		randf_range(0, TAU)
	)
	get_tree().current_scene.add_child(glowstick)

	glowstick.throw(forward)
