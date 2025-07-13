extends Button

@onready var invhandler = $".."
@onready var playerscript = $"../../../../../Player/PlayerScripting"
@onready var textlabel = $"../../../CursorLabel"
@onready var menuhandler = $"../../.."
var itemid = -1
var is_being_hovered = false

func _pressed():
	is_being_hovered = false
	if get_parent().name == "InvButtCont":
		playerscript.use_item(itemid)
		itemid = -1
	else:
		playerscript.remove_worn(get_index())

func _process(_delta):
	if itemid != -1:
		if menuhandler.window == menuhandler.WindowType.INV:
			if get_viewport().get_mouse_position().x >= global_position.x and get_viewport().get_mouse_position().y >= global_position.y and\
			get_viewport().get_mouse_position().x <= global_position.x+48 and get_viewport().get_mouse_position().y <= global_position.y+48:
				textlabel.set_global_position(get_viewport().get_mouse_position())
				textlabel.text = "  " + playerscript.Inventory[itemid].objname
				is_being_hovered = true
			else:
				is_being_hovered = false
		else:
			is_being_hovered = false
