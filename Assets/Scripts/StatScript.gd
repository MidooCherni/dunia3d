extends Node

#	base player stat code.. might say fuck it and merge it into PlayerScript

enum Race{
	HUMAN, DWARF, SUNELF, FEYELF, HALFELF, DROW, HALFFOOT, GNOME,
	LUNARIAN, SATYR, DRAGONKIN, CENTAUR, MINOTAUR, LEIJON, VYKOI, APEKIN,
	TROLL, OGRE, GOBLIN, ORC, DEBUG
}

enum Class{
	FIGHTER, SAVAGE, MONK, SPELLSWORD,
	INQUISITOR, TEMPLAR, STORMLORD, WARLORD, MOONKNIGHT, REAPER,
	WIZARD, WITCH, SORCERER, NECROMANCER,
	MARKSMAN, BEASTLORD, LACERATOR, ENGINEER,
	THIEF, ASSASSIN, PIRATE, BARD,
	BISHOP, CULTIST, WARSAGE, DRUID,
	ARCHEOLOGIST, ARTISAN, HEALER, MERCHANT,
	NPC, DEBUG
}

var charname = "charname"

var STR = 10
var CON = 10
var DEX = 10
var AGI = 10
var INT = 10
var WIS = 10
var CHA = 10

var fire_res = 0
var frost_res = 0
var shadow_res = 0
var nature_res = 0
var arcane_res = 0

var level = 1

var max_hp = 1
var cur_hp = 1

var max_mp = 0
var cur_mp = 0

var equipped_spell_id = 0

var max_slots = [0, 0, 0, 0, 0, 0, 0, 0, 0]
var cur_slots = [0, 0, 0, 0, 0, 0, 0, 0, 0]

var max_sp = 1
var cur_sp = 1

var armor = 0
var agicap = 0

var dmgA = 1
var dmgB = 4
var dmgC = 0

var race = Race.DEBUG
var job = Class.DEBUG

var worn_items = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

# str
var skillAthletics = 0
# con
var skillConcentration = 0
var skillCraftSmithing = 0
# dex
var skillMusicianship = 0
var skillCraftJewelcrafting = 0
var skillCraftLeatherworking = 0
var skillOpenLock = 0
var skillSleightofHand = 0
var skillCraftTraps = 0
var skillCraftWeaving = 0
# agi
var skillAcrobacy = 0
var skillPerformDance = 0
var skillEscape = 0
var skillHide = 0
var skillRide = 0
var skillMoveSilently = 0
# int
var skillCraftAlchemy = 0
var skillCraftCooking = 0
var skillDisableDevice = 0
var skillKnowledgeLore = 0
var skillKnowledgeNature = 0
var skillNurse = 0
var skillUseMagicDevice = 0
# wis
var skillHandleAnimal = 0
var skillJudge = 0
var skillListen = 0
var skillSearch = 0
# cha
var skillBluff = 0
var skillDiplomacy = 0
var skillIntimidate = 0
var skillPerform = 0

func _process(_delta):
	# ensure hp never goes beyond cap
	if cur_hp > max_hp: cur_hp = max_hp
	if cur_mp > max_mp: cur_mp = max_mp
	if cur_sp > max_sp: cur_sp = max_sp
	if cur_hp < 0: cur_hp = 0
	if cur_mp < 0: cur_mp = 0
	if cur_sp < 0: cur_sp = 0
	pass
