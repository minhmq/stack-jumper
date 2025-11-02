extends Node2D
class_name PlatformSpawner

## Spawns platforms with difficulty curve based on score
## Uses object pooling for performance

@export var platform_scene: PackedScene
@export var coin_scene: PackedScene
@export var initial_spawn_y: float = 500.0
@export var min_gap_y: float = 120.0
@export var max_gap_y: float = 220.0
@export var base_platform_width: float = 240.0
@export var min_platform_width: float = 120.0
@export var base_platform_speed: float = 40.0
@export var max_platform_speed: float = 180.0

var last_spawn_y: float = 0.0
var screen_width: float = 1080.0
var platform_pool: ObjectPool
var coin_pool: ObjectPool
var active_platforms: Array[Node2D] = []
var active_coins: Array[Node2D] = []

func _ready() -> void:
	if platform_scene:
		platform_pool = ObjectPool.new(platform_scene, get_tree().current_scene, 10)
	if coin_scene:
		coin_pool = ObjectPool.new(coin_scene, get_tree().current_scene, 5)
	
	last_spawn_y = initial_spawn_y
	screen_width = get_viewport_rect().size.x
	
	GameState.score_changed.connect(_on_score_changed)
	
	# Spawn initial platforms
	for i in range(5):
		spawn_platform()

func _on_score_changed(new_score: int) -> void:
	# Check if we need to spawn more platforms
	spawn_if_needed()

func spawn_if_needed() -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	
	var camera_top = camera.global_position.y - get_viewport_rect().size.y / (2.0 * camera.zoom.y)
	
	# Spawn platforms ahead of camera
	if last_spawn_y > camera_top - 300.0:
		spawn_platform()

func spawn_platform() -> void:
	if not platform_scene or not platform_pool:
		return
	
	var platform = platform_pool.acquire() as Platform
	if not platform:
		return
	
	# Calculate difficulty parameters based on score
	var score = GameState.score
	var difficulty = get_difficulty_for_score(score)
	
	# Spawn position
	var gap_y = lerp(min_gap_y, max_gap_y, difficulty)
	var spawn_y = last_spawn_y - gap_y
	var spawn_x = randf_range(100.0, screen_width - 100.0)
	
	platform.global_position = Vector2(spawn_x, spawn_y)
	
	# Set platform properties
	platform.width = lerp(base_platform_width, min_platform_width, difficulty)
	platform.speed = lerp(base_platform_speed, max_platform_speed, difficulty)
	platform.direction = 1.0 if randf() > 0.5 else -1.0
	platform.platform_type = get_platform_type_for_score(score)
	platform.reset()
	
	active_platforms.append(platform)
	last_spawn_y = spawn_y
	
	# Occasionally spawn a coin
	if coin_scene and coin_pool and randf() < 0.3:
		spawn_coin(platform)

func spawn_coin(platform: Platform) -> void:
	var coin = coin_pool.acquire() as Coin
	if not coin:
		return
	
	coin.global_position = Vector2(
		platform.global_position.x,
		platform.global_position.y - 60.0
	)
	active_coins.append(coin)

func get_difficulty_for_score(score: int) -> float:
	# Returns 0.0 (easy) to 1.0 (hard) based on score
	var max_score = 100.0
	return clamp(float(score) / max_score, 0.0, 1.0)

func get_platform_type_for_score(score: int) -> Platform.PlatformType:
	var rand = randf()
	
	if score < 10:
		return Platform.PlatformType.NORMAL
	elif score < 20:
		# 10% chance for conveyor
		if rand < 0.1:
			return Platform.PlatformType.CONVEYOR_LEFT if randf() < 0.5 else Platform.PlatformType.CONVEYOR_RIGHT
	elif score < 30:
		# 10% conveyor, 10% breakable
		if rand < 0.1:
			return Platform.PlatformType.CONVEYOR_LEFT if randf() < 0.5 else Platform.PlatformType.CONVEYOR_RIGHT
		elif rand < 0.2:
			return Platform.PlatformType.BREAKABLE
	else:
		# 10% conveyor, 10% breakable, 10% bounce
		if rand < 0.1:
			return Platform.PlatformType.CONVEYOR_LEFT if randf() < 0.5 else Platform.PlatformType.CONVEYOR_RIGHT
		elif rand < 0.2:
			return Platform.PlatformType.BREAKABLE
		elif rand < 0.3:
			return Platform.PlatformType.BOUNCE
	
	return Platform.PlatformType.NORMAL

func cleanup_below_y(y: float) -> void:
	var cleanup_offset = 500.0
	
	for i in range(active_platforms.size() - 1, -1, -1):
		var platform = active_platforms[i]
		if not is_instance_valid(platform):
			active_platforms.remove_at(i)
			continue
		
		if platform.global_position.y > y + cleanup_offset:
			if platform_pool:
				platform_pool.release(platform)
			active_platforms.remove_at(i)
	
	for i in range(active_coins.size() - 1, -1, -1):
		var coin = active_coins[i]
		if not is_instance_valid(coin):
			active_coins.remove_at(i)
			continue
		
		if coin.global_position.y > y + cleanup_offset:
			if coin_pool:
				coin_pool.release(coin)
			active_coins.remove_at(i)

func reset() -> void:
	# Return all platforms and coins to pool
	for platform in active_platforms:
		if is_instance_valid(platform) and platform_pool:
			platform_pool.release(platform)
	active_platforms.clear()
	
	for coin in active_coins:
		if is_instance_valid(coin) and coin_pool:
			coin_pool.release(coin)
	active_coins.clear()
	
	last_spawn_y = initial_spawn_y
	# Spawn initial platforms again
	for i in range(5):
		spawn_platform()

