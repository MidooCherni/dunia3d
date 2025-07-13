extends "StatScript.gd"

#	inventory management
@onready var invhandler = $"../../UI/Menus/FrameInventory/InvButtCont"
@onready var audioplayer = $"../../UI/Menus/FrameInventory/InvSounds"
@onready var equipslots = $"../../UI/Menus/EquipSlots/EquipSlotsGrp"
@onready var weaponscript = $"../../UI/Weapon"
@onready var cam = $"../PlayerHeadPos/PlayerCamera"

var sfx_clothes = preload("res://Assets/Sounds/item/clothes.wav")
var sfx_drink = preload("res://Assets/Sounds/item/drink.ogg")
var sfx_book = preload("res://Assets/Sounds/item/readbook.wav")
var sfx_scroll = preload("res://Assets/Sounds/item/readscroll.wav")

var sfx_metalslide = preload("res://Assets/Sounds/combat/w_unsheathe.wav")
var sfx_sheathe = preload("res://Assets/Sounds/combat/w_sheathe.wav")

var rng = RandomNumberGenerator.new()

enum State{
	IDLE, STUNNED, ASLEEP, DEAD
}	# TODO: clean up useless dogshit enum i made for the express purpose of tricking spell code
var state = State.IDLE

	# ------------------------------------------------------------------------------------- MAGIC
enum EffectType{
	NULL, HEALING, DAMAGE,
	PROTECTION, RESTOREBODY, RESTOREMIND, CUREPOIS, CUREDIS,
	INFRAVIS, TELEPATHY, WATERBREATH,
	SPEED, SLOW, HEROISM, GENIUS, REGENHP, CLARITY, CONCENT, 
	RESISTALL, FIRES, FRRES, NATRES, SHADRES, 
	DERESISTALL, DEFIRES, DEFRRES, DENATRES, DESHADRES, 
	WEAKNESS, SILENCE, MUTATION, CUREMUT,
	POISON, BLIND, CONFU, PARA, SLEEP, FOG, ROOT, STUN,
	POLYMORPH, MINDCTRL, SUMMON, MAP, SENSEOBJ, SENSEPPL, IDENTIFY,
	CURSE, UNCURSE, BLINK, TELE, FLY, DISPEL
}
enum Element{
	ARCANE, FIRE, FROST, NATURE, LIGHTNING, HOLY, SHADOW, SLICE, BLUNT, PIERCE
}
enum Tar{
	SELF, TOUCH, HITSCAN, PROJ, SCREEN, PBAE, TARAE
}
class Effect:		# TODO: FIGURE OUT A SYSTEM. MANA COST? MATS? FATIGUE?
	var name = ""
	var effect = EffectType.NULL
	var element = Element.ARCANE
	var tartype = Tar.SELF
	var magnitude = 0
	var duration = 0
	var description = ""
	func _init(_name, _effecttype, _element, _tartype, _magnitude, _duration, _desc):
		self.name = _name
		self.effect = _effecttype
		self.element = _element
		self.tartype = _tartype
		self.magnitude = _magnitude
		self.duration = _duration
		self.description = _desc
class Spell:
	var name = ""
	var effectlist = []
	var effectNum = 0
	var spellrank = 0
	func _init(_name, _effectlist, _effectnum, _spellrank):
		self.name = _name
		self.effectlist = _effectlist
		self.effectNum = _effectnum
		self.spellrank = _spellrank
var Spells: Array[Spell] = []

	# ------------------------------------------------------------------------------------- ITEMS
enum ItemType{
	WEAPON, ARMOR, CONSUMABLE, REAGENT, TOOL, JUNK
}
enum Subtype{
	NONE, ONEAXE, ONEBLUNT, ONESLASH, ONEPIERCE, TWOAXE, TWOBLUNT, TWOSLASH, TWOPIERCE, THROWN, RANGE, 
	LIGHT, MEDIUM, HEAVY, RING, OFFHAND, HEAD, NECK, BACK, HANDS, WAIST, FEET, AMMO,
	POTION, SCROLL, BOOK, WAND, HERB, GEM, METAL
}
class Item:
	var qty = 0
	var icon = ""
	var objname = ""
	var type = ItemType.JUNK
	var subtype = Subtype.NONE
	var description = ""
	var weight = 0
	var value = 0
	var dmg = [0, 0, 0]		# armor, agicap, spellaura
	var stats = [0, 0, 0, 0, 0, 0, 0]
	var resists = [0, 0, 0, 0, 0]
	var onUseSpell = null
	func _init(_ic, _n, _t, _st, _desc, _wei, _val, _d=[0, 0, 0], _sta=[0, 0, 0, 0, 0, 0, 0], _res=[0, 0, 0, 0, 0], _onu=null):
		self.qty = 0
		self.icon = _ic
		self.objname = _n
		self.type = _t
		self.subtype = _st
		self.description = _d
		self.weight = _wei
		self.value = _val
		self.dmg = _d
		self.stats = _sta
		self.resists = _res
		self.onUseSpell = _onu

