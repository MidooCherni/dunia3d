extends TextureRect

var readied = false
var sheathanim = false

func _ready() -> void:
	if !readied: set_position(Vector2(160, 1260))

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Weapon"):
		readied = !readied
		sheathanim = true
		
	if sheathanim:
		if readied:
			set_position(Vector2(0, position.y-40))
			if position.y <= 0: 
				set_position(Vector2(0, 0))
				sheathanim = false
		else:
			set_position(Vector2(0, position.y+40))
			if position.y >= 1080:
				set_position(Vector2(0, 1080))
				sheathanim = false
