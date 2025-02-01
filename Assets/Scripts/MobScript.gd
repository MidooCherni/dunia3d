extends Sprite3D

#	tip: a creature will always load their own palette using their mobname

enum Type{
	ANIMAL, CONSTRUCT, CRYPTID, DRAGON, ELEMENTAL,
	FIEND, HUMANOID, SPIRIT, UNDEAD,
	DEBUG
}

enum State{
	IDLE, AGGRO, CHASING, WINDING, RECOVERING, STUNNED, DEAD
}

@onready var player = get_node("../../Player")
@onready var playerStats = get_node("../../Player/PlayerScripting")
@onready var paincode = get_node("../../UI/Static/Pain")
var mobname = "debugman"
var state = State.IDLE
var oldState = State.AGGRO
var aggressive = false
var attacktimer = 0
var attacktimerMax = 15
var freezetimer = 0
var freezetimerMax = 10

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
	
func _process(delta):
	# check in aggro range and chase player
	match state:
		State.AGGRO:
			if global_position.distance_to(player.global_position) <= 10.0:
				# TODO: check not rooted or stunned
				state = State.CHASING
		State.CHASING:
			if int(global_position.distance_to(player.global_position)) % 2 == 0:
				texture = _tex_run1
			else:
				texture = _tex_run2
			if global_position.distance_to(player.global_position) > 2.0:
				# TODO: more sophisticated pathfinding algorithm
				var playerpos = Vector3(player.global_position.x, \
					myheight+player.global_position.y, player.global_position.z)
				global_position = global_position.move_toward(playerpos, delta * (float(AGI)/2))
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
	
	# ensure hp never goes beyond cap
	if cur_hp > max_hp: cur_hp = max_hp
	if cur_mp > max_mp: cur_mp = max_mp
	if cur_sp > max_sp: cur_sp = max_sp
	if cur_hp < 0: cur_hp = 0
	if cur_mp < 0: cur_mp = 0
	if cur_sp < 0: cur_sp = 0
	pass