func get_race_dice():
	match race:
		Race.GNOME:
			return 4
		Race.GOBLIN, Race.HALFFOOT:
			return 5
		Race.SUNELF, Race.LUNARIAN, Race.LEIJON:
			return 6
		Race.HUMAN, Race.DROW, Race.HALFELF, Race.VYKOI, Race.SATYR, Race.APEKIN:
			return 7
		Race.DWARF, Race.FEYELF, Race.CENTAUR:
			return 8
		Race.TROLL, Race.ORC, Race.MINOTAUR:
			return 9
		Race.DRAGONKIN:
			return 10
		Race.OGRE:
			return 12
		_:
			return 8

var Inventory: Array[Item] = []

func wear_item(itemid):
	var slotid = -1
	if Inventory[itemid].type == ItemType.WEAPON:
		if Inventory[itemid].subtype in [Subtype.TWOAXE, Subtype.TWOBLUNT, Subtype.TWOSLASH, Subtype.TWOPIERCE, Subtype.RANGE]:
			if equipslots.get_child(4).itemid != -1: remove_worn(4)
		slotid = 0
	elif Inventory[itemid].type == ItemType.ARMOR:
		match Inventory[itemid].subtype:
			Subtype.LIGHT, Subtype.MEDIUM, Subtype.HEAVY:
				slotid = 1
			Subtype.RING:
				if equipslots.get_child(2).itemid == -1:
					slotid = 2
				else:
					remove_worn(3)
					slotid = 3
			_:
				slotid = (Inventory[itemid].subtype)-11
	else:
		print("ERROR: trying to wear unwearable item")
	if slotid == -1:
		print("ERROR: trying to wear unwearable item")
	else:
		worn_items[slotid] = itemid
		if equipslots.get_child(slotid).itemid != -1:
			remove_worn(slotid)
		equipslots.get_child(slotid).icon = load("res://Assets/Textures/Icons/" + Inventory[itemid].icon)
		equipslots.get_child(slotid).itemid = itemid
			# 	modify stats accordingly
		STR += Inventory[itemid].stats[0]
		max_hp -= ((CON / 2) - 5) * level
		CON += Inventory[itemid].stats[1]
		max_hp += ((CON / 2) - 5) * level
		if cur_hp > max_hp: cur_hp = max_hp
		DEX += Inventory[itemid].stats[2]
		AGI += Inventory[itemid].stats[3]
		INT += Inventory[itemid].stats[4]
		max_mp = (INT / 2) + (2 * level)
		WIS += Inventory[itemid].stats[5]
		CHA += Inventory[itemid].stats[6]
		fire_res += Inventory[itemid].resists[0]
		frost_res += Inventory[itemid].resists[1]
		shadow_res += Inventory[itemid].resists[2]
		nature_res += Inventory[itemid].resists[3]
		arcane_res += Inventory[itemid].resists[4]
		if Inventory[itemid].type == ItemType.WEAPON:
			dmgA = Inventory[itemid].dmg[0]
			dmgB = Inventory[itemid].dmg[1]
			dmgC = Inventory[itemid].dmg[2]
			var wname = Inventory[itemid].icon.trim_suffix(".png")
			weaponscript.tex_idle = load("res://Assets/Textures/Weapons/" + wname + "1.png")
			weaponscript.tex_pull = load("res://Assets/Textures/Weapons/" + wname + "2.png")
			weaponscript.tex_cooldown = load("res://Assets/Textures/Weapons/" + wname + "3.png")
			match Inventory[itemid].subtype:
				Subtype.ONEBLUNT, Subtype.TWOBLUNT:
					weaponscript.hit_type = 1
				Subtype.ONEAXE, Subtype.ONESLASH, Subtype.ONEPIERCE, Subtype.TWOAXE, Subtype.TWOSLASH, Subtype.TWOPIERCE, Subtype.THROWN:
					weaponscript.hit_type = 2
				Subtype.RANGE:
					weaponscript.hit_type = 3
			weaponscript.texture = weaponscript.tex_idle
		else:
			armor = Inventory[itemid].dmg[0]
			agicap = Inventory[itemid].dmg[1]
			#	TODO: add spell aura to player
			#	TODO: add onusespell to spellbook
			#	TODO: weight

