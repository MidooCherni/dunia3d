extends Sprite3D

#	tip: a creature will always load their own palette using their mobname

enum Type{
	ANIMAL, CONSTRUCT, CRYPTID, DRAGON, ELEMENTAL,
	FIEND, HUMANOID, SPIRIT, UNDEAD,
	DEBUG
}

enum State{
	IDLE, DEAD, CHASING, WINDING, RECOVERING, STUNNED, ASLEEP, AGGRO
}

@onready var player = get_node("../../Player")
@onready var playerStats = get_node("../../Player/PlayerScripting")
@onready var paincode = get_node("../../UI/Static/Pain")
@onready var mapgen = get_node("../..")
var mobname = "debugman"
var state = State.IDLE
var oldState = State.AGGRO
var aggressive = false
var last_player_pos = null
var attacktimer = 0
var attacktimerMax = 15
var freezetimer = 0
var freezetimerMax = 10
var deathtimer = 30

var potentialdrops = []
var contents = []

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

var max_sp = 100
var cur_sp = 100

var dmgA = 0
var dmgB = 0
var dmgC = 0

var armor = 0

var type = Type.DEBUG

var tex_idle
var tex_run1
var tex_run2
var tex_wind
var tex_strike
var tex_hit
var tex_dead

var _tex_idle
var _tex_run1
var _tex_run2
var _tex_wind
var _tex_strike
var _tex_hit
var _tex_dead

var myheight

var rng = RandomNumberGenerator.new()

func roll_possessions():
	if potentialdrops.size() == 0: return
	for loot_table in potentialdrops:
		var dice = rng.randi_range(0, 100)
		if dice <= loot_table[1]:
			var dice2 = rng.randi_range(0, loot_table[0].size()-1)
			contents.append(loot_table[0][dice2])

#pathfinding code
func is_walkable(world_x, world_y):
	var x = int(world_x / 2)
	var y = int(world_y / 2)
	if x < 0 or x >= mapgen.FLOOR_MAX_TILES or y < 0 or y >= mapgen.FLOOR_MAX_TILES:
		return false
	return mapgen.grid[x][y] in ['|', '.', '-']

func get_neighbors(world_pos):
	var dirs = [Vector2(0, -2), Vector2(0, 2), Vector2(-2, 0), Vector2(2, 0)]
	var neighbors = []
	for dir in dirs:
		var new_pos = world_pos + dir
		if is_walkable(new_pos.x, new_pos.y):
			neighbors.append(new_pos)
	return neighbors

func find_path(start_world, goal_world):
	var frontier = []
	var came_from = {}
	frontier.append(start_world)
	came_from[start_world] = null
	while frontier.size() > 0:
		var current = frontier.pop_front()
		if current == goal_world:
			break
		for next in get_neighbors(current):
			if not came_from.has(next):
				frontier.append(next)
				came_from[next] = current
	var path = []
	var current = goal_world
	while current != null:
		path.insert(0, current)
		current = came_from.get(current, null)
	if path.size() > 0 and path[0] == start_world:
		path.remove_at(0)
	return path

func has_line_of_sight(wx0, wy0, wx1, wy1):
	var x0 = int(wx0 / 2)
	var y0 = int(wy0 / 2)
	var x1 = int(wx1 / 2)
	var y1 = int(wy1 / 2)
	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx = -1
	if x0 < x1: sx = 1
	var sy = -1
	if y0 < y1: sy = 1
	var err = dx - dy
	while true:
		if mapgen.grid[x0][y0] != '.':
			return false
		if x0 == x1 and y0 == y1:
			break
		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy
	return true
	
#etc
func _ready() -> void:
	_tex_idle = load(tex_idle)
	_tex_run1 = load(tex_run1)
	_tex_run2 = load(tex_run2)
	_tex_wind = load(tex_wind)
	_tex_strike = load(tex_strike)
	_tex_hit = load(tex_hit)
	_tex_dead = load(tex_dead)
		
	# (CON modifier + 8) * level
	max_hp = (((CON / 2) - 5) + 8) * level
	cur_hp = max_hp
	if INT > 9:
		max_mp = (INT / 2) + (2 * level)
		cur_mp = max_mp
	texture = _tex_idle
	myheight = texture.get_height() / 200.0
	if aggressive: state = State.AGGRO
	
func _physics_process(delta):
	# check in aggro range and chase player
	match state:
		State.AGGRO:
			if global_position.distance_to(player.global_position) <= 20.0:
				# TODO: check not rooted or stunned
				if has_line_of_sight(position.x, position.z, player.tile(player.position.x), player.tile(player.position.z)):
					last_player_pos = [player.tile(player.position.x), player.tile(player.position.z)]
					state = State.CHASING
				elif last_player_pos != null:
					global_position = global_position.move_toward(Vector3(last_player_pos[0], player.position.y+myheight, last_player_pos[1]), delta * (float(AGI)/2))
		State.CHASING:
			if global_position.distance_to(player.global_position) > 2.0:
				var mpos = Vector2(position.x, position.z)
				var ppos = Vector2(player.tile(player.position.x), player.tile(player.position.z))
				if has_line_of_sight(position.x, position.z, player.tile(player.position.x), player.tile(player.position.z)):
					var path = find_path(mpos, ppos)
					if path.size() > 0:
						var next = path[0]
						global_position = global_position.move_toward(Vector3(next.x, player.position.y+myheight, next.y), delta * (float(AGI)/2))
				if int(global_position.distance_to(player.global_position)) % 2 == 0:
					texture = _tex_run1
				else:
					texture = _tex_run2
				# TODO: more sophisticated pathfinding algorithm
				#var playerpos = Vector3(player.global_position.x, \
				#	myheight+player.global_position.y, player.global_position.z)
				#global_position = global_position.move_toward(playerpos, delta * (float(AGI)/2))
			else:
				state = State.WINDING
		State.WINDING:
			texture = _tex_wind
			attacktimer += 1
			if attacktimer >= attacktimerMax:
				attacktimer = 0
				#	damage formula here
				if global_position.distance_to(player.global_position) <= 2.0:
					var damage = ((STR / 2) - 5) + (rng.randi_range(dmgA, dmgA*dmgB) + dmgC) - playerStats.armor
					if damage >= 0:
						playerStats.cur_hp -= damage
						paincode.alph = 1.0
				state = State.RECOVERING
		State.RECOVERING:
			texture = _tex_strike
			attacktimer += 1
			if attacktimer >= attacktimerMax*4:
				attacktimer = 0
				state = State.AGGRO
		State.STUNNED:
			texture = _tex_hit
			freezetimer += 1
			if freezetimer >= freezetimerMax:
				freezetimer = 0
				state = State.AGGRO
		State.DEAD:
			texture = _tex_dead
			if contents.size() == 0:
				deathtimer -= 1
				if deathtimer == 0: queue_free()
	
	# ensure hp never goes beyond cap
	if cur_hp > max_hp: cur_hp = max_hp
	if cur_mp > max_mp: cur_mp = max_mp
	if cur_sp > max_sp: cur_sp = max_sp
	if cur_hp < 0: cur_hp = 0
	if cur_mp < 0: cur_mp = 0
	if cur_sp < 0: cur_sp = 0
	pass
