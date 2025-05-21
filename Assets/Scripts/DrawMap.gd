extends Control

@onready var p = $"../../Player"

func draw_map(gridfile):
	# Create an image with 100x50 pixels
	var image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	
	# Iterate through pixels and set their color
	for y in range(0, 64):
		for x in range(0, 64):
			match gridfile[x][y]:
				' ':
					image.set_pixel(x, y, Color(0, 0, 0, 0.5)) # black
				'#':
					image.set_pixel(x, y, Color(0.7, 0.35, 0, 1)) # brown
				'-', '|':
					image.set_pixel(x, y, Color(0, 1, 0, 1)) # green
				'.':
					image.set_pixel(x, y, Color(0.3, 0.3, 0.3, 1)) # grey
				'>':
					image.set_pixel(x, y, Color(1, 0.25, 0.5, 1)) # pink
					#image.set_pixel(x, y, Color(1, 0.5, 0, 1)) # brown
	if p.position.x > 0 and p.position.x < 128 and p.position.z > 0 and p.position.z < 128:
		image.set_pixel(p.tile(p.position.x)/2, p.tile(p.position.z)/2, Color(1, 0, 0, 1)) # red
	
	var image_texture = ImageTexture.create_from_image(image)
	
	var sprite = Sprite2D.new()
	sprite.texture = image_texture
	
	add_child(sprite)
	sprite.position.x = DisplayServer.screen_get_size().x - 100
	sprite.position.y = DisplayServer.screen_get_size().y - 100
	sprite.scale.x = 3.0
	sprite.scale.y = 3.0
