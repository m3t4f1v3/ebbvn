extends Control

var rect_dict = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Start hidden by default

# Initialize and display the rect with optional arguments for file path, position, and size
func initialize_rect(arguments: String) -> void:
	var color_rect = ColorRect.new()
	color_rect.hide()
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect_dict[arguments] = color_rect
	var path = ""
	var rect_position = Vector2.ZERO
	var rect_size = Vector2(1920, 1080)
	
	# Split the arguments by spaces
	var tokens = arguments.split(" ")
	if tokens.size() > 0:
		# The first token is always the file path
		path = tokens[0]
	
	var token_index = 1
	while token_index < tokens.size():
		match tokens[token_index]:
			"at":
				# Parse position if available
				if token_index + 2 < tokens.size():
					rect_position = Vector2(tokens[token_index + 1].to_int(), tokens[token_index + 2].to_int())
					token_index += 2
			"sized":
				# Parse size if available
				if token_index + 2 < tokens.size():
					rect_size = Vector2(tokens[token_index + 1].to_int(), tokens[token_index + 2].to_int())
					token_index += 2
		token_index += 1
	
	# Apply position and size settings
	color_rect.position = rect_position
	color_rect.set_size(rect_size)

	# Load and apply the color if file path is provided
	color_rect.color = Color(path)
	
	add_child(color_rect)
	color_rect.show()

# Hide the rect
func deinitialize_rect(arguments: String) -> void:
	for key in rect_dict:
		if arguments in key:
			rect_dict[key].queue_free()
			break
