extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in range(10):
		for y in range(10):
			var block = StaticBody3D.new()
			var block_mesh = CSGBox3D.new()
			var block_collision = CollisionShape3D.new()
			var stone = StandardMaterial3D.new()
			stone.albedo_texture = load("res://images/3dtextures/gilded_blackstone.png")
			stone.normal_enabled = true
			stone.normal_texture = load("res://images/3dtextures/gilded_blackstone_n.png")
			
			stone.metallic_texture = load("res://images/3dtextures/gilded_blackstone_s.png")
			stone.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
			
			stone.roughness_texture = load("res://images/3dtextures/gilded_blackstone_s.png")
			stone.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
			
			block_mesh.material = stone
			block_collision.shape = BoxShape3D.new()
			block.add_child(block_mesh)
			block.add_child(block_collision)
			block.position = Vector3(-x * 2, x + y - 1, -y * 2)
			self.add_child(block)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
