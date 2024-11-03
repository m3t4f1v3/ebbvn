extends Control

var danmu = []

const quotes = [
	"happyyy birthdayyyyy esliiii",
	"Slappy turd day dumbass (love meep)"
]

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(20):
		var comment = RichTextLabel.new()
		var x = rng.randf_range(0, 1920)
		var comment_scale = rng.randf_range(1, 2)
		comment.scale = Vector2(comment_scale, comment_scale)
		
		var y = rng.randf_range(0, 1080.0)
		var speed = rng.randf_range(100, 500.0)
		comment.push_color(Color(rng.randf(), rng.randf(), rng.randf()))
		#comment.text = quotes[rng.randi_range(0,Esl len(quotes)-1)]
		comment.append_text(quotes[rng.randi_range(0, len(quotes)-1)])
		comment.pop()
		comment.set_meta("speed", speed)
		comment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		comment.autowrap_mode = TextServer.AUTOWRAP_OFF
		comment.fit_content = true
		danmu.append(comment)
		comment.position = Vector2(x, y)
		add_child(comment)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for comment in danmu:
		var speed = comment.get_meta("speed")
		comment.position.x += speed * delta
		
		# Check if the comment has moved past the right edge
		if comment.position.x > 1920:
			# Move it back to the left, wrapping it around the screen
			comment.position.x = -comment.size.x * comment.scale.x
