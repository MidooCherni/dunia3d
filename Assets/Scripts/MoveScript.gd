extends CharacterBody3D

#	player movement code

const JUMP_VELOCITY = 2
const SENSITIVITY = 0.0015

@onready var head = $PlayerHeadPos
@onready var camera = $PlayerHeadPos/PlayerCamera
@onready var statcode = $PlayerScripting

@onready var soundsource = $PlayerFootsteps
var sfx_walkloop = preload("res://Assets/Sounds/walkloop.mp3")

var speed = 5.0
var mousecap = true

func tile(num):
	if (int(num) % 2) == 0:
		return int(num)
	else:
		return (int(num)+1)

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion and mousecap:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _physics_process(delta: float) -> void:
	if statcode.agicap == 0 or statcode.agicap > statcode.AGI:
		speed = statcode.AGI / 2
	else:
		speed = statcode.agicap / 2
	
	# fall
	if not is_on_floor():
		velocity += get_gravity() * delta

	# capture mouse
	if Input.is_action_just_pressed	("Capture"):
		if mousecap:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			mousecap = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mousecap = true

	# jump
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# movement
	var input_dir := Input.get_vector("Strafe Left", "Strafe Right", "Forward", "Backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if !soundsource.is_playing():
			soundsource.stream = sfx_walkloop
			soundsource.play()
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		if soundsource.is_playing(): soundsource.stop()
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
