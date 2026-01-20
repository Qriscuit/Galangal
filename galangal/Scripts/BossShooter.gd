# BossShooter.gd
extends Node2D
class_name BossShooter

signal health_changed(current: int, max: int)

@export var max_health: int = 100
var current_health: int

# Identify friend/foe (groups)
@export var player_projectile_group: StringName = &"player_projectiles"
@export var enemy_projectile_group: StringName = &"enemy_projectiles"

@export var pool_path: NodePath
@export var target_path: NodePath

@export var radius: float = 70.0
@export var point_count: int = 12

@export var fire_interval: float = 1
@export var style_switch_interval: float = 4.0

@export var styles: Array[ShootStyle] = []  # assign ShootStyle_* resources in Inspector

var _pool: Projectile_Pool
var _target: Node2D
var _spawn_points: Array[Vector2] = []
var _t: float = 0.0
var _style_index: int = 0

var _fire_accum: float = 0.0
var _style_accum: float = 0.0

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	
	_pool = get_node(pool_path) as Projectile_Pool
	_target = get_node(target_path) as Node2D
	_rebuild_spawn_points()

func _process(dt: float) -> void:
	_t += dt
	_fire_accum += dt
	_style_accum += dt

	if point_count != _spawn_points.size():
		_rebuild_spawn_points()

	if styles.is_empty():
		return

	if _style_accum >= style_switch_interval:
		_style_accum = 0.0
		_style_index = (_style_index + 1) % styles.size()

	if _fire_accum >= fire_interval:
		_fire_accum = 0.0
		_fire_current_style()

func _rebuild_spawn_points() -> void:
	_spawn_points.clear()
	if point_count <= 0:
		return

	var step := TAU / float(point_count)
	for i in point_count:
		var a := step * float(i)
		_spawn_points.append(Vector2(cos(a), sin(a)) * radius)
	# These are LOCAL offsets around the boss. We convert to world using boss.global_transform.

func _fire_current_style() -> void:
	if _pool == null or _target == null:
		return

	var ctx := {
		"boss": self,
		"pool": _pool,
		"spawn_points": _spawn_points,
		"target_pos": _target.global_position,
		"t": _t
	}

	styles[_style_index].fire(ctx)

# --------------------------------------------------------------------
# HIT REGISTRATION (connect Hurtbox Area2D.area_entered -> this)
# --------------------------------------------------------------------
func on_hurtbox_area_entered(area: Area2D) -> void:
	# Only take damage from player shots
	if not area.is_in_group(player_projectile_group):
		return

	_take_damage(1)

	# Despawn pooled projectile if applicable
	if area is Projectile:
		var proj := area as Projectile
		proj.request_despawn.emit(proj)

func _take_damage(damage: int) -> void:
	current_health = maxi(current_health - damage, 0)
	health_changed.emit(current_health, max_health)

	if current_health == 0:
		_on_boss_died()

func _on_boss_died() -> void:
	# Put your boss death behavior here (disable shooting, play anim, etc.)
	queue_free()