func remove_worn(slotnum):
	if equipslots.get_child(slotnum).itemid == -1:
		print("ERROR: tried to remove from empty slot")
	else:
		worn_items[slotnum] = 0
		var itemcode = equipslots.get_child(slotnum).itemid
		match Inventory[itemcode].type:
			ItemType.WEAPON:	
				match Inventory[itemcode].subtype:
					Subtype.ONEBLUNT, Subtype.TWOBLUNT, Subtype.RANGE, Subtype.AMMO:
						audioplayer.stream = sfx_sheathe
						audioplayer.play()
					_:
						audioplayer.stream = sfx_metalslide
						audioplayer.play()
			ItemType.ARMOR:
				# match Inventory[itemid].subtype:	# TODO: metal wearing sounds
				audioplayer.stream = sfx_clothes
				audioplayer.play()
			# modify stats accordingly
		STR -= Inventory[itemcode].stats[0]
		max_hp -= ((CON / 2) - 5) * level
		CON -= Inventory[itemcode].stats[1]
		max_hp += ((CON / 2) - 5) * level
		if cur_hp > max_hp: cur_hp = max_hp
		DEX -= Inventory[itemcode].stats[2]
		AGI -= Inventory[itemcode].stats[3]
		INT -= Inventory[itemcode].stats[4]
		max_mp = (INT / 2) + (2 * level)
		WIS -= Inventory[itemcode].stats[5]
		CHA -= Inventory[itemcode].stats[6]
		fire_res -= Inventory[itemcode].resists[0]
		frost_res -= Inventory[itemcode].resists[1]
		shadow_res -= Inventory[itemcode].resists[2]
		nature_res -= Inventory[itemcode].resists[3]
		arcane_res -= Inventory[itemcode].resists[4]
		if Inventory[itemcode].type == ItemType.WEAPON:
			dmgA = 1
			dmgB = 4
			dmgC = 0
			weaponscript.tex_idle = load("res://Assets/Textures/Weapons/fist1.png")
			weaponscript.tex_pull = load("res://Assets/Textures/Weapons/fist2.png")
			weaponscript.tex_cooldown = load("res://Assets/Textures/Weapons/fist3.png")
			weaponscript.hit_type = 0
			weaponscript.texture = weaponscript.tex_idle
		else:
			armor = Inventory[itemcode].dmg[0]
			agicap = 0
			#	TODO: add spell aura to player
			#	TODO: add onusespell to spellbook
			#	TODO: weight
		Inventory[equipslots.get_child(slotnum).itemid].qty += 1	# TODO: find a better way to do this
		equipslots.get_child(slotnum).icon = load("res://Assets/Textures/Icons/empty.png")
		equipslots.get_child(slotnum).itemid = -1

func resolve_spell_effects(spellobj):
	if spellobj == null:
		return
	var targets = []
	for i in range(0, spellobj.effectNum):
		match spellobj.effectlist[i].tartype:
			Tar.SELF:
				targets = [self]
			Tar.TOUCH, Tar.HITSCAN:
				var attack_range = 3
				if spellobj.effectlist[i].tartype == Tar.HITSCAN:
					attack_range = 255
				var space = cam.get_world_3d().direct_space_state
				var query = PhysicsRayQueryParameters3D.create(cam.global_position, \
					cam.global_position - cam.global_transform.basis.z * attack_range)
				var collision = space.intersect_ray(query)
				if collision and collision.collider.name == "CreatureRigidbody":
					#	TODO: damage function
					var mob = collision.collider.get_parent()
					if mob.state != mob.State.DEAD:
						targets = [mob]
			Tar.PROJ:	# TODO: finish aoes
				pass
			Tar.SCREEN:
				pass
			Tar.PBAE:
				pass
			Tar.TARAE:
				pass
		for tar in targets:
			match spellobj.effectlist[i].effect:
				EffectType.HEALING:
					tar.cur_hp += spellobj.effectlist[i].magnitude
					if tar.cur_hp > tar.max_hp: tar.cur_hp = tar.max_hp	
				EffectType.DAMAGE:
					#	TODO: account for resistance type
					if tar.state != tar.State.DEAD:
						var damage = spellobj.effectlist[i].magnitude
						if damage >= 0:
							tar.cur_hp -= damage
							if tar.cur_hp <= 0:
								tar.state = tar.State.DEAD
							else:
								tar.state = tar.State.STUNNED
				# TODO: more shit
				_:
					print("ERROR: unsupported spell effect")

