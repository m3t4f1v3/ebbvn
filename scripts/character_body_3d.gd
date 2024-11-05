extends CharacterBody3D

# Minecraft physics constants
const GRAVITY = 32.0
const WALK_SPEED = 4.317
const SPRINT_SPEED = 5.612
const JUMP_FORCE = 9.0
const TERMINAL_VELOCITY = 78.4
const AIR_RESISTANCE = 0.98
const GROUND_FRICTION = 0.6

# Mouse sensitivity (Minecraft's default is 100% which is roughly equivalent to 0.022)
const MOUSE_SENSITIVITY = 0.0022

# Player state
var is_sprinting := false
var want_to_jump := false

# Camera nodes (assign these in the editor)
@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready() -> void:
	# Capture mouse
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Ensure camera starts level
	head.rotation.x = 0
	head.rotation.z = 0
	camera.rotation.x = 0
	camera.rotation.z = 0

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("left", "right")
	input_dir.y = Input.get_axis("forward", "backward")
	input_dir = input_dir.normalized()
	
	# Get current horizontal velocity
	var current_horizontal_velocity := Vector3(velocity.x, 0, velocity.z)
	
	# Handle movement
	if input_dir != Vector2.ZERO:
		# Convert input direction to world space based on head rotation
		var head_basis = head.global_transform.basis
		var movement_direction = head_basis * Vector3(input_dir.x, 0, input_dir.y)
		movement_direction.y = 0
		movement_direction = movement_direction.normalized()
		
		# Apply movement force
		var target_speed := SPRINT_SPEED if is_sprinting else WALK_SPEED
		var target_velocity = movement_direction * target_speed
		
		# Accelerate towards target velocity
		if is_on_floor():
			current_horizontal_velocity = current_horizontal_velocity.lerp(target_velocity, GROUND_FRICTION)
		else:
			current_horizontal_velocity = current_horizontal_velocity.lerp(target_velocity, 0.02)
	else:
		# Apply friction when no input
		if is_on_floor():
			current_horizontal_velocity = current_horizontal_velocity.lerp(Vector3.ZERO, GROUND_FRICTION)
		
	# Apply air resistance
	if not is_on_floor():
		current_horizontal_velocity *= AIR_RESISTANCE
	
	# Handle vertical movement
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
		velocity.y = maxf(velocity.y, -TERMINAL_VELOCITY)
	elif want_to_jump:
		velocity.y = JUMP_FORCE
	
	# Update horizontal velocity
	velocity.x = current_horizontal_velocity.x
	velocity.z = current_horizontal_velocity.z
	
	# Reset jump input
	want_to_jump = false
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("jump") and is_on_floor():
		want_to_jump = true
	
	if event.is_action_pressed("sprint"):
		is_sprinting = true
	elif event.is_action_released("sprint"):
		is_sprinting = false
		
	# Mouse look
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Rotate head (left/right)
		head.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		
		# Rotate camera (up/down)
		var current_tilt: float = camera.rotation.x
		current_tilt -= event.relative.y * MOUSE_SENSITIVITY
		# Clamp the up/down rotation to prevent over-rotation
		current_tilt = clampf(current_tilt, -PI/2, PI/2)
		camera.rotation.x = current_tilt
	
	# Toggle mouse capture
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
