extends Node3D

# contains mob dictionary, handles spawning

@onready var p = $"../Player/PlayerScripting"
@onready var mapgen = $".."

#	loot groups: if mob drops this loot group, game will roll a dice within it to see which drops
var lg_lt_weapons = [4, 6, 7]	# low tier weaponry
var lg_lt_armors = [5]	#
var lg_lt_consumes = [2, 3, 8]

var rng = RandomNumberGenerator.new()

enum Type{
	ANIMAL, CONSTRUCT, CRYPTID, DRAGON, ELEMENTAL,
	FIEND, HUMANOID, SPIRIT, UNDEAD,
	DEBUG
}
class Creature:
	var mobname = "null"
	var level = 1
	var type = Type.DEBUG
	var STR = 10
	var CON = 10
	var DEX = 10
	var AGI = 10
	var INT = 10
	var WIS = 10
	var CHA = 10
	var dmgA = 0	# num of dice
	var dmgB = 0	# dice face
	var dmgC = 0	# +const
	var aggressive = false
	var armor = 0
	var drops = []
	func _init(_mn, _lev, _typ:Type, _s, _co, _d, _a, _i, _w, _ch, ag, _dA, _dB, _dC, _ar, _drops):
		self.mobname = _mn
		self.STR = _s
		self.CON = _co
		self.DEX = _d
		self.AGI = _a
		self.INT = _i
		self.WIS = _w
		self.CHA = _ch
		self.level = _lev
		self.type = _typ
		self.aggressive = ag
		self.dmgA = _dA
		self.dmgB = _dB
		self.dmgC = _dC
		self.armor = _ar
		self.drops = _drops

# 		creature list begins here
var goblin = Creature.new("goblin", 1, Type.HUMANOID, 8, 10, 14, 13, 10, 8, 8, true, 1, 6, 2, 0, [[lg_lt_weapons, 100], [lg_lt_armors, 100], [lg_lt_consumes, 100]])
# 		creature list ends

func spawn_light_source(xpos, ypos):
	var lightfile = preload("res://Assets/Templates/lightsource.tscn")
	var light = lightfile.instantiate()
	add_child(light)
	light.scale = Vector3(1.5, 1.5, 1.5)
	light.position.x = xpos*2
	light.position.y = 2.5
	light.position.z = ypos*2
	

func create_stairs(xpos, ypos):
	var stair_file = preload("res://Assets/Templates/interactable.tscn")
	var stairs = stair_file.instantiate()
	var stair_mesh = load("res://Assets/Meshes/Tiles/stairs.blend").instantiate()
	stairs.add_child(stair_mesh)
	add_child(stairs)
	mapgen.apply_shader(stairs)
	stairs.position.x = xpos
	stairs.position.z = ypos
	stairs.type = stairs.Kind.STAIRDOWN
	#TODO: store last room in extra grid list and import/export

func create_door(xpos, ypos, zpos, gridpos, _keyid=0):
	var door_file = preload("res://Assets/Templates/interactable.tscn")
	var door = door_file.instantiate()
	var door_mesh = load("res://Assets/Meshes/Interactables/door.blend").instantiate()
	add_child(door)
	door.add_child(door_mesh)
	mapgen.apply_shader(door)
	door.keyid = _keyid
	door.position.x = xpos
	door.position.y = ypos
	door.position.z = zpos
	door.contents = gridpos
	door.type = door.Kind.DOOR
	door.useSfx = load("res://Assets/Sounds/chest_opn.wav")
	return door

func create_container(droplist, xpos, ypos, zpos, _keyid=0):
	var chest_file = preload("res://Assets/Templates/interactable.tscn")
	var chest = chest_file.instantiate()
	var chest_mesh = load("res://Assets/Meshes/Interactables/chest_full.blend").instantiate()
	add_child(chest)
	chest.add_child(chest_mesh)
	chest.type = chest.Kind.CHEST
	chest.keyid = _keyid
	chest.value = droplist
	if chest.value.size() == 0:
		chest.active = true
		chest.get_child(0).queue_free()
		var chest_mesh2 = load("res://Assets/Meshes/Interactables/chest_empty.blend").instantiate()
		chest.add_child(chest_mesh2)
	else:
		chest.roll_contents()
	mapgen.apply_shader(chest)
	chest.position.x = xpos
	chest.position.y = ypos
	chest.position.z = zpos
	chest.useSfx = load("res://Assets/Sounds/chest.wav")
	return chest

