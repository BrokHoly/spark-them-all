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

var isFPS: bool = true

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


func _ready() -> void:
	
	health = stats.get_stat("max_health")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	collectible_area.body_entered.connect(_on_collectible_entered)

func _physics_process(delta: float) -> void:
	if stats == null:
		print(stats)
		return
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = stats.get_stat("jump_velocity")

	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprint / Walk / Focus
	var sprint_multiplier = 1.0;
	var fov = BASE_FOV
	var lamp_angle = stats.get_stat("lamp_idle_angle")
	var lamp_range = stats.get_stat("lamp_idle_range")
	if(Input.is_action_pressed("focus")):
		sprint_multiplier = stats.get_stat("sprint_multiplier")
		fov = FOCUS_FOV
		lamp_angle = stats.get_stat("lamp_focus_angle")
		lamp_range = stats.get_stat("lamp_focus_range")
	elif (Input.is_action_pressed("sprint")):
		sprint_multiplier = stats.get_stat("sprint_multiplier")
		fov = SPRINT_FOV
	camera.fov = lerp(camera.fov, fov, 8.0 * delta)
	lamp_spotlight.spot_angle = lerp(lamp_spotlight.spot_angle, lamp_angle, 8.0 * delta)
	lamp_spotlight.spot_range = lerp(lamp_spotlight.spot_range, lamp_range, 8.0 * delta)
	spot_collide_sphere.shape.radius = lamp_range
	
	if direction:
		velocity.x = direction.x * stats.get_stat("speed") * sprint_multiplier
		velocity.z = direction.z * stats.get_stat("speed") * sprint_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, stats.get_stat("speed") * sprint_multiplier)
		velocity.z = move_toward(velocity.z, 0, stats.get_stat("speed") * sprint_multiplier)

	move_and_slide()

	handle_joystick_look(delta)

	_handle_lamp_burn(delta)
	
	_handle_interaction()

# Mouse look
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * LOOK_SENSITIVITY)
		fps_anchor.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
		fps_anchor.rotation.x = clamp(fps_anchor.rotation.x, -PI/2, PI/2)
		update_lamp_rotation()

# Gamepad look
func handle_joystick_look(delta: float) -> void:
	var look_input := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if look_input.length() < JOYSTICK_DEADZONE:
		return
	rotate_y(-look_input.x * JOYSTICK_SENSITIVITY * delta)
	fps_anchor.rotate_x(-look_input.y * JOYSTICK_SENSITIVITY * delta)
	fps_anchor.rotation.x = clamp(fps_anchor.rotation.x, -PI/2, PI/2)
	update_lamp_rotation()

# Shared lamp rotation
func update_lamp_rotation() -> void:
	var target_lamp_x = clamp(fps_anchor.rotation.x, -PI/4, PI/4)
	lamp_anchor.rotation.x = lerp(lamp_anchor.rotation.x, target_lamp_x, 0.15)

# 🔹 Check if a body is inside the cone
func _is_in_spotlight(body: Node3D) -> bool:
	var to_body = body.global_position - lamp_spotlight.global_position
	var distance = to_body.length()
	
	if distance > lamp_spotlight.spot_range:
		return false

	var forward = -lamp_spotlight.global_transform.basis.z
	var cos_angle = forward.dot(to_body.normalized())

	var limit = cos(deg_to_rad(lamp_spotlight.spot_angle * 0.5))
	return cos_angle > limit
	
# 🔹 Handle lamp exposure for Boulars
func _handle_lamp_burn(delta: float) -> void:
	for body in spot_area.get_overlapping_bodies():
		if body.is_in_group("ennemy"):  # Your enemy group
			if _is_in_spotlight(body):
				body.expose_to_light(delta, stats.get_stat("lamp_idle_damage_per_tick"), stats.get_stat("lamp_damage_cooldown"))

# Collectible system (unchanged)
func _on_collectible_entered(body: Node3D):
	if(body.is_in_group("collectible")):
		collect_item(body)
	
func collect_item(body: Node3D):
	boular_grapes += 1
	emit_signal("grape_collected", boular_grapes)  # <- signal emitted
	body.queue_free()

func on_ennemy_killed():
	kill_score += 1
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

func _clear_hover():
	if current_hovered:
		current_hovered.is_being_pressed = false
		current_hovered.on_hover_exit()
		current_hovered = null
	hud.hide_help_text()
