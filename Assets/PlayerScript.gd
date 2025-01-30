extends "Scripts/StatScript.gd"

enum Race{
	HUMAN, DWARF, SUNELF, FEYELF, HALFELF, DROW, HALFFOOT, GNOME,
	# TODO: finish enums
}

func _ready():
	# TODO: fix debug values to scale off enum
	
	max_hp = 100
	cur_hp = 100
	
	max_mp = 100
	cur_mp = 100
	
	max_sp = 100
	cur_sp = 100
