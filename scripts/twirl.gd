extends Control

var twirling = false
var detwirling = false
var total_progress = 0.0
var total_wait = 1.0
var max_drag_distance = 0.5

func init(argument: String) -> void:
	var parts = argument.split(", ")
	if len(parts) == 2: # does the argument actually exist, or do we use defaults
		total_wait = parts[0]
		max_drag_distance = parts[1]
	self.material.set_shader_parameter("max_drag_distance", 0.)
	twirling = true
	self.show()

func deinit(_argument: String) -> void:
	self.material.set_shader_parameter("max_drag_distance", max_drag_distance)
	detwirling = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if twirling:
		total_progress += delta
		self.material.set_shader_parameter("max_drag_distance", lerp(0.0, max_drag_distance, total_progress))
	elif detwirling:
		total_progress += delta
		self.material.set_shader_parameter("max_drag_distance", lerp(max_drag_distance, 0.0, total_progress))
	
	if total_progress >= total_wait:
		if detwirling:
			self.hide()
		twirling = false
		detwirling = false
		total_progress = 0  # Reset if needed for re-triggering the effect
