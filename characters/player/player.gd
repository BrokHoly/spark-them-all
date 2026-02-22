extends CharacterBody3D

# Relative to player control
const SPEED = 5.0
const SPRINT_MULTIPLIER = 1.5
const WALK_MULTIPLIER = 0.8
const JUMP_VELOCITY = 4.5
const LOOK_SENSITIVITY = 0.002
const JOYSTICK_SENSITIVITY = 3.0
const JOYSTICK_DEADZONE = 0.15
const BASE_FOV = 75.0
const SPRINT_FOV = 85.0
const FOCUS_FOV = 70.0

const MAX_HEALTH = 10
var health = MAX_HEALTH 

var lamp_damage_cooldown = 0.5   # seconds between hits
var lamp_damage_per_tick = 1

var boular_grapes = 0
var kill_score = 0

var isFPS: bool = true

# Relative to the lamp
const LAMP_IDLE_ANGLE = 45.0
const LAMP_IDLE_RANGE = 5.0
const LAMP_FOCUS_ANGLE = 20.0
const LAMP_FOCUS_RANGE = 15.0
const LAMP_IDLE_RADIUS = 2.0
const LAMP_FOCUS_RADIUS = 1.0

@onready var fps_anchor: Node3D = $FPSAnchor
@onready var camera: Camera3D = $FPSAnchor/Camera3D
@onready var lamp_anchor: Node3D = $LampAnchor
@onready var lamp_spotlight: SpotLight3D = $LampAnchor/SpotLight3D
@onready var collectible_area: Area3D = $CollectibleRange
@onready var aim_area: Area3D = $LampAnchor/AimArea
@onready var cylinder_shape: CylinderShape3D = $LampAnchor/AimArea/CylinderShape.shape
@onready var raycast: RayCast3D = $FPSAnchor/RayCast3D
@onready var interaction_label: Label = $Hud/BaseHUD/InteractLabel


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	collectible_area.body_entered.connect(_on_collectible_entered)
	

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# Sprint / Walk / Focus
	var speed_multiplier = 1.0
	var fov = BASE_FOV
	var lamp_angle = LAMP_IDLE_ANGLE
	var lamp_range = LAMP_IDLE_RANGE
	var lamp_radius = LAMP_IDLE_RADIUS
	if(Input.is_action_pressed("focus")):
		speed_multiplier = WALK_MULTIPLIER
		fov = FOCUS_FOV
		lamp_angle = LAMP_FOCUS_ANGLE
		lamp_range = LAMP_FOCUS_RANGE
		lamp_radius = LAMP_FOCUS_RADIUS
	elif (Input.is_action_pressed("sprint")):
		speed_multiplier = SPRINT_MULTIPLIER
		fov = SPRINT_FOV
	camera.fov = lerp(camera.fov, fov, 8.0 * delta)
	lamp_spotlight.spot_angle = lerp(lamp_spotlight.spot_angle, lamp_angle, 8.0 * delta)
	lamp_spotlight.spot_range = lerp(lamp_spotlight.spot_range, lamp_range, 8.0 * delta)

	# Update lamp collision area
	_update_lamp_area(lamp_range, lamp_radius)

	# Movement velocity
	if direction:
		velocity.x = direction.x * SPEED * speed_multiplier
		velocity.z = direction.z * SPEED * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * speed_multiplier)
		velocity.z = move_toward(velocity.z, 0, SPEED * speed_multiplier)

	move_and_slide()

	# Handle joystick look separately
	handle_joystick_look(delta)

	# Handle lamp burn on Boulars
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

# 🔹 Update the cylinder collision to grow forward from lamp
func _update_lamp_area(range: float, radius: float) -> void:
	# Update the CylinderShape3D
	cylinder_shape.height = range
	cylinder_shape.radius = radius
	# Offset the area so cylinder grows forward from lamp origin
	# Cylinder extends equally, so move origin forward by half its height
	aim_area.transform.origin = Vector3(0, 0, -range * 0.5)
	# Make sure area always points forward along lamp
	aim_area.global_transform = lamp_anchor.global_transform
	aim_area.global_transform = lamp_anchor.global_transform

# 🔹 Check if a body is inside the cone
func _is_in_lamp_cone(body: Node3D) -> bool:
	var to_body = body.global_position - lamp_anchor.global_position
	var distance = to_body.length()
	if distance > lamp_spotlight.spot_range:
		return false
	var forward = -lamp_anchor.global_transform.basis.z
	var dot = forward.normalized().dot(to_body.normalized())
	var threshold = cos(deg_to_rad(lamp_spotlight.spot_angle * 0.5))
	return dot > threshold
	
# 🔹 Handle lamp exposure for Boulars
func _handle_lamp_burn(delta: float) -> void:
	# Loop through overlapping bodies in AimArea
	for body in aim_area.get_overlapping_bodies():
		if body.is_in_group("ennemy"):  # Your enemy group
			if _is_in_lamp_cone(body):
				# Each Boular should implement expose_to_light(delta)
				body.expose_to_light(delta, lamp_damage_per_tick, lamp_damage_cooldown)
				#print("IN IT ????", Time.get_unix_time_from_system())

# Collectible system (unchanged)
func _on_collectible_entered(body: Node3D):
	if(body.is_in_group("collectible")):
		collect_item(body)
	
func collect_item(body: Node3D):
	boular_grapes += 1
	print("COLLECT ALLÉ : ", boular_grapes)
	body.queue_free()

func on_ennemy_killed():
	kill_score += 1
	print("kill score : ", kill_score)
	
	
func _handle_interaction():
	if not raycast.is_colliding():
		_hide_interaction_text()
		return
	
	var collider = raycast.get_collider()
	
	if collider and collider.is_in_group("interactable"):
		_show_interaction_text("Press [F] to interact (or X on Xbox, or SQUARE on PS)")

		if Input.is_action_just_pressed("interact"):
			if collider.has_method("interact"):
				collider.interact(self)
	else:
		_hide_interaction_text()
		

func _show_interaction_text(text: String):
	interaction_label.text = text
	interaction_label.visible = true

func _hide_interaction_text():
	interaction_label.visible = false
