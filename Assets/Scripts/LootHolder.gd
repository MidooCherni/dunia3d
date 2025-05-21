extends Control

@onready var playerScript = $"../../../../Player/PlayerScripting"

var cursor = 0
var contents = []
var lootboxes = []
var numinstances = 0

func resetcursor():
	cursor = 0
	contents = []
	for i in range(0, 5):
		lootboxes[i].get_child(2).visible = false

func _ready():
	lootboxes = get_children()
	
func _process(_delta: float) -> void:
	numinstances = contents.size()-1
	if contents.size() > 5: numinstances = 4
	for i in range(0, 5):
		if i <= numinstances:
			lootboxes[i].visible = true
			lootboxes[i].get_child(0).texture = load("res://Assets/Textures/Icons/" + playerScript.Inventory[contents[i]].icon)
			lootboxes[i].get_child(1).text = str(playerScript.Inventory[contents[i]].objname)
			lootboxes[i].get_child(2).visible = cursor == i
		else:
			lootboxes[i].visible = false

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ScrollUp") and visible:
		if cursor > 0: cursor -= 1
	if Input.is_action_just_pressed("ScrollDown") and visible:
		if cursor < 4 and cursor < contents.size()-1: cursor += 1
