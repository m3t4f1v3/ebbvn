extends Node

@export var read_from_current_dir = false
@export var script_file = "script.md"
@export var button_theme: Theme  # Drag your custom theme resource here in the Inspector
@export var validate_script = false

var scenes = {}
var current_scene = "scene-1"
var base_dir = ""

var left_char = ""
var middle_char = ""
var right_char = ""

var credits_rolling = false
var shaking
var shake_intensity = 10
var audio_positions = {}
var current_bgm = ""
var current_sfx = ""

@onready var default_left_position = Vector2($Sprites/Left.position)
@onready var default_middle_position = Vector2($Sprites/Middle.position)
@onready var default_right_position = Vector2($Sprites/Right.position)
@onready var default_left_size = Vector2($Sprites/Left.size)
@onready var default_middle_size = Vector2($Sprites/Middle.size)
@onready var default_right_size = Vector2($Sprites/Right.size)

func load_scene(scene_name):
	$Sprites/Left.texture = null
	$Sprites/Middle.texture = null
	$Sprites/Right.texture = null
	left_char = ""
	middle_char = ""
	right_char = ""
	current_scene = scene_name
	update_scene_ui(scenes[current_scene])

func load_both(path: String, type = null):
	if read_from_current_dir:
		match type:
			ImageTexture:
				var image = Image.load_from_file(path)
				var texture = ImageTexture.create_from_image(image)
				return texture
			AudioStream:
				var audio
				if "ogg" in path:
					audio = AudioStreamOggVorbis.load_from_file(path)
				else:
					var file = FileAccess.open(path, FileAccess.READ)
					if "wav" in path:
						printerr("This will hurt your ears, thus I will NOT play it")
						#audio = AudioStreamWAV.new()
						return
					elif "mp3" in path:
						audio = AudioStreamMP3.new()
					audio.data = file.get_buffer(file.get_length())
				return audio
			_:
				print(path)
				printerr("Invalid type provided")
	else:
		return load(path)
			
func _input(event: InputEvent):
	$SubViewport.push_input(event)

