extends CanvasLayer
class_name HealthBar

@export var player_path: NodePath
@export var health_bar_path: NodePath

@onready var player: Player = get_node(player_path) as Player
@onready var health_bar: ProgressBar = get_node(health_bar_path) as ProgressBar

@export var Boss_path: NodePath
@export var Boss_health_bar_path: NodePath

@onready var Boss: BossShooter = get_node(Boss_path) as BossShooter
@onready var Boss_health_bar: ProgressBar = get_node(Boss_health_bar_path) as ProgressBar


func _ready() -> void:
	# Initialize bar immediately
	health_bar.min_value = 0
	health_bar.max_value = player.max_health
	health_bar.value = player.current_health
	player.healthChanged.connect(_on_player_health_changed)

	# Connect signal
	Boss_health_bar.min_value = 0
	Boss_health_bar.max_value = player.max_health
	Boss_health_bar.value = player.current_health
	Boss.health_changed.connect(_on_Boss_health_changed)

func _on_player_health_changed(current: int, max: int) -> void:
	health_bar.max_value = max
	health_bar.value = current
	
func _on_Boss_health_changed(current: int, max: int) -> void:
	Boss_health_bar.max_value = max
	Boss_health_bar.value = current
