extends Node3D

@onready var world = $TileTree
@onready var interholder = $NPCTree
@onready var minimap = $UI/Map
@onready var p = $Player

const MAX_GEN_FAILURES = 100
const FLOOR_MAX_TILES = 64

var rng = RandomNumberGenerator.new()
var rooms = []
var grid = []
var level = 0

var tileshader = preload("res://Assets/Scripts/Shaders/spatial/standard/standard_opaque_repeating.gdshader")

var tiletextures = [
	preload("res://Assets/Meshes/Tiles/wallblock.blend"),
	preload("res://Assets/Meshes/Tiles/wallblockA.blend"),
	preload("res://Assets/Meshes/Tiles/wallblockB.blend"),
	preload("res://Assets/Meshes/Tiles/wallblockC.blend"),
	preload("res://Assets/Meshes/Tiles/wallblockD.blend"),
	preload("res://Assets/Meshes/Tiles/wallblockE.blend")
]

var doodads = [
	preload("res://Assets/Meshes/Doodads/barrelA.blend"),
	preload("res://Assets/Meshes/Doodads/barrelB.blend"),
	preload("res://Assets/Meshes/Doodads/barrelC.blend"),
	preload("res://Assets/Meshes/Doodads/barrelD.blend"),
	preload("res://Assets/Meshes/Doodads/barrelE.blend"),
	preload("res://Assets/Meshes/Doodads/crateA.blend"),
	preload("res://Assets/Meshes/Doodads/crateB.blend"),
	preload("res://Assets/Meshes/Doodads/crateC.blend"),
]

func load_from_file():
	var file = FileAccess.open("res://Assets/Scripts/Map/samplemap.txt", FileAccess.READ)
	var content = file.get_as_text()
	return content

func load_map(fileinfo):
	var linecounter = 0
	var numcounter = 0
	var tile = null
	var tile_instance = null
	for i in fileinfo:
		match i:
			'#':
				tile = preload("res://Assets/Meshes/Tiles/wallblock.blend")
				tile_instance = tile.instantiate()
				world.add_child(tile_instance)
				tile_instance.position.x = numcounter*2
				tile_instance.position.z = linecounter*2
			'.':
				gen_ground(numcounter, linecounter)
			'|':
				gen_ground(numcounter, linecounter)
				tile = preload("res://Assets/Meshes/Tiles/gate.blend")
				tile_instance = tile.instantiate()
				world.add_child(tile_instance)
				tile_instance.position.x = numcounter*2
				tile_instance.position.z = linecounter*2
				interholder.create_door(numcounter*2, 0, linecounter*2 + 0.75, [numcounter, linecounter])
			'-':
				gen_ground(numcounter, linecounter)
				tile = preload("res://Assets/Meshes/Tiles/gate.blend")
				tile_instance = tile.instantiate()
				world.add_child(tile_instance)
				tile_instance.position.x = numcounter*2
				tile_instance.position.z = linecounter*2
				tile_instance.set_rotation_degrees(Vector3(0, 90, 0))
				var door = interholder.create_door(numcounter*2 - 0.75, 0, linecounter*2, [numcounter, linecounter])
				door.set_rotation_degrees(Vector3(0, -90, 0))
			'@':
				gen_ground(numcounter, linecounter)
				$Player.global_position = Vector3(numcounter*2, 0.0, linecounter*2)
			'g':
				gen_ground(numcounter, linecounter)
				interholder.spawn(interholder.goblin, numcounter*2, 0, linecounter*2)
			'1':
				linecounter += 1
				numcounter = 0
				continue
		numcounter += 1

class Rect:
	var x = 0
	var y = 0
	var width = 0
	var height = 0
	func _init(_x, _y, _w, _h):
		self.x = _x
		self.y = _y
		self.width = _w
		self.height = _h
	func intersects(other):
		return not (
			self.x + self.width <= other.x or
			self.x >= other.x + other.width or
			self.y + self.height <= other.y or
			self.y >= other.y + other.height
		)
		
func apply_shader(_instance):
	pass
	#if instance is MeshInstance3D:
	#	var mesh = instance.mesh
	#	if mesh:
	#		var original_mat = mesh.surface_get_material(0)
	#		var tex = original_mat.albedo_texture
	#		var shader_material = ShaderMaterial.new()
	#		shader_material.shader = tileshader
	#		shader_material.set_shader_parameter("albedo_texture", tex)
	#		instance.set_surface_override_material(0, shader_material)
	#for child in instance.get_children():
	#	apply_shader(child)

