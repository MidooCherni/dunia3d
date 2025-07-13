extends Button

@onready var menu = $".."
@onready var player = $"../../../Player/PlayerScripting"

func _pressed():
	menu.window = menu.WindowType.CHAR
	menu.buttinv.visible = true
	menu.buttinv.self_modulate.a = 1.0
	menu.buttchar.visible = true
	menu.buttchar.self_modulate.a = 0.5
	menu.buttskills.visible = true
	menu.buttskills.self_modulate.a = 1.0
	menu.frameinv.visible = false
	menu.framechar.visible = true
	menu.frameskills.visible = false
	
	var damstr = str(player.dmgA) + "d" + str(player.dmgB)
	var addition = player.dmgC + int((float((player.STR - 10)) / 2))
	if addition != 0:
		if addition > 0:
			damstr += "+" + str(addition)
		else:
			damstr += str(addition)
	menu.framechar.get_child(2).text = str(player.STR) + "\n\n" + \
		str(player.CON) + "\n\n" + \
		str(player.DEX) + "\n\n" + \
		str(player.AGI) + "\n\n" + \
		str(player.INT) + "\n\n" + \
		str(player.WIS) + "\n\n" + \
		str(player.CHA) + "\n"
	menu.framechar.get_child(3).text = damstr + "\n\n" + \
		str(player.armor) + "\n\n" + \
		str(player.fire_res) + "\n\n" + \
		str(player.frost_res) + "\n\n" + \
		str(player.shadow_res) + "\n\n" + \
		str(player.nature_res) + "\n\n" + \
		str(player.arcane_res) + "\n"
	menu.framechar.get_child(4).text = str(player.cur_hp) + "/" + str(player.max_hp) + "\n" + \
		str(player.cur_mp) + "/" + str(player.max_mp) + "\n" + \
		str(player.cur_sp) + "/" + str(player.max_sp)
