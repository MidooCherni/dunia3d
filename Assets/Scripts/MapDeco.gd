extends Sprite3D

var rng = RandomNumberGenerator.new()

var possible_decos = [
	preload("res://Assets/Textures/MeshUV/skull.png"),
	preload("res://Assets/Textures/MeshUV/skulls.png")
]

func _ready() -> void:
	var ran = randi_range(0, possible_decos.size()-1)
	texture = possible_decos[ran]
	offset.x -= texture.get_width() / 2.0
	offset.y -= 1