func find_edges():
	for y in range(1, FLOOR_MAX_TILES-1):
		for x in range(1, FLOOR_MAX_TILES-1):
			# the most retarded surround check in human history
			if grid[x][y] == '.':
				if grid[x-1][y] == ' ' or grid[x-1][y-1] == ' ' or grid[x][y-1] == ' ' or grid[x+1][y] == ' ' or \
				grid[x+1][y+1] == ' ' or grid[x][y+1] == ' ' or grid[x-1][y+1] == ' ' or grid[x+1][y-1] == ' ':
					grid[x][y] = '#'

func create_corridors():
	for i in range(1, rooms.size()):
		var room_a = rooms[i - 1]
		var room_b = rooms[i]
		
		var center_a = Vector2(room_a.x + room_a.width / 2, room_a.y + room_a.height / 2).floor()
		var center_b = Vector2(room_b.x + room_b.width / 2, room_b.y + room_b.height / 2).floor()
		
		if rng.randi_range(0, 1) == 0:
			draw_horizontal_corridor(center_a.x, center_b.x, center_a.y)
			draw_vertical_corridor(center_a.y, center_b.y, center_b.x)
		else:
			draw_vertical_corridor(center_a.y, center_b.y, center_a.x)
			draw_horizontal_corridor(center_a.x, center_b.x, center_b.y)

func draw_horizontal_corridor(x1, x2, y):
	var doorsmade = 0
	for x in range(min(x1, x2), max(x1, x2) + 1):
		if grid[x][y] == '#' and doorsmade < 1 and grid[x][y-1] != '.' and grid[x][y+1] != '.':
			grid[x][y] = '|'
			doorsmade += 1
		elif grid[x][y] != '>':
			grid[x][y] = '.'

func draw_vertical_corridor(y1, y2, x):
	var doorsmade = 0
	for y in range(min(y1, y2), max(y1, y2) + 1):
		if grid[x][y] == '#' and doorsmade < 1 and grid[x-1][y] != '.' and grid[x+1][y] != '.':
			grid[x][y] = '-'
			doorsmade += 1
		elif grid[x][y] != '>':
			grid[x][y] = '.'

func generate_lights():
	var litchance
	for room in rooms:
		litchance = rng.randi_range(0, 3)
		if litchance != 0:
			interholder.spawn_light_source(room.x+(room.width/2), room.y+(room.height/2))

func convert_ascii():
	for i in FLOOR_MAX_TILES:
		grid.append([])
		for j in FLOOR_MAX_TILES:
			grid[i].append(' ')
	for room in rooms:
		for y in range(room.y, room.y+room.height):
			for x in range(room.x, room.x+room.width):
				if room == rooms[rooms.size()-1] and y == room.y+(room.height/2) and x == room.x+(room.width/2):
					grid[x][y] = '>'
				else:
					grid[x][y] = '.'

func generate_map():
	var current_attempt = 0
	var done_trying = false
	var num_rooms = rng.randi_range(5, 10)
	for i in range(0, num_rooms):
		current_attempt = 0
		done_trying = false
		while(!done_trying):
			var width = rng.randi_range(5, 15)
			var height = rng.randi_range(5, 15)
			var x = rng.randi_range(1, FLOOR_MAX_TILES-15)
			var y = rng.randi_range(1, FLOOR_MAX_TILES-15)
			var new_room = Rect.new(x, y, width, height)
			var intersects = false
			done_trying = false
			for other_room in rooms:
				if new_room.intersects(other_room): intersects = true
			if !intersects:
				rooms.append(new_room)
				done_trying = true
			current_attempt += 1
			if current_attempt > MAX_GEN_FAILURES:
				done_trying = true
	convert_ascii()
	find_edges()
	create_corridors()
	generate_lights()
	decorate()
	render_map()
	populate()

func gen_ground(posx, posy):
	var tile = null
	var tile_instance = null
	tile = preload("res://Assets/Meshes/Tiles/floorblock.blend")
	tile_instance = tile.instantiate()
	world.add_child(tile_instance)
	apply_shader(tile_instance)
	tile_instance.position.x = posx*2
	tile_instance.position.z = posy*2
	tile = preload("res://Assets/Meshes/Tiles/ceilingblock.blend")
	tile_instance = tile.instantiate()
	world.add_child(tile_instance)
	apply_shader(tile_instance)
	tile_instance.position.x = posx*2
	tile_instance.position.z = posy*2
	tile_instance.position.y = 1

