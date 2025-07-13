extends Control

@onready var buttinv = $ButtInv
@onready var buttchar = $ButtChar
@onready var buttskills = $ButtSkills
@onready var frameinv = $FrameInventory
@onready var framechar = $FrameChar
@onready var frameskills = $FrameSkills
@onready var equipslots = $EquipSlots

@onready var player = $"../../Player"
@onready var invhandler = $FrameInventory/InvButtCont

@onready var cursorlabel = $CursorLabel
@onready var buttonfather = $FrameInventory/InvButtCont
@onready var equipbuttonfather = $EquipSlots/EquipSlotsGrp

enum WindowType{
	NONE, INV, CHAR, SKILLS, SPELLBOOK
}

var window = WindowType.NONE
var labelvisible = false

func _ready() -> void:
	buttinv.visible = false
	buttchar.visible = false
	buttskills.visible = false
	frameinv.visible = false
	framechar.visible = false
	frameskills.visible = false
	equipslots.visible = false

func _physics_process(_delta: float) -> void:
	invhandler.render()
	labelvisible = false
	for i in range(0, 42):
		if buttonfather.get_child(i).is_being_hovered:
			labelvisible = true
	for i in range(0, 11):
		if equipbuttonfather.get_child(i).is_being_hovered:
			labelvisible = true
	cursorlabel.visible = labelvisible
	if Input.is_action_just_pressed("Menu"):
		if window == WindowType.NONE:
			player.mousecap = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			window = WindowType.INV
			buttinv.visible = true
			buttinv.self_modulate.a = 0.5
			buttchar.visible = true
			buttskills.visible = true
			equipslots.visible = true
			frameinv.visible = true
			framechar.visible = false
			frameskills.visible = false
		else:
			window = WindowType.NONE
			player.mousecap = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			buttinv.visible = false
			buttchar.visible = false
			equipslots.visible = false
			buttskills.visible = false
			frameinv.visible = false
			framechar.visible = false
			frameskills.visible = false