func use_item(itemid):
	if itemid >= 0 and itemid < Inventory.size():
		# TODO: item usage stat requirement
		match Inventory[itemid].type:
			ItemType.WEAPON:
				match Inventory[itemid].subtype:
					Subtype.ONEBLUNT, Subtype.TWOBLUNT, Subtype.RANGE, Subtype.AMMO:
						audioplayer.stream = sfx_sheathe
						audioplayer.play()
					_:
						audioplayer.stream = sfx_metalslide
						audioplayer.play()
				wear_item(itemid)
				Inventory[itemid].qty -= 1		# 	TODO: find a better way to do this
			ItemType.ARMOR:
				# match Inventory[itemid].subtype:	# TODO: metal wearing sounds
				audioplayer.stream = sfx_clothes
				audioplayer.play()
				wear_item(itemid)
				Inventory[itemid].qty -= 1
			ItemType.CONSUMABLE:
				match Inventory[itemid].subtype:
					Subtype.POTION:
						audioplayer.stream = sfx_drink
						audioplayer.play()
					Subtype.SCROLL:
						audioplayer.stream = sfx_scroll
						audioplayer.play()
					Subtype.BOOK:
						audioplayer.stream = sfx_book
						audioplayer.play()
					Subtype.WAND, Subtype.HERB, Subtype.GEM, Subtype.METAL:		# TODO: REAL SOUNDS
						audioplayer.stream = sfx_clothes
						audioplayer.play()
				if (Inventory[itemid].onUseSpell == null):
					print("ERROR: tried to use a spell with an invalid spellid")
				else:
					resolve_spell_effects(Inventory[itemid].onUseSpell)	# casts spell by object ref
				Inventory[itemid].qty -= 1
	else:
		print("ERROR: invalid item id")
	invhandler.render()

func _ready():	# TODO: use database system to import items
	#			spell list begins here
	var potionheal = Spell.new("potionheal", [Effect.new("potion heal", EffectType.HEALING, Element.NATURE, Tar.SELF, 10, 0, "heals for 10 points")], 1, 0)
	Spells.append(potionheal)
	
	#			item list begins here	name, plural, type, subtype, desc, weight, value, damage[], resists[], onuse spell
	Inventory.append(Item.new("coin.png", "a gold piece", ItemType.REAGENT, Subtype.METAL, "Standard-issue Hylonian coins-- though outside of human lands, their worth is only as much as you could convince a potential trader of.", 0, 1))
	Inventory.append(Item.new("book.png", "Book of Debug", ItemType.CONSUMABLE, Subtype.BOOK, "awesome godmode book grraahh.", 0, 0))
	Inventory.append(Item.new("scroll.png", "declaration of gyattdependence", ItemType.CONSUMABLE, Subtype.SCROLL, "huh", 0, 1))
	Inventory.append(Item.new("lean.png", "a sip of lean", ItemType.CONSUMABLE, Subtype.POTION, "purrp", 0, 1))
	Inventory.append(Item.new("rock.png", "a rock", ItemType.WEAPON, Subtype.TWOBLUNT, "to kill people with", 0, 1, [2, 8, 0], [1, 1, 1, 1, 1, 1, 1], [3, 3 ,3 ,3 ,3]))
	Inventory.append(Item.new("rock.png", "rock hat", ItemType.ARMOR, Subtype.HEAD, "to wear", 0, 1, [2, 8, 0], [1, 1, 1, 1, 1, 1, 1], [3, 3 ,3 ,3 ,3]))
	Inventory.append(Item.new("rock.png", "offhand test rock", ItemType.ARMOR, Subtype.OFFHAND, "ambidexterity test", 0, 1))
	Inventory.append(Item.new("bow.png", "test bow", ItemType.WEAPON, Subtype.RANGE, "shoots gay ass little arrows etc.", 0, 2, [1, 6, 0]))
	Inventory.append(Item.new("redlean.png", "potion of healean", ItemType.CONSUMABLE, Subtype.POTION, "heals you", 0, 0, 0, 0, 0, potionheal))
	Inventory.append(Item.new("testsword.png", "test sword", ItemType.WEAPON, Subtype.ONESLASH, "slash slash", 0, 1, [1, 10, 0], [0, 0, 0, 0, 0, 0, 0], [0, 0 ,0 ,0 ,0]))
	#			item list ends here
	Inventory[0].qty = 43 # TODO debug inventory, remove later
	Inventory[9].qty = 1

	# TODO: fix debug values to scale off enum
	var per_level_hp = 1
	#if job in [Class.FIGHTER, Class.SAVAGE, Class.MONK, Class.SPELLSWORD, Class.INQUISITOR, Class.TEMPLAR, Class.STORMLORD, Class.WARLORD, Class.MOONKNIGHT, Class.REAPER]:
	per_level_hp = get_race_dice()
	#else:
	#		per_level_hp = rng.randi_range(1, get_race_dice())
	max_hp = (per_level_hp + ((CON / 2) - 5)) * level
	cur_hp = max_hp
	max_mp = (INT / 2) + (2 * level)
	cur_mp = max_mp
	max_sp = 100
	cur_sp = 100