func gen_ceiling(posx, posy):
	var tile = null
	var tile_instance = null
	tile = preload("res://Assets/Meshes/Tiles/ceilingblock.blend")
	tile_instance = tile.instantiate()
	world.add_child(tile_instance)
	apply_shader(tile_instance)
	tile_instance.position.x = posx*2
	tile_instance.position.z = posy*2
	tile_instance.position.y = 1

func decorate():
	var ran = 0
	var tile = null
	var tile_instance = null
	for y in range(1, FLOOR_MAX_TILES-1):
		for x in range(1, FLOOR_MAX_TILES-1):
			if grid[x][y] == '.':
				if (grid[x+1][y] == '#' and grid[x-1][y] == '.') or (grid[x-1][y] == '#' and grid[x+1][y] == '.') or \
				(grid[x][y-1] == '#' and grid[x][y+1] == '.') or (grid[x][y+1] == '#' and grid[x][y-1] == '.'):
					ran = randi_range(0, 4)
					if ran == 0:
						ran = randi_range(0, doodads.size()-1)
						tile = doodads[ran]
						tile_instance = tile.instantiate()
						world.add_child(tile_instance)
						apply_shader(tile_instance)
						tile_instance.position.x = x*2
						tile_instance.position.z = y*2

func populate():
	var ran = 0
	for room in rooms:
		if room != rooms[0]:
			for y in range(room.y+1, room.y+room.height-1):
				for x in range(room.x+1, room.x+room.width-1):
					ran = randi_range(0, 10)
					if ran == 0:	# TODO: RNG A CREATURE
						interholder.spawn(interholder.goblin, x*2, 0, y*2)
						print("spone a guy at " + str(x*2) + ", " + str(y*2))

func render_map():
	for y in range(0, FLOOR_MAX_TILES):
		for x in range(0, FLOOR_MAX_TILES):
			var i
			var tile = null
			var tile_instance = null
			i = grid[x][y]
			match i:
				'#', ' ':
					var tiletype = rng.randi_range(0, 50)
					tile = tiletextures[0]
					if tiletype == 0: tile = tiletextures[4]
					if tiletype == 1: tile = tiletextures[2]
					if tiletype in [2, 3]: tile = tiletextures[1]
					if tiletype in range(4, 18): tile = tiletextures[3]
					if tiletype in range(19,32): tile = tiletextures[5]
					tile_instance = tile.instantiate()
					world.add_child(tile_instance)
					apply_shader(tile_instance)
					tile_instance.position.x = x*2
					tile_instance.position.z = y*2
				'.':
					gen_ground(x, y)
				'|':
					gen_ground(x, y)
					tile = preload("res://Assets/Meshes/Tiles/gate.blend")
					tile_instance = tile.instantiate()
					world.add_child(tile_instance)
					apply_shader(tile_instance)
					tile_instance.position.x = x*2
					tile_instance.position.z = y*2
					if rng.randi_range(0, 1) == 0:
						interholder.create_door(x*2, 0, y*2 + 0.75, [x, y])
					else:
						grid[x][y] = '.'
				'-':
					gen_ground(x, y)
					tile = preload("res://Assets/Meshes/Tiles/gate.blend")
					tile_instance = tile.instantiate()
					world.add_child(tile_instance)
					apply_shader(tile_instance)
					tile_instance.position.x = x*2
					tile_instance.position.z = y*2
					tile_instance.set_rotation_degrees(Vector3(0, 90, 0))
					if rng.randi_range(0, 1) == 0:
						var door = interholder.create_door(x*2 - 0.75, 0, y*2, [x, y])
						door.set_rotation_degrees(Vector3(0, -90, 0))
					else:
						grid[x][y] = '.'
				'>':
					gen_ceiling(x, y)
					interholder.create_stairs(x*2, y*2)

func clear_map():
	grid = []
	rooms = []
	for thing in world.get_children():
		thing.queue_free()
	for unit in interholder.get_children():
		unit.queue_free()

func go_down():
	# TODO: difficulty calculation
	level += 1
	clear_map()
	generate_map()
	p.position.x = rooms[0].x*2 + rooms[0].width
	p.position.z = rooms[0].y*2 + rooms[0].height

# URGENT TODO: example
func _ready() -> void:
	#var mapinfo = load_from_file()
	#load_map(mapinfo)
	generate_map()
	p.position.x = rooms[0].x*2 + rooms[0].width
	p.position.z = rooms[0].y*2 + rooms[0].height

func _physics_process(_delta):
	minimap.draw_map(grid)
