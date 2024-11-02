extends Node

@export var script_file_path: String = "res://script.md"
@export var button_theme: Theme  # Drag your custom theme resource here in the Inspector

var scenes = {}
var current_scene = "scene-1"

var left_char = ""
var right_char = ""
var waiting_for_click = false

func load_scene(scene_name):
	$Sprites/Left.texture = null
	$Sprites/Right.texture = null
	left_char = ""
	right_char = ""
	current_scene = scene_name
	update_scene_ui(scenes[current_scene])

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
		var split_line = line.split(": ")
		if line.begins_with("<!--"): continue # these are in-script comments
		if len(split_line) == 2:
			if line.begins_with("* "):  # Choice line
				# in markdown link syntax
				var choice = split_line[1].strip_edges().split("](")
				var choice_text = choice[0].trim_prefix("[")
				var scene_id = choice[1].trim_prefix("#").trim_suffix(")")
				choices.append([choice_text, scene_id])
			else:  # Dialogue line
				var char_name = split_line[0].split(" (")
				if len(char_name) == 2: # we are changing the sprite
					var char_sprite = char_name[1].rstrip(")")
					# change sprite to char_name
					match char_name:
						left_char:
							$Sprites/Left.texture = load("res://images/sprites/%s.png" % char_sprite)
						right_char:
							$Sprites/Right.texture = load("res://images/sprites/%s.png" % char_sprite)
						_:
							assert(false, "ERROR: You must introduce a characters position before setting the sprite.")
				if char_label.text != char_name[0]:
					# we are changing characters
					if char_name[0].to_lower() != "narrator":
						char_label.text = char_name[0]
					dialogue_text = ""
				dialogue_text += split_line[1] + "\n"
				# Wait for click here by setting waiting_for_click to true
				waiting_for_click = true
				#text_label.text = dialogue_text.strip_edges()
				await get_tree().create_timer(0.1).timeout  # A slight delay to allow UI to update
				var in_bbcode = false
				for character in dialogue_text:
					#text_label.append_text(character)
					text_label.text += character
					if character == "[":
						in_bbcode = true
					if character == "]":
						in_bbcode = false
					#print($TextBox/TextControl/ProgressButton.button_pressed)
					if not $TextBox/TextControl/ProgressButton.button_pressed and not in_bbcode:
						await get_tree().create_timer(0.05).timeout  # Adjust speed by changing the timer duration
				
				await $TextBox/TextControl/ProgressButton.pressed  # Wait for a click on TextControl node
				waiting_for_click = false
		else:
			# Handle other types of script actions
			if " enters from the " in line: # set initial positions
				var data = line.split(" enters from the ")
				var character = data[0]
				var position = data[1]
				
				match position:
					"left":
						left_char = character
						if right_char == character:
							right_char = ""
					"right":
						right_char = character
						if left_char == character:
							left_char = ""
					_:
						printerr("Invalid position specified for character.")
			elif line.begins_with("clear"):
				$TextBox/TextControl/Text.text = ""
			elif " moves to the " in line: # change positions
				var data = line.split(" moves to the ")
				var character = data[0]
				var position = data[1]
				var current_left_texture = $Sprites/Left.texture
				var current_right_texture = $Sprites/Right.texture
				$Sprites/Left.texture = current_right_texture
				$Sprites/Right.texture = current_left_texture
				
				match position:
					"left":
						left_char = character
						if right_char == character:
							right_char = ""
					"right":
						right_char = character
						if left_char == character:
							left_char = ""
					_:
						printerr("Invalid position specified for character.")
			elif " changes into " in line: # sprite change
				var data = line.split(" changes into ")
				var character = data[0]
				var char_sprite = data[1]
				match character:
					left_char:
						$Sprites/Left.texture = load("res://images/sprites/%s" % char_sprite)
					right_char:
						$Sprites/Right.texture = load("res://images/sprites/%s" % char_sprite)
					_:
						assert(false, "ERROR: Character position not set before changing sprite.")
			elif line.begins_with("bgi"): # background image change
				$BackgroundImage.texture = load("res://images/backgrounds/%s" % line.trim_prefix("bgi "))
			elif " plays at " in line: # music
				var type_and_file = line.split(" plays at ")[0].split(" ")
				var type = type_and_file[0]
				var file = type_and_file[1]
				var volume = line.split(" plays at ")[1].to_float()
				if type == "bgm":
					$BackgroundMusicPlayer.stream = load("res://audio/bgm/%s" % file)
					$BackgroundMusicPlayer.volume_db = volume
					$BackgroundMusicPlayer.play()
				else:
					$SFXPlayer.stream = load("res://audio/sfx/%s" % file)
					$SFXPlayer.volume_db = volume
					$SFXPlayer.play()
			elif line.begins_with("goto"):
				load_scene(line.trim_prefix("goto "))
			else:
				print(line)
				assert(false, "ERROR: Unrecognized line format.")
	
	# Populate choice buttons
	for choice in choices:
		var button = Button.new()
		button.text = choice[0].strip_edges()  # The choice text
		button.theme = button_theme  # Apply the custom theme
		button.size_flags_horizontal = Control.SIZE_EXPAND | Control.SIZE_FILL
		button.connect("pressed", Callable(self, "_on_choice_selected").bind(choice[1].strip_edges()))  # Connect to scene loading
		button_container.add_child(button)

func _on_choice_selected(next_scene: String):
	load_scene(next_scene)

func _ready():
	var file = FileAccess.open(script_file_path, FileAccess.ModeFlags.READ)
	if file:
		var script_text = file.get_as_text()
		scenes = parse_markdown(script_text)
		file.close()
		load_scene("scene-1")  # Start at Scene 1 or an initial scene of your choice

func parse_markdown(text: String) -> Dictionary:
	var parsed_scenes = {}
	var local_scene = ""
	for line in text.split("\n"):
		if line.begins_with("## "):
			local_scene = line.trim_prefix("## ").strip_edges().replace(" ", "-").to_lower()
			parsed_scenes[local_scene] = []
		elif local_scene and line:
			parsed_scenes[local_scene].append(line)
	return parsed_scenes
