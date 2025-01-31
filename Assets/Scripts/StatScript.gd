extends Node

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

@onready var STR = 10
@onready var CON = 10
@onready var DEX = 10
@onready var AGI = 10
@onready var INT = 10
@onready var WIS = 10
@onready var CHA = 10

@onready var max_hp = 1
@onready var cur_hp = 1

@onready var max_mp = 0
@onready var cur_mp = 0

@onready var max_sp = 1
@onready var cur_sp = 1

@onready var race = Race.DEBUG
@onready var job = Class.DEBUG
	
func _process(_delta):
	# ensure hp never goes beyond cap
	if cur_hp > max_hp: cur_hp = max_hp
	if cur_mp > max_mp: cur_mp = max_mp
	if cur_sp > max_sp: cur_sp = max_sp
	if cur_hp < 0: cur_hp = 0
	if cur_mp < 0: cur_mp = 0
	if cur_sp < 0: cur_sp = 0
	pass
