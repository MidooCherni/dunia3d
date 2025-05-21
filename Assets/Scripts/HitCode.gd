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

var hit_type = 0	# 0 = punch, 1 = blunt, 2 = slice, 3 = bow
var began_pull = false

var rng = RandomNumberGenerator.new()

@onready var cam = $"../../Player/PlayerHeadPos/PlayerCamera"
@onready var p = $"../../Player/PlayerScripting"
@onready var sfxobj = $WeaponSfx
@onready var lootholder = $"../Static/Cursor/LootHolder"
@onready var mapgen = $"../.."

var sfx_swing = preload("res://Assets/Sounds/combat/swing.wav")
var sfx_punch = preload("res://Assets/Sounds/combat/punch.wav")
var sfx_blunt = preload("res://Assets/Sounds/combat/blunt.wav")
var sfx_slice = preload("res://Assets/Sounds/combat/slice.ogg")
var sfx_unsheathe = preload("res://Assets/Sounds/combat/w_unsheathe.wav")
var sfx_sheathe = preload("res://Assets/Sounds/combat/w_sheathe.wav")
var sfx_bowpull = preload("res://Assets/Sounds/combat/bowPULL.wav")
var sfx_bowshoot = preload("res://Assets/Sounds/combat/bowSHOOT.wav")

func strike():
	sfxobj.stream = sfx_swing				# TODO: test for if the player can even swing (para, stun, down, etc)
	sfxobj.play()
	var attack_range = 3
	if p.Inventory[p.worn_items[0]].subtype == 8:
		attack_range = 6
	if p.Inventory[p.worn_items[0]].subtype == 10:
		attack_range = 255
	var space = cam.get_world_3d().direct_space_state
	#	TODO: melee reach affected by weapon type
	var query = PhysicsRayQueryParameters3D.create(cam.global_position, \
		cam.global_position - cam.global_transform.basis.z * attack_range)
	var collision = space.intersect_ray(query)
	if collision and collision.collider.name == "CreatureCollider":
		#	TODO: damage function
		var mob = collision.collider.get_parent()
		match hit_type:
			0:
				sfxobj.stream = sfx_punch
			1:
				sfxobj.stream = sfx_blunt
			2:
				sfxobj.stream = sfx_slice
			3:
				sfxobj.stream = sfx_bowshoot
		sfxobj.play()
		if mob.state != mob.State.DEAD:
			var damage = ((p.STR / 2) - 5) + (rng.randi_range(p.dmgA, p.dmgA*p.dmgB) + p.dmgC) - mob.armor
			if damage >= 0:
				mob.cur_hp -= damage
				if mob.cur_hp <= 0:
					mob.state = mob.State.DEAD
				else:
					mob.state = mob.State.STUNNED

func try_display_container():
	var objToLootFrom = null
	var shouldShowLoot = false
	var space = cam.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(cam.global_position, \
		cam.global_position - cam.global_transform.basis.z * 3)
	var collision = space.intersect_ray(query)
	if collision and collision.collider.name == "StaticBody3D":
		var obj = collision.collider.get_parent().get_parent().get_parent()
		if collision.collider.get_parent().get_parent().name in ["chest_full", "chest_empty"]:
			if obj.active == false:
				if Input.is_action_just_pressed("Activate") and (obj.keyid == 0 or p.Inventory[obj.keyid].qty > 0):
					obj.active = true
					obj.get_child(0).queue_free()
					var chest_mesh2 = load("res://Assets/Meshes/Interactables/chest_empty.blend").instantiate()
					obj.add_child(chest_mesh2)
					sfxobj.stream = obj.useSfx
					sfxobj.play()
			else:
				objToLootFrom = obj
				shouldShowLoot = true
		elif collision.collider.get_parent().get_parent().name == "door":
			if Input.is_action_just_pressed("Activate") and (obj.keyid == 0 or p.Inventory[obj.keyid].qty > 0) and !obj.active:
				obj.value = [100]
				obj.active = true
				mapgen.grid[obj.contents[0]][obj.contents[1]] = '.'
				sfxobj.stream = obj.useSfx
				sfxobj.play()
	if collision and collision.collider.name == "CreatureCollider":
		var mob = collision.collider.get_parent()
		if mob.state == mob.State.DEAD:
			if mob.contents.size() > 0:
				objToLootFrom = mob 
				shouldShowLoot = true
	if shouldShowLoot:
		lootholder.visible = true
		lootholder.contents = objToLootFrom.contents
		if Input.is_action_just_pressed("Activate"):
			p.Inventory[lootholder.contents[lootholder.cursor]].qty += 1
			objToLootFrom.contents.remove_at(lootholder.cursor)
			lootholder.contents = objToLootFrom.contents
			if lootholder.cursor >= lootholder.contents.size()-1: lootholder.cursor = lootholder.contents.size()-1
			p.audioplayer.stream = p.sfx_clothes
			p.audioplayer.play()
	else:
		lootholder.resetcursor() 
		lootholder.visible = false

func _physics_process(_delta: float) -> void:
	try_display_container()
	
	if atkspeedtimer > 0:
		atkspeedtimer -= 1
		if atkspeedtimer == 0:
			recovering = false
			texture = tex_idle
	
	if Input.is_action_just_pressed("Weapon") and !pulled and !recovering:
		readied = !readied
		sheathanim = true
		if hit_type > 0:
			if readied:
				sfxobj.stream = sfx_unsheathe
			else:
				sfxobj.stream = sfx_sheathe
			sfxobj.play()
		
	if Input.is_action_pressed("Attack"):
		if readied and !recovering and !sheathanim:
			if hit_type == 3:
				if !began_pull:
					sfxobj.stream = sfx_bowpull
					sfxobj.play()
					began_pull = true
			texture = tex_pull
			pulled = true
	
	if Input.is_action_just_released("Attack") and pulled:
		#	TODO: idk check when you cant attack
		began_pull = false
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
