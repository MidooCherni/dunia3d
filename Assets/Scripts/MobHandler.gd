extends Node3D

# contains mob dictionary, handles spawning

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
	func _init(_mn, _lev, _typ:Type, _s, _co, _d, _a, _i, _w, _ch, ag, _dA, _dB, _dC, _ar):
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

# 	creature dictionary begins here
var goblin = Creature.new("goblin", 1, Type.HUMANOID, 8, 10, 14, 13, 10, 8, 8, true, 1, 6, 2, 0)
# 	creature dictionary ends

func spawn(template_mob:Creature, xpos, ypos, zpos):
	var mob_file = preload("res://Assets/creature.tscn")
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
	add_child(mob)
	mob.position.x = xpos
	mob.position.y = ypos + (float(load(mob.tex_idle).get_height()) / 200.0)
	mob.position.z = zpos
	return mob

func _ready():
	spawn(goblin, 0, 0, -18)
