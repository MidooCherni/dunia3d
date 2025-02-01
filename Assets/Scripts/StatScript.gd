extends Node

#	base player stat code.. might say fuck it and merge it into PlayerScript

enum Race{
	HUMAN, DWARF, SUNELF, FEYELF, HALFELF, DROW, HALFFOOT, GNOME,
	LUNARIAN, SATYR, DRAGONKIN, CENTAUR, MINOTAUR, LEIJIN, VYKOI, APEKIN,
	TROLL, OGRE, GOBLIN, ORC,
	ANIMAL, CONSTRUCT, CRYPTID, DRAGON, ELEMENTAL,
	FIEND, HUMANOID, SPIRIT, UNDEAD,
	DEBUG
}

enum Class{
	FIGHTER, SAVAGE, MONK, SPELLSWORD,
	WIZARD, WITCH, SORCERER, NECROMANCER,
	INQUISITOR, TEMPLAR, STORMLORD, WARLORD, MOONKNIGHT, REAPER,
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

var level = 1

var max_hp = 1
var cur_hp = 1

var max_mp = 0
var cur_mp = 0

var max_sp = 1
var cur_sp = 1

var armor = 0

var dmgA = 1
var dmgB = 4
var dmgC = 0

var race = Race.DEBUG
var job = Class.DEBUG
	
func _process(_delta):
	# ensure hp never goes beyond cap
	if cur_hp > max_hp: cur_hp = max_hp
	if cur_mp > max_mp: cur_mp = max_mp
	if cur_sp > max_sp: cur_sp = max_sp
	if cur_hp < 0: cur_hp = 0
	if cur_mp < 0: cur_mp = 0
	if cur_sp < 0: cur_sp = 0
	pass
