extends Control

var titlecards = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Start hidden by default

# Initialize and display the titlecard with optional arguments for text, position, and size
func init(arguments: String) -> void:
	var titlecard = RichTextLabel.new()
	titlecard.bbcode_enabled = true
	titlecard.hide()
	titlecard.mouse_filter = Control.MOUSE_FILTER_IGNORE
	titlecards[arguments] = titlecard
	var text = ""
	var pos = Vector2.ZERO
	var card_size = Vector2(1920, 1080)
	
	# Split the arguments by spaces
	var tokens = arguments.split(" ")
	if tokens.size() > 0:
		# The first token is always the text
		text = tokens[0]
	
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
					card_size = Vector2(tokens[i + 1].to_int(), tokens[i + 2].to_int())
					i += 2
		i += 1
	
	# Apply position and size settings
	titlecard.text += text
	titlecard.position = pos
	titlecard.set_size(card_size)
	
	add_child(titlecard)
	titlecard.show()

# Hide the titlecard
func deinit(arguments: String) -> void:
	for key in titlecards:
		#print(key, arguments)
		if arguments in key:
			titlecards[key].queue_free()
			break
		