func update_scene_ui(scene_lines: Array):
	# Reference the text label and buttons container
	var text_label = $TextBox/TextControl/Text
	var char_label = $TextBox/NameControl/Name
	var button_container = $TextBox/Buttons/HBoxContainer
	
	# Clear previous buttons
	for child in button_container.get_children():
		child.queue_free()

	# Initialize variables to hold dialogue text and choices
	var dialogue_text = ""
	var choices = []
	
	# Separate dialogue lines from choices
	for line in scene_lines:
		var split_line = line.split(": ", true, 1)
		if line.begins_with("<!--"): continue # these are in-script comments
		if len(split_line) == 2:
			if line.begins_with("* "):  # Choice line
				# in markdown link syntax
				var choice = split_line[1].strip_edges().split("](")
				var choice_text = choice[0].trim_prefix("[")
				var scene_id = choice[1].trim_prefix("#").trim_suffix(")")
				var option_label = split_line[0].trim_prefix("* ")
				choices.append([choice_text, scene_id, option_label])
			else:  # Dialogue line
				var char_name = split_line[0].split(" (")
				if len(char_name) == 2: # we are changing the sprite
					var char_sprite = char_name[1].rstrip(")")
					# change sprite to char_name
					match char_name[0]:
						left_char:
							$Sprites/Left.texture = load_both(base_dir + "images/sprites/%s" % char_sprite, ImageTexture)
						middle_char:
							$Sprites/Middle.texture = load_both(base_dir + "images/sprites/%s" % char_sprite, ImageTexture)
						right_char:
							$Sprites/Right.texture = load_both(base_dir + "images/sprites/%s" % char_sprite, ImageTexture)
						_:
							assert(false, "ERROR: You must introduce a characters position before setting the sprite.")
				dialogue_text = ""
				if char_label.text != char_name[0]: # we are changing characters
					dialogue_text += "\n"
					if char_name[0].to_lower() != "narrator":
						char_label.text = char_name[0]
				dialogue_text += split_line[1] + "\n"
				#text_label.text = dialogue_text.strip_edges()
				if not validate_script:
					await get_tree().create_timer(0.1).timeout  # A slight delay to allow UI to update
				var in_bbcode = false
				line.replace("res://", base_dir)
				for character in dialogue_text:
					
					text_label.text += character
					if character == "[":
						in_bbcode = true
					if character == "]":
						in_bbcode = false
					
					if not $TextBox/TextControl/ProgressButton.button_pressed and not in_bbcode and not Input.is_action_pressed("HURRRYYY") and not validate_script:
						if Input.is_action_pressed("speed up text scroll"):
							await get_tree().create_timer(0.01).timeout
						else:
							await get_tree().create_timer(0.05).timeout # Adjust speed by changing the timer duration
				if not validate_script:
					await $TextBox/TextControl/ProgressButton.pressed  # Wait for a click on TextControl node
		else:
			# Handle other types of script actions
			if " enters from the " in line: # set initial positions
				var data = line.split(" enters from the ")
				var character = data[0]
				var position = data[1]
				
				match position:
					"left":
						left_char = character
						$Sprites/Left.position = default_left_position
						$Sprites/Left.size = default_left_size
					"middle":
						middle_char = character
						$Sprites/Middle.position = default_middle_position
						$Sprites/Middle.size = default_middle_size
					"right":
						right_char = character
						$Sprites/Right.position = default_right_position
						$Sprites/Middle.size = default_right_size
					_:
						print(line)
						printerr("Invalid position specified for character.")
			elif line.begins_with("clear"):
				if line == "clear":
					$TextBox/NameControl/Name.text = ""
					$TextBox/TextControl/Text.text = ""
				if "chars" in line:
					$Sprites/Left.texture = null
					$Sprites/Middle.texture = null
					$Sprites/Right.texture = null
					left_char = ""
					middle_char = ""
					right_char = ""
					$Sprites/Left.position = default_left_position
					$Sprites/Left.size = default_left_size
					$Sprites/Middle.position = default_middle_position
					$Sprites/Middle.size = default_middle_size
					$Sprites/Right.position = default_right_position
					$Sprites/Right.size = default_right_size
				if "sprites" in line:
					$Sprites/Left.texture = null
					$Sprites/Middle.texture = null
					$Sprites/Right.texture = null
					$Sprites/Left.position = default_left_position
					$Sprites/Left.size = default_left_size
					$Sprites/Middle.position = default_middle_position
					$Sprites/Middle.size = default_middle_size
					$Sprites/Right.position = default_right_position
					$Sprites/Right.size = default_right_size

			elif " moves to the " in line: # change positions
				var data = line.split(" moves to the ")
				var character = data[0]
				var position = data[1]
				
				# Determine current position of the character
				var current_sprite = null
				if character == left_char:
					current_sprite = "left"
				elif character == middle_char:
					current_sprite = "middle"
				elif character == right_char:
					current_sprite = "right"
				else:
					print(line)
					printerr("Invalid character specified to move.")
					return
				
				# Move character to the specified position
				match position:
					"left":
						left_char = character
						if current_sprite == "middle":
							$Sprites/Left.texture = $Sprites/Middle.texture
							$Sprites/Middle.texture = null
						elif current_sprite == "right":
							$Sprites/Left.texture = $Sprites/Right.texture
							$Sprites/Right.texture = null
					"middle":
						middle_char = character
						if current_sprite == "left":
							$Sprites/Middle.texture = $Sprites/Left.texture
							$Sprites/Left.texture = null
						elif current_sprite == "right":
							$Sprites/Middle.texture = $Sprites/Right.texture
							$Sprites/Right.texture = null
					"right":
						right_char = character
						if current_sprite == "left":
							$Sprites/Right.texture = $Sprites/Left.texture
							$Sprites/Left.texture = null
						elif current_sprite == "middle":
							$Sprites/Right.texture = $Sprites/Middle.texture
							$Sprites/Middle.texture = null
					_:
						print(line)
						printerr("Invalid position specified for character.")
			elif " changes into " in line: # sprite change
				var data = line.split(" changes into ")
				var character = data[0]
				var char_sprite = data[1]
				match character:
					left_char:
						$Sprites/Left.texture = load_both(base_dir + "images/sprites/%s" % char_sprite, ImageTexture)
					middle_char:
						$Sprites/Middle.texture = load_both(base_dir + "images/sprites/%s" % char_sprite, ImageTexture)
					right_char:
						$Sprites/Right.texture = load_both(base_dir + "images/sprites/%s" % char_sprite, ImageTexture)
					_:
						print(line)
						assert(false, "ERROR: Character position not set before changing sprite.")
			elif line.begins_with("bgi"): # background image change
				var arguments = line.trim_prefix("bgi ")
				var tokens = arguments.split(" ")
				var file_path
				var pos = Vector2(0, 0)
				var img_size = Vector2(1920, 1080)
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
				$BackgroundImage.texture = load_both(base_dir + "images/backgrounds/%s" % file_path, ImageTexture)
				$BackgroundImage.size = img_size
				$BackgroundImage.position = pos
			elif line.begins_with("credits bgi"): # credits background change
				$Credits.texture = load_both(base_dir + "images/backgrounds/%s" % line.trim_prefix("credits bgi "), ImageTexture)
			elif " plays" in line:  # music playback command
				var parts = line.split(" plays")
				var type_and_file = parts[0].split(" ")
				var type = type_and_file[0]
				var file = type_and_file[1]
				
				
				# Default values for optional parameters
				var volume: float = 0  # Default volume if "at" not specified
				var start_time: float = 0  # Default start time if "from" not specified
				
				# Check for optional parameters "at" (volume) and "from" (start time)
				if "at" in parts[1] and "from" in parts[1]:
					# Syntax: "file plays at Xdb from Y sec"
					var play_at_parts = parts[1].split("at ")
					volume = play_at_parts[1].split(" db ")[0].to_float()
					start_time = play_at_parts[1].split(" from ")[1].to_float()
				elif "at" in parts[1]:
					# Syntax: "file plays at Xdb"
					#print(parts[1])
					volume = parts[1].split("at ")[1].to_float()
				elif "from" in parts[1]:
					# Syntax: "file plays from Y sec"
					start_time = parts[1].split(" from ")[1].to_float()
				
				# Load and configure the audio stream based on type
				if type == "bgm":
					if current_bgm:
						audio_positions[current_bgm] = $BackgroundMusicPlayer.get_playback_position()
					current_bgm = file
					$BackgroundMusicPlayer.stream = load_both(base_dir + "audio/bgm/%s" % file, AudioStream)
					$BackgroundMusicPlayer.volume_db = volume
					$BackgroundMusicPlayer.play(start_time)
				elif type == "sfx":
					if current_sfx:
						audio_positions[current_sfx] = $SFXPlayer.get_playback_position()
					$SFXPlayer.stream = load_both(base_dir + "audio/sfx/%s" % file, AudioStream)
					$SFXPlayer.volume_db = volume
					$SFXPlayer.play(start_time)
				else:
					print(line)
					printerr("Invalid sound type")
			elif " stops" in line:
				if "bgm" in line:
					$BackgroundMusicPlayer.stop()
				elif "sfx" in line:
					$SFXPlayer.stop()
				else:
					print(line)
					printerr("Invalid sound type")
			elif " pauses" in line:
				var parts = line.trim_suffix(" pauses").split(" ")
				var type = parts[0]
				var audio = parts[1]
				if type == "bgm":
					audio_positions[audio] = $BackgroundMusicPlayer.get_playback_position()
					$BackgroundMusicPlayer.stop()
				elif type == "sfx":
					audio_positions[audio] = $SFXPlayer.get_playback_position()
					$SFXPlayer.stop()
				else:
					print(line)
					printerr("Invalid sound type")
			elif " resumes" in line:
				var parts = line.trim_suffix(" resumes").split(" ")
				var type = parts[0]
				var audio = parts[1]
				if type == "bgm":
					$BackgroundMusicPlayer.stream = load_both(base_dir + "audio/bgm/%s" % audio, AudioStream)
					if audio_positions.has(audio):
						$BackgroundMusicPlayer.play(audio_positions[audio])
					else:
						$BackgroundMusicPlayer.play()
				elif type == "sfx":
					$SFXPlayer.stream = load_both(base_dir + "audio/bgm/%s" % audio, AudioStream)
					if audio_positions.has(audio):
						$SFXPlayer.play(audio_positions[audio])
					else:
						$SFXPlayer.play()
				else:
					print(line)
					printerr("Invalid sound type")
			elif " goes to " in line and "db" in line:
				var parts = line.split(" goes to ")
				var type = parts[0]
				var volume = float(parts[1])
				if type == "bgm":
					$BackgroundMusicPlayer.volume_db = volume
				elif type == "sfx":
					$SFXPlayer.volume_db = volume
				else:
					print(line)
					printerr("Invalid sound type")
			elif line == "hide textbox":
				$TextBox.hide()
			elif line == "show textbox":
				$TextBox.show()
			elif line.begins_with("goto "):
				load_scene(line.trim_prefix("goto "))
			elif line.begins_with("wait for click"):
				if not validate_script:
					await $TextBox/TextControl/ProgressButton.pressed
			elif line.begins_with("3D"):
				var command = line.trim_prefix("3D ")
				if command.begins_with("wait for completion of parkour course "):
					var course = command.trim_prefix("wait for completion of parkour course ")
					$"SubViewport/Node3D/Parkour Civilization".call(course)
					$SubViewport/Node3D/CharacterBody3D.position = Vector3(0,1,0)
					#var deaths = 0
					$"SubViewport/Node3D/Ground/Limitless".connect("body_entered", Callable(func(body):
						#deaths += 1
						if body == $SubViewport/Node3D/CharacterBody3D:
							$TextBox/NameControl/Name.text = "Satoru Gojo keychain"
							$TextBox/TextControl/Text.text += "Limitless\n"
							#print(deaths)
						)
					)
					if not validate_script:
						var _body = await $"SubViewport/Node3D/Parkour Civilization".flag.body_entered
					#print(body)
				else:
					print(line)
					printerr("unknown 3d command")
			elif line.begins_with("pause for "): # pause for 1 sec
				if not validate_script:
					await get_tree().create_timer(float(line.trim_prefix("pause for "))).timeout
			elif line.begins_with("fullscreen effect "):
				var parts = line.split(" ")
				
				
				
				var action = parts[2]  # Expected to be "show" or "hide"
				var effect_name = parts[3]  # Expected effect name
				var effect_path = "FullscreenFx/%s" % effect_name
				
				var argument = line.substr(len("fullscreen effect xxxx ") + len(effect_name) + 1)
				if effect_name == "screenshake":
					if action == "show":
						shaking = true
						shake_intensity = float(argument)
					elif action == "hide":
						shaking = false
						$TextBox.position = Vector2(60, 560)
						$Sprites.position = Vector2(60, 70)
					else:
						printerr("Invalid action '%s' for fullscreen effect '%s'." % [action, effect_name])
						
				# Check if the node exists
				if not has_node(effect_path):
					printerr("Effect node '%s' not found." % effect_name)
					return
				
				var effect_node = get_node(effect_path)
				
				# Handle show/hide actions
				match action:
					"show":
						if effect_node.has_method("init"):
							effect_node.init(argument)
						else:
							effect_node.show()
					"hide":
						if effect_node.has_method("deinit"):
							effect_node.deinit(argument)
						else:
							effect_node.hide()
					_:
						printerr("Invalid action '%s' for fullscreen effect '%s'." % [action, effect_name])

			elif " sprite translates to " in line:
				var data = line.split(" sprite translates to ")
				var sprite_to_change = data[0]
				var sprite_position = data[1].split(",")
				match sprite_to_change.to_lower():
					"left":
						$Sprites/Left.set_position(Vector2(float(sprite_position[0]), float(sprite_position[1])))
					"middle":
						$Sprites/Middle.set_position(Vector2(float(sprite_position[0]), float(sprite_position[1])))
					"right":
						$Sprites/Right.set_position(Vector2(float(sprite_position[0]), float(sprite_position[1])))
					_:
						print(line)
						assert(false, "ERROR: Invalid sprite position")
			elif " sprite rotates by " in line:
				var data = line.split(" sprite rotates by ")
				var sprite_to_change = data[0]
				var sprite_angle_in_deg = float(data[1])
				match sprite_to_change.to_lower():
					"left":
						$Sprites/Left.rotation_degrees = sprite_angle_in_deg
					"middle":
						$Sprites/Middle.rotation_degrees = sprite_angle_in_deg
					"right":
						$Sprites/Right.rotation_degrees = sprite_angle_in_deg
					_:
						print(line)
						assert(false, "ERROR: Invalid sprite position")
			elif " sprite scales to " in line:
				var data = line.split(" sprite scales to ")
				var sprite_to_change = data[0]
				var sprite_scales = data[1].split(",")
				match sprite_to_change.to_lower():
					"left":
						$Sprites/Left.set_size(Vector2(float(sprite_scales[0]), float(sprite_scales[1])))
					"middle":
						$Sprites/Middle.set_size(Vector2(float(sprite_scales[0]), float(sprite_scales[1])))
					"right":
						$Sprites/Right.set_size(Vector2(float(sprite_scales[0]), float(sprite_scales[1])))
					_:
						print(line)
						assert(false, "ERROR: Invalid sprite position")
			elif line.begins_with("credits roll"):
				$TextBox/Buttons.hide()
				$TextBox/NameControl.hide()
				$TextBox.position = Vector2(0,0)
				$TextBox/TextControl.position = Vector2(0,0)
				$TextBox/TextControl.size = Vector2(1920, 1080)
				$TextBox/TextControl/Text.size = Vector2(1920, 1080)
				#$TextBox/TextControl/Text.scroll_following = true
				#$TextBox/TextControl/Text.theme.default_font_size = 96
				#$TextBox/TextControl/Text.material.shader = load_both(base_dir + "shaders/tilt.gdshader")
				$TextBox/TextControl/TextBackground.size = Vector2(1920, 1080)
				$TextBox/TextControl/TextBackground.material.shader = null
				$Credits.show()
				
				if $BackgroundImage.texture:
					$Credits.texture = $BackgroundImage.texture
				
				var steps = 100
				
				for step in range(steps): #really stupid way of doing this ngl
					$Credits.material.set_shader_parameter("up_left", lerp(Vector2(0,0), Vector2(0.2, 0.5), float(step+1)/steps))
					$Credits.material.set_shader_parameter("up_right", lerp(Vector2(1,0), Vector2(0.8, 0.5), float(step+1)/steps))
					$Credits.material.set_shader_parameter("down_right", lerp(Vector2(1,1), Vector2(1, 0.8), float(step+1)/steps))
					$Credits.material.set_shader_parameter("down_left", lerp(Vector2(0,1), Vector2(0, 0.8), float(step+1)/steps))
					if not validate_script:
						await get_tree().create_timer(float(1)/steps).timeout
					#print($Credits.material.get_shader_parameter("up_left"))
				
				#$TextBox/TextControl/Text.material.set_shader_parameter("up_left", Vector2(0.4, 0))
				#$TextBox/TextControl/Text.material.set_shader_parameter("up_right", Vector2(1-0.4, 0))
				
				#$TextBox/TextControl/TextBackground.material.set_shader_parameter("up_left", Vector2(0.4, 0))
				#$TextBox/TextControl/TextBackground.material.set_shader_parameter("up_right", Vector2(1-0.4, 0))
				
				credits_rolling = true
				
			elif credits_rolling:
				var in_bbcode = false
				line.replace("res://", base_dir)
				for character in line:
					text_label.text += character
					if character == "[":
						in_bbcode = true
					if character == "]":
						in_bbcode = false
					if not in_bbcode and not validate_script:
						await get_tree().create_timer(0.03).timeout
				text_label.text += "\n"
				#await get_tree().create_timer(0.01).timeout
			else:
				print(line)
				assert(false, "ERROR: Unrecognized line format.")
	if choices:
		# Populate choice buttons
		for choice in choices:
			if choice[2].is_valid_int():
				var current_time = Time.get_unix_time_from_system()
				if abs(current_time - float(choice[2])) < 7*24*60*60:
					#print(current_time)
					#print(float(choice[2]))
					pass # process it if we are within 1 week of the time
				else:
					#print(current_time)
					#print(float(choice[2]))
					continue
			var button = Button.new()
			button.text = choice[0].strip_edges()  # The choice text
			button.theme = button_theme  # Apply the custom theme
			button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
			button.connect("pressed", Callable(self, "_on_choice_selected").bind(choice[1].strip_edges()))  # Connect to scene loading
			button_container.add_child(button)
	else:
		print("we're done")

