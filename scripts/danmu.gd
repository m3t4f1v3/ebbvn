extends Control

var danmu = []

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func init(arguments: String) -> void:
	# nasty, but we should only see this at the end
	#await get_tree().get_current_scene().ready
	var quotes = arguments.split("|")
	#print(quotes)
	for i in range(20):
		var comment = RichTextLabel.new()
		#var x = rng.randf_range(0, 1920)
		var comment_scale = rng.randf_range(1, 2)
		comment.scale = Vector2(comment_scale, comment_scale)
		
		var y = rng.randf_range(0, 1080.0)
		var speed = rng.randf_range(100, 500.0)
		comment.push_color(Color(rng.randf(), rng.randf(), rng.randf()))
		var text = quotes[rng.randi_range(0, len(quotes)-1)]
		if "[img]" in text:
			var parts = text.split("]")
			var data = parts[0].trim_prefix("[img")
			var path = parts[1].trim_suffix("[/img")#.replace("res://", get_tree().get_current_scene().base_dir)
			#print(path)
			if "=" in data:
				# currently only supports width and height
				var w_h = data.trim_prefix("=").split("x")
				if len(w_h) == 2:
					# we have both width and height
					comment.add_image(get_tree().get_current_scene().load_both(path, ImageTexture), w_h[0], w_h[1])
				else:
					# just width
					comment.add_image(get_tree().get_current_scene().load_both(path, ImageTexture), w_h[0])
			else:
				# no arguments, no worries
				comment.add_image(get_tree().get_current_scene().load_both(path, ImageTexture))
		else:
			comment.append_text(text)
		
		comment.pop()
		comment.set_meta("speed", speed)
		comment.mouse_filter = Control.MOUSE_FILTER_IGNORE
		comment.autowrap_mode = TextServer.AUTOWRAP_OFF
		comment.fit_content = true
		danmu.append(comment)
		# design choice?
		comment.position = Vector2(-1000, y)
		add_child(comment)
	self.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for comment in danmu:
		var speed = comment.get_meta("speed")
		comment.position.x += speed * delta
		
		# Check if the comment has moved past the right edge
		if comment.position.x > 1920:
			# Move it back to the left, wrapping it around the screen
			comment.position.x = -comment.size.x * comment.scale.x

# no deinit since we wont really be dealing with it any further tbh
