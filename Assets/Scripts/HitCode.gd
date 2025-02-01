extends TextureRect

#	attack and weapon animation code

var readied = false
var sheathanim = false
var pulled = false
var recovering = false

var atkspeedtimer = 0		# TODO: replace weapon system
var atkspeedtimerMax = 20

var tex_idle = load("res://Assets/Textures/Weapons/fist1.png")
var tex_pull = load("res://Assets/Textures/Weapons/fist2.png")
var tex_cooldown = load("res://Assets/Textures/Weapons/fist3.png")

var rng = RandomNumberGenerator.new()

@onready var cam = $"../../Player/PlayerHeadPos/PlayerCamera"
@onready var p = $"../../Player/PlayerScripting"

func strike():
	print("striking...")
	var space = cam.get_world_3d().direct_space_state
	#	TODO: melee reach affected by weapon type
	var query = PhysicsRayQueryParameters3D.create(cam.global_position, \
		cam.global_position - cam.global_transform.basis.z * 3)
	var collision = space.intersect_ray(query)
	if collision and collision.collider.name == "CreatureCollider":
		#	TODO: damage function
		var mob = collision.collider.get_parent()
		if mob.state != mob.State.DEAD:
			var damage = ((p.STR / 2) - 5) + (rng.randi_range(p.dmgA, p.dmgA*p.dmgB) + p.dmgC) - mob.armor
			if damage >= 0:
				mob.cur_hp -= damage
				#	TODO: make a sound
				if mob.cur_hp <= 0:
					mob.state = mob.State.DEAD
				else:
					mob.state = mob.State.STUNNED

func _physics_process(delta: float) -> void:
	if atkspeedtimer > 0:
		atkspeedtimer -= 1
		if atkspeedtimer == 0:
			recovering = false
			texture = tex_idle
	
	if Input.is_action_just_pressed("Weapon") and !pulled and !recovering:
		readied = !readied
		sheathanim = true
		
	if Input.is_action_pressed("Attack"):
		if readied and !recovering and !sheathanim:
			texture = tex_pull	# TODO: change weapon image system
			pulled = true
	
	if Input.is_action_just_released("Attack") and pulled:
		#	TODO: idk check when you cant attack
		strike()
		texture = tex_cooldown
		pulled = false
		recovering = true
		atkspeedtimer = atkspeedtimerMax

	if sheathanim:
		if readied:
			set_position(Vector2(0, position.y-40))
			if position.y <= 0: 
				set_position(Vector2(0, 0))
				sheathanim = false
		else:
			set_position(Vector2(0, position.y+40))
			if position.y >= 1080:
				set_position(Vector2(0, 1080))
				sheathanim = false
