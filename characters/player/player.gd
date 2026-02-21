extends CharacterBody3D

# Relative to player control
const SPEED = 5.0
const SPRINT_MULTIPLIER = 1.5
const JUMP_VELOCITY = 4.5
const LOOK_SENSITIVITY = 0.002
const JOYSTICK_SENSITIVITY = 3.0
const JOYSTICK_DEADZONE = 0.15
const BASE_FOV = 75.0
const SPRINT_FOV = 85.0

var boular_grapes = 0;

var isFPS: bool = true

# Relative to the lamp
const LAMP_IDLE_ANGLE = 45
const LAMP_IDLE_RANGE = 5
const LAMP_FOCUS_ANGLE = 30
const LAMP_FOCUS_RANGE = 10

@onready var fps_anchor: Node3D = $FPSAnchor
@onready var camera: Camera3D = $FPSAnchor/Camera3D
@onready var lamp: Node3D = $LampAnchor
@onready var collectible_area: Area3D = $CollectibleRange


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
	
	#Sprint
	var speed_multiplier = 1.0
	var fov = BASE_FOV
	if(Input.is_action_pressed("sprint")):
		speed_multiplier = SPRINT_MULTIPLIER
		fov = SPRINT_FOV
	camera.fov = lerp(camera.fov, fov, 8.0 * delta)
	
	if direction:
		velocity.x = direction.x * SPEED * speed_multiplier
		velocity.z = direction.z * SPEED * speed_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * speed_multiplier)
		velocity.z = move_toward(velocity.z, 0, SPEED * speed_multiplier)

	move_and_slide()

	# 🎮 Handle joystick look separately
	handle_joystick_look(delta)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().quit()

# 🖱 Mouse look (UNCHANGED LOGIC)
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * LOOK_SENSITIVITY)

		fps_anchor.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
		fps_anchor.rotation.x = clamp(fps_anchor.rotation.x, -PI/2, PI/2)

		update_lamp_rotation()

# 🎮 Gamepad look (NEW)
func handle_joystick_look(delta: float) -> void:
	var look_input := Input.get_vector("look_left", "look_right", "look_up", "look_down")

	# Apply deadzone
	if look_input.length() < JOYSTICK_DEADZONE:
		return

	rotate_y(-look_input.x * JOYSTICK_SENSITIVITY * delta)

	fps_anchor.rotate_x(-look_input.y * JOYSTICK_SENSITIVITY * delta)
	fps_anchor.rotation.x = clamp(fps_anchor.rotation.x, -PI/2, PI/2)

	update_lamp_rotation()

# 🔦 Shared lamp logic (so we don't duplicate code)
func update_lamp_rotation() -> void:
	var target_lamp_x = clamp(fps_anchor.rotation.x, -PI/4, PI/4)
	lamp.rotation.x = lerp(lamp.rotation.x, target_lamp_x, 0.15)


func _on_collectible_entered(body: Node3D):
	if(body.is_in_group("collectible")):
		collect_item(body)
	
	
	
func collect_item(body: Node3D):
	boular_grapes += 1
	print("COLLECT ALLÉ : ", boular_grapes)
	body.queue_free()
