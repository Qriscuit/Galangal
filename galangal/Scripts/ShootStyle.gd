extends Resource

class_name ShootStyle

# Boss calls this. Implementations decide how to spawn bullets.
func fire(ctx: Dictionary) -> void:
	# ctx keys (convention):
	# "boss": Node2D
	# "pool": ProjectilePool
	# "spawn_points": Array[Vector2] (LOCAL offsets around boss)
	# "target_pos": Vector2
	# "t": float (time in seconds)
	pass
