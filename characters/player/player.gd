extends CharacterBody3D

# Relative to player control
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const LOOK_SENSITIVITY = 0.002
const JOYSTICK_SENSITIVITY = 3.0
const JOYSTICK_DEADZONE = 0.15
var isFPS: bool = true

# Relative to the lamp
const LAMP_IDLE_ANGLE = 45
const LAMP_IDLE_RANGE = 5
const LAMP_FOCUS_ANGLE = 30
const LAMP_FOCUS_RANGE = 10

@onready var camera: Node3D = $FPSAnchor
@onready var lamp: Node3D = $LampAnchor

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

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

		camera.rotate_x(-event.relative.y * LOOK_SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

		update_lamp_rotation()

# 🎮 Gamepad look (NEW)
func handle_joystick_look(delta: float) -> void:
	var look_input := Input.get_vector("look_left", "look_right", "look_up", "look_down")

	# Apply deadzone
	if look_input.length() < JOYSTICK_DEADZONE:
		return

	rotate_y(-look_input.x * JOYSTICK_SENSITIVITY * delta)

	camera.rotate_x(-look_input.y * JOYSTICK_SENSITIVITY * delta)
	camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)

	update_lamp_rotation()

# 🔦 Shared lamp logic (so we don't duplicate code)
func update_lamp_rotation() -> void:
	var target_lamp_x = clamp(camera.rotation.x, -PI/4, PI/4)
	lamp.rotation.x = lerp(lamp.rotation.x, target_lamp_x, 0.15)
