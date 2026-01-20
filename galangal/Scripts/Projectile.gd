# Projectile.gd
extends Area2D
class_name Projectile

signal request_despawn(projectile: Projectile)

@export var speed: float = 900.0

var _velocity: Vector2 = Vector2.ZERO
var _time_left: float = 0.0
var _active: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)

func activate(global_pos: Vector2, direction: Vector2, lifetime: float, override_speed: float = -1.0) -> void:
	global_position = global_pos
	_velocity = direction.normalized() * (override_speed if override_speed > 0.0 else speed)
	_time_left = lifetime
	_active = true
	visible = true
	monitoring = true
	set_physics_process(true)

func deactivate() -> void:
	_active = false
	visible = false
	set_deferred("monitoring", false)
	set_physics_process(false)

func _physics_process(dt: float) -> void:
	if not _active:
		return

	global_position += _velocity * dt
	_time_left -= dt
	if _time_left <= 0.0:
		request_despawn.emit(self)

func _on_area_entered(_area: Area2D) -> void:
	request_despawn.emit(self)

func _on_body_entered(_body: Node) -> void:
	request_despawn.emit(self)
