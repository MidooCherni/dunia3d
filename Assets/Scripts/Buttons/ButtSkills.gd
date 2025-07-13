extends Button

@onready var menu = $".."
@onready var player = $"../../../Player/PlayerScripting"

func _pressed():
	menu.window = menu.WindowType.SKILLS
	menu.buttinv.visible = true
	menu.buttinv.self_modulate.a = 1.0
	menu.buttchar.visible = true
	menu.buttchar.self_modulate.a = 1.0
	menu.buttskills.visible = true
	menu.buttskills.self_modulate.a = 0.5
	menu.frameinv.visible = false
	menu.framechar.visible = false
	menu.frameskills.visible = true

	menu.frameskills.get_child(2).text = \
str(player.skillAthletics) + "\n" \
+ "⠀\n" \
+ str(player.skillConcentration) + "\n" \
+ str(player.skillCraftSmithing) + "\n" \
+ "⠀\n" \
+ str(player.skillMusicianship) + "\n" \
+ str(player.skillCraftJewelcrafting) + "\n" \
+ str(player.skillCraftLeatherworking) + "\n" \
+ str(player.skillOpenLock) + "\n" \
+ str(player.skillSleightofHand) + "\n" \
+ str(player.skillCraftTraps) + "\n" \
+ str(player.skillCraftWeaving) + "\n" \
+ "⠀\n" \
+ str(player.skillAcrobacy) + "\n" \
+ str(player.skillPerformDance) + "\n" \
+ str(player.skillEscape) + "\n" \
+ str(player.skillHide) + "\n" \
+ str(player.skillRide) + "\n" \
+ str(player.skillMoveSilently)

	menu.frameskills.get_child(3).text = \
str(player.skillCraftAlchemy) + "\n" \
+ str(player.skillCraftCooking) + "\n" \
+ str(player.skillDisableDevice) + "\n" \
+ str(player.skillKnowledgeLore) + "\n" \
+ str(player.skillKnowledgeNature) + "\n" \
+ str(player.skillNurse) + "\n" \
+ str(player.skillUseMagicDevice) + "\n" \
+ " \n" \
+ str(player.skillHandleAnimal) + "\n" \
+ str(player.skillJudge) + "\n" \
+ str(player.skillListen) + "\n" \
+ str(player.skillSearch) + "\n" \
+ " \n" \
+ str(player.skillBluff) + "\n" \
+ str(player.skillDiplomacy) + "\n" \
+ str(player.skillIntimidate) + "\n" \
+ str(player.skillPerform)
