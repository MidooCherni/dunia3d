extends Control

@onready var playerScript = $"../../../../Player/PlayerScripting"
var nothing = load("res://Assets/Textures/Icons/empty.png")

var cursor_item_id = 0
var cursor_item_qty = 0

func render():
	for index in get_children().size():
		if get_child(index).itemid == -1:
			get_child(index).icon = nothing
			get_child(index).visible = false
		else:
			get_child(index).icon = load("res://Assets/Textures/Icons/" + playerScript.Inventory[get_child(index).itemid].icon)
			get_child(index).visible = true
func _ready():
	render()
