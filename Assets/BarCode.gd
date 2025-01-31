extends Control

@onready var player = $"../../Player/PlayerScripting"
@onready var hpbar = $UIHP
@onready var mpbar = $UIMP
@onready var spbar = $UISP

func _process(_delta):		# TODO: ceontingency for slots
	hpbar.set_scale(Vector2((1.5 * (float(player.cur_hp) / float(player.max_hp))), 0.5))
	mpbar.set_scale(Vector2((1.5 * (float(player.cur_mp) / float(player.max_mp))), 0.5))
	spbar.set_scale(Vector2((1.5 * (float(player.cur_sp) / float(player.max_sp))), 0.5))
