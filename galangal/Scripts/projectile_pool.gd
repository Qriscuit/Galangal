# ProjectilePool.gd
extends Node
class_name Projectile_Pool

@export var projectile_scene: PackedScene
@export var prewarm_count: int = 200
@export var max_count: int = 600
@export var container_path: NodePath  # Optional: node that holds active projectiles

var _free: Array[Projectile] = []
var _in_use: Dictionary = {}  # projectile -> true
var _container: Node = null

func _ready() -> void:
	_container = get_node_or_null(container_path)
	if _container == null:
		_container = self

	_prewarm()

func _prewarm() -> void:
	for i in prewarm_count:
		var p := _create_new()
		if p == null:
			break
		_free.append(p)

func _create_new() -> Projectile:
	if projectile_scene == null:
		push_error("ProjectilePool: projectile_scene is not set.")
		return null

	if _free.size() + _in_use.size() >= max_count:
		return null

	var node := projectile_scene.instantiate()
	var p := node as Projectile
	if p == null:
		push_error("ProjectilePool: projectile_scene root must extend Projectile.")
		node.queue_free()
		return null

	_container.add_child(p)
	p.deactivate()
	p.request_despawn.connect(_on_projectile_request_despawn)
	return p

func acquire() -> Projectile:
	var p: Projectile = null
	if _free.size() > 0:
		p = _free.pop_back()
	else:
		p = _create_new()

	if p == null:
		return null

	_in_use[p] = true
	return p

func release(p: Projectile) -> void:
	if p == null:
		return
	if not _in_use.has(p):
		# Already released or not ours
		return

	_in_use.erase(p)
	p.deactivate()
	_free.append(p)

func _on_projectile_request_despawn(p: Projectile) -> void:
	release(p)
