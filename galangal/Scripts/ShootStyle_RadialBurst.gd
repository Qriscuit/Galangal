extends ShootStyle

class_name ShootStyle_RadialBurst

@export var lifetime: float = 2.0
@export var projectile_speed: float = 900.0

func fire(ctx: Dictionary) -> void:
	var boss := ctx["boss"] as Node2D
	var pool := ctx["pool"] as Projectile_Pool
	var pts: Array = ctx["spawn_points"]

	for local_offset in pts:
		var p := pool.acquire()
		if p == null:
			return

		var world_spawn := boss.global_transform * (local_offset as Vector2)
		var dir := (world_spawn - boss.global_position).normalized()  # outward

		p.activate(world_spawn, dir, lifetime, projectile_speed, 4, 1)
