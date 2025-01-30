extends CharacterBody3D

const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.0015

@onready var head = $PlayerHeadPos
@onready var camera = $PlayerHeadPos/PlayerCamera
@onready var statcode = $PlayerScripting

var speed = 5.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	speed = statcode.AGI / 2
	# fall
	if not is_on_floor():
		velocity += get_gravity() * delta

	# jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# movement
	var input_dir := Input.get_vector("Strafe Left", "Strafe Right", "Forward", "Backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
