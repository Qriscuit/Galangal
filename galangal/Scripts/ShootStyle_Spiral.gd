# ShootStyle_Spiral.gd
extends ShootStyle
class_name ShootStyle_Spiral

@export var lifetime: float = 2.2
@export var projectile_speed: float = 850.0
@export var angular_speed: float = 2.5  # radians/sec

func fire(ctx: Dictionary) -> void:
	var boss := ctx["boss"] as Node2D
	var pool := ctx["pool"] as Projectile_Pool
	var pts: Array = ctx["spawn_points"]
	var t: float = ctx["t"]

	var angle_offset := t * angular_speed

	for i in pts.size():
		var local_offset := pts[i] as Vector2
		var p := pool.acquire()
		if p == null:
			return

		var world_spawn := boss.global_transform * local_offset

		# Base outward direction, rotated by time-based spiral offset
		var outward := (world_spawn - boss.global_position).normalized()
		var dir := outward.rotated(angle_offset + float(i) * 0.15)

		p.activate(world_spawn, dir, lifetime, projectile_speed, 4, 1)