func _on_choice_selected(next_scene: String):
	load_scene(next_scene)

func _process(_delta):
	if shaking:
		var random_offset = Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity))
		$TextBox.position = Vector2(60, 560) + random_offset
		$Sprites.position = Vector2(60, 70) + random_offset
	if Input.is_action_pressed("hide textbox"):
		$TextBox.hide()
	else:
		$TextBox.show()

func _ready():
	if read_from_current_dir:
		base_dir = "./"
	else:
		base_dir = "res://"

	print("we are working from ", base_dir)
	var file = FileAccess.open(base_dir + script_file, FileAccess.ModeFlags.READ)
	if file:
		var script_text = file.get_as_text()
		scenes = parse_markdown(script_text)
		#print(scenes)
		file.close()
		load_scene("scene-1")  # Start at Scene 1 or an initial scene of your choice

func clean_string(input: String) -> String:
	var regex = RegEx.new()
	regex.compile("[^a-zA-Z0-9-]")  # Matches any character that is NOT alphanumeric or a hyphen
	return regex.sub(input,"")  # Replace matches with an empty string


func parse_markdown(text: String) -> Dictionary:
	var parsed_scenes = {}
	var local_scene = ""
	for line in text.split("\n"):
		if line.begins_with("## "):
			#print("please")
			local_scene = clean_string(line.trim_prefix("## ").strip_edges().replace(" ", "-")).to_lower()
			parsed_scenes[local_scene] = []
			#print(local_scene)
		elif local_scene and line:
			parsed_scenes[local_scene].append(line)
	return parsed_scenes