func drop(droplist, xpos, ypos, zpos):
	var mob_file = preload("res://Assets/Templates/creature.tscn")
	var mob = mob_file.instantiate()
	mob.tex_idle = "res://Assets/Textures/itemdrop.png"
	mob.tex_run1 = "res://Assets/Textures/itemdrop.png"
	mob.tex_run2 = "res://Assets/Textures/itemdrop.png"
	mob.tex_wind = "res://Assets/Textures/itemdrop.png"
	mob.tex_strike = "res://Assets/Textures/itemdrop.png"
	mob.tex_hit = "res://Assets/Textures/itemdrop.png"
	mob.tex_dead = "res://Assets/Textures/itemdrop.png"
	mob.state = mob.State.DEAD
	mob.potentialdrops = droplist
	mob.roll_possessions()
	add_child(mob)
	mob.position.x = xpos
	mob.position.y = ypos + (float(load(mob.tex_idle).get_height()) / 200.0)
	mob.position.z = zpos
	return mob

func spawn(template_mob:Creature, xpos, ypos, zpos):
	var mob_file = preload("res://Assets/Templates/creature.tscn")
	var mob = mob_file.instantiate()
	mob.mobname = template_mob.mobname
	mob.level = template_mob.level
	mob.type = template_mob.type
	mob.STR = template_mob.STR
	mob.CON = template_mob.CON
	mob.DEX = template_mob.DEX
	mob.AGI = template_mob.AGI
	mob.INT = template_mob.INT
	mob.WIS = template_mob.WIS
	mob.CHA = template_mob.CHA
	mob.aggressive = template_mob.aggressive
	mob.dmgA = template_mob.dmgA
	mob.dmgB = template_mob.dmgB
	mob.dmgC = template_mob.dmgC
	mob.armor = template_mob.armor
	mob.tex_idle = "res://Assets/Textures/Mobs/" + template_mob.mobname + "/" + template_mob.mobname + "_idle.png"
	mob.tex_run1 =  "res://Assets/Textures/Mobs/" + template_mob.mobname + "/" + template_mob.mobname + "_run1.png"
	mob.tex_run2 =  "res://Assets/Textures/Mobs/" + template_mob.mobname + "/" + template_mob.mobname + "_run2.png"
	mob.tex_wind =  "res://Assets/Textures/Mobs/" + template_mob.mobname + "/" + template_mob.mobname + "_wind.png"
	mob.tex_strike =  "res://Assets/Textures/Mobs/" + template_mob.mobname + "/" + template_mob.mobname + "_strike.png"
	mob.tex_hit =  "res://Assets/Textures/Mobs/" + template_mob.mobname + "/" + template_mob.mobname + "_hit.png"
	mob.tex_dead =  "res://Assets/Textures/Mobs/" + template_mob.mobname + "/" + template_mob.mobname + "_dead.png"
	mob.potentialdrops = template_mob.drops
	mob.roll_possessions()
	add_child(mob)
	mob.position.x = xpos
	mob.position.y = ypos + (float(load(mob.tex_idle).get_height()) / 200.0)
	mob.position.z = zpos
	mob.spawnx = xpos
	mob.spawny = ypos + (float(load(mob.tex_idle).get_height()) / 200.0)
	mob.spawnz = zpos
	return mob

func _ready():
	pass
	#create_container([[[1], 100], [[2], 50]], 3, 0, 10)
	#spawn(goblin, 0, 0, -18)
	#drop([[lg_lt_weapons, 100], [lg_lt_armors, 100], [lg_lt_consumes, 100]], 10, 0, 0)
