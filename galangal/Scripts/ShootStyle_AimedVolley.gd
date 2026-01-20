extends ShootStyle
class_name ShootStyle_AimedVolley

@export var lifetime: float = 2.0
@export var projectile_speed: float = 1000.0
@export var use_every_nth_point: int = 2   
@export var spread_radians: float = 0.06

func fire(ctx: Dictionary) -> void:
	var boss := ctx["boss"] as Node2D
	var pool := ctx["pool"] as Projectile_Pool
	var pts: Array = ctx["spawn_points"]
	var target_pos: Vector2 = ctx["target_pos"]

	for i in pts.size():
		if use_every_nth_point > 1 and (i % use_every_nth_point) != 0:
			continue

		var local_offset := pts[i] as Vector2
		var p := pool.acquire()
		if p == null:
			return

		var world_spawn := boss.global_transform * local_offset
		var base_dir := (target_pos - world_spawn).normalized()

		# Alternate left/right spread for pattern readability
		var s := spread_radians * (1.0 if (i % 2) == 0 else -1.0)
		var dir := base_dir.rotated(s)

		p.activate(world_spawn, dir, lifetime, projectile_speed, 4, 1)
