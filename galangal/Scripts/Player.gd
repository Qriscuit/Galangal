# Player.gd
extends Node2D
class_name Player

signal hit(damage: int)
signal healthChanged(current: int)

@export var Health : int = 100 
@export var move_speed: float = 650.0
@export var min_x: float = -800.0
@export var max_x: float = 800.0

# Shooting
@export var allowedToShoot: bool = true
@export var fire_cooldown: float = 0.18
@export var projectile_pool_path: NodePath
@export var muzzle_path: NodePath  # child Node2D where bullets spawn from
@export var shot_lifetime: float = 1.6
@export var shot_speed: float = 1200.0

# Identify friend/foe (groups)
@export var player_projectile_group: StringName = &"player_projectiles"
@export var enemy_projectile_group: StringName = &"enemy_projectiles"

# Use your actual pool type name here:
# If your pool script has: class_name ProjectilePool
var _pool: Projectile_Pool
var _muzzle: Node2D
var _fire_timer: float = 0.0

func _ready() -> void:
	_pool = get_node_or_null(projectile_pool_path) as Projectile_Pool
	_muzzle = get_node_or_null(muzzle_path) as Node2D
	if _muzzle == null:
		_muzzle = self

func _physics_process(dt: float) -> void:
	_fire_timer = maxf(0.0, _fire_timer - dt)

	_handle_movement(dt)
	_handle_shooting()
	_handle_shielding()

func _handle_movement(dt: float) -> void:
	var axis := Input.get_action_strength("MoveRight") - Input.get_action_strength("MoveLeft")

	# Node2D movement: manually integrate position
	global_position.x += axis * move_speed * dt

	# Clamp X (keep current Y)
	global_position.x = clampf(global_position.x, min_x, max_x)

func _handle_shooting() -> void:
	if not Input.is_action_pressed("Shoot"):
		return
	if _fire_timer > 0.0:
		return
	if not allowedToShoot:
		return

	_fire_timer = fire_cooldown
	_spawn_player_shot()
	
func _handle_shielding() -> void:
	if Input.is_action_just_pressed("Shield"):
		$Shield.visible = true
		allowedToShoot = false
		return
		
	if Input.is_action_just_released("Shield"):
		$Shield.visible = false
		allowedToShoot = true
		return

func _spawn_player_shot() -> void:
	if _pool == null:
		push_warning("Player: projectile pool not set.")
		return

	var p := _pool.acquire()
	if p == null:
		return

	# Team tagging (important with pooling)
	if p.is_in_group(enemy_projectile_group):
		p.remove_from_group(enemy_projectile_group)
	p.add_to_group(player_projectile_group)

	var spawn_pos := _muzzle.global_position
	var dir := Vector2.UP

	p.activate(spawn_pos, dir, shot_lifetime, shot_speed)

# --------------------------------------------------------------------
# HIT REGISTRATION
# --------------------------------------------------------------------
# Connect Hurtbox (Area2D).area_entered -> this function.
func on_hurtbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group(enemy_projectile_group):
		return

	_take_hit(1)

	# If it's one of our pooled projectiles, despawn it
	if area is Projectile:
		var proj := area as Projectile
		proj.request_despawn.emit(proj)

func _take_hit(damage: int) -> void:
	hit.emit(damage)
	print("Player hit! Damage:", damage)
