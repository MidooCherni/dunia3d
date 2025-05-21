extends Button

@onready var menu = $".."

func _pressed():
	menu.window = menu.WindowType.SKILLS
	menu.buttinv.visible = true
	menu.buttinv.self_modulate.a = 1.0
	menu.buttchar.visible = true
	menu.buttchar.self_modulate.a = 1.0
	menu.buttskills.visible = true
	menu.buttskills.self_modulate.a = 0.5
	menu.frameinv.visible = false
	menu.framechar.visible = true
