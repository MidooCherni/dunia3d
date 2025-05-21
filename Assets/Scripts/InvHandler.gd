extends Control

@onready var playerScript = $"../../../../Player/PlayerScripting"
@onready var equipFather = $"../../EquipSlots/EquipSlotsGrp"
var nothing = load("res://Assets/Textures/Icons/empty.png")

var cursor_item_id = 0
var cursor_item_qty = 0

func render():
	var invindex = 0
	var icons = get_children()
	for index in playerScript.Inventory.size():
		if playerScript.Inventory[index].qty > 0:
			icons[invindex].itemid = index
			icons[invindex].icon = load("res://Assets/Textures/Icons/" + playerScript.Inventory[index].icon)
			icons[invindex].visible = true
			if playerScript.Inventory[index].qty > 1:
				icons[invindex].get_child(0).text = str(playerScript.Inventory[index].qty)
			else:
				icons[invindex].get_child(0).text = ""
			invindex += 1
	if invindex < 42:	# TODO: implement inventory pages
		for i in range(invindex, 42):
			icons[i].itemid = -1
			icons[i].icon = nothing
			icons[i].visible = false
	equipFather.render()

func _ready():
	render()
