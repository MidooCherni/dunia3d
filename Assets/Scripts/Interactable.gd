extends Node3D

enum Kind{
	NULL, CHEST, DOOR, STAIRDOWN, GATE, SPELLTRIGGER
}

var rng = RandomNumberGenerator.new()

var type = Kind.NULL
var active = false
var keyid = 0

var value = []
var contents = []

var useSfx = ""

func roll_contents():
	if value.size() == 0 or type != Kind.CHEST: return
	for loot_table in value:
		var dice = rng.randi_range(0, 100)
		if dice <= loot_table[1]:
			var dice2 = rng.randi_range(0, loot_table[0].size()-1)
			contents.append(loot_table[0][dice2])

func _physics_process(_delta):
	if type == Kind.DOOR and active and value[0] > 0:
		rotate_y(deg_to_rad(2))
		value[0] -= 2
