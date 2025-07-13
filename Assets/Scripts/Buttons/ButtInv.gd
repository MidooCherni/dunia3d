extends Button

@onready var menu = $".."
@onready var invhandler = $"../FrameInventory/InvButtCont"

func _pressed():
	menu.window = menu.WindowType.INV
	menu.buttinv.visible = true
	menu.buttinv.self_modulate.a = 0.5
	menu.buttchar.visible = true
	menu.buttchar.self_modulate.a = 1.0
	menu.buttskills.visible = true
	menu.buttskills.self_modulate.a = 1.0
	menu.frameinv.visible = true
	menu.framechar.visible = false
	menu.frameskills.visible = false
	invhandler.render()
