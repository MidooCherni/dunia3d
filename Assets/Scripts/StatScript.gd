extends Node

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
	
func _process(_delta):
	# ensure hp never goes beyond cap
	if cur_hp > max_hp: cur_hp = max_hp
	pass
