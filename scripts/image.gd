extends Control

var images = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Start hidden by default

# Initialize and display the image with optional arguments for file path, position, and size
func init(arguments: String) -> void:
	var image = TextureRect.new()
	image.hide()
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	images[arguments] = image
	var file_path = ""
	var pos = Vector2.ZERO
	var img_size = Vector2(1920, 1080)
	
	# Split the arguments by spaces
	var tokens = arguments.split(" ")
	if tokens.size() > 0:
		# The first token is always the file path
		file_path = tokens[0]
	
	var i = 1
	while i < tokens.size():
		match tokens[i]:
			"at":
				# Parse position if available
				if i + 2 < tokens.size():
					pos = Vector2(tokens[i + 1].to_int(), tokens[i + 2].to_int())
					i += 2
			"sized":
				# Parse size if available
				if i + 2 < tokens.size():
					img_size = Vector2(tokens[i + 1].to_int(), tokens[i + 2].to_int())
					i += 2
		i += 1
	
	# Apply position and size settings
	image.position = pos
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_SCALE

	image.set_size(img_size)
	# Load and apply the texture if file path is provided

	if file_path:
		# ugly but we're shipping in like 10 days
		image.texture = get_tree().get_current_scene().load_both("res://images/%s" % file_path, ImageTexture)
	add_child(image)
	image.show()

# Hide the image
func deinit(arguments: String) -> void:
	for key in images:
		#print(key, arguments)
		if arguments in key:
			images[key].queue_free()
			break
		
