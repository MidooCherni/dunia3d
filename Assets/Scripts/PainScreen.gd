extends TextureRect

#	miscellaneous function to handle pain screen when hit
var alph = 0.0

func _process(delta: float) -> void:
	if alph > 0.0:
		alph -= 0.02
		self_modulate.a = alph
