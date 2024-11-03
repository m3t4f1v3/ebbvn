extends Control

var twirling = false
var detwirling = false
var total_progress = 0.

func init() -> void:
	self.material.set_shader_parameter("max_drag_distance", 0.)
	twirling = true
	self.show()

func deinit() -> void:
	self.material.set_shader_parameter("max_drag_distance", 0.5)
	detwirling = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if twirling:
		total_progress += delta
		self.material.set_shader_parameter("max_drag_distance", lerp(0.0, 0.5, total_progress))
	elif detwirling:
		total_progress += delta
		self.material.set_shader_parameter("max_drag_distance", lerp(0.5, 0.0, total_progress))
	
	if total_progress >= 1.0:
		if detwirling:
			self.hide()
		twirling = false
		detwirling = false
		total_progress = 0  # Reset if needed for re-triggering the effect
