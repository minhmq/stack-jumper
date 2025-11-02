extends StaticBody2D
class_name Platform

## Platform with variants: NORMAL, CONVEYOR, BREAKABLE, BOUNCE

enum PlatformType {
	NORMAL,
	CONVEYOR_LEFT,
	CONVEYOR_RIGHT,
	BREAKABLE,
	BOUNCE
}

@export var platform_type: PlatformType = PlatformType.NORMAL
@export var width: float = 200.0
@export var speed: float = 80.0  # Horizontal movement speed
@export var direction: float = 1.0  # -1 or 1
@export var lifetime_on_break: float = 0.3  # Time before breakable platform disappears

var has_landed: bool = false
var bounding_rect: Rect2

func _ready() -> void:
	setup_platform()
	update_bounding_rect()

func setup_platform() -> void:
	# Setup collision shape
	var collision = $CollisionShape2D
	if collision and collision.shape is RectangleShape2D:
		var rect_shape = collision.shape as RectangleShape2D
		rect_shape.size = Vector2(width, 20.0)
	
	# Setup visual
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		sprite = Polygon2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
		sprite.position = Vector2.ZERO
	
	if sprite is Sprite2D:
		# Use simple colored rectangle
		var image = Image.create(int(width), 20, false, Image.FORMAT_RGBA8)
		var color = get_platform_color()
		image.fill(color)
		var texture = ImageTexture.create_from_image(image)
		sprite.texture = texture
		sprite.centered = true
	elif sprite is Polygon2D:
		# Use Polygon2D for colored rectangle
		sprite.color = get_platform_color()
		sprite.polygon = PackedVector2Array([
			Vector2(-width/2, -10),
			Vector2(width/2, -10),
			Vector2(width/2, 10),
			Vector2(-width/2, 10)
		])

func get_platform_color() -> Color:
	match platform_type:
		PlatformType.NORMAL:
			return Color(0.3, 0.7, 0.9, 1.0)  # Blue
		PlatformType.CONVEYOR_LEFT, PlatformType.CONVEYOR_RIGHT:
			return Color(0.9, 0.6, 0.2, 1.0)  # Orange
		PlatformType.BREAKABLE:
			return Color(0.8, 0.3, 0.3, 1.0)  # Red
		PlatformType.BOUNCE:
			return Color(0.4, 0.9, 0.4, 1.0)  # Green
		_:
			return Color.WHITE

func update_bounding_rect() -> void:
	bounding_rect = Rect2(
		global_position.x - width/2,
		global_position.y - 10,
		width,
		20
	)

func _physics_process(delta: float) -> void:
	# Move horizontally
	if platform_type == PlatformType.CONVEYOR_LEFT:
		global_position.x -= speed * delta
		direction = -1.0
	elif platform_type == PlatformType.CONVEYOR_RIGHT:
		global_position.x += speed * delta
		direction = 1.0
	else:
		global_position.x += speed * direction * delta
	
	update_bounding_rect()
	
	# Wrap around screen edges (rough approximation)
	var screen_width = 1080.0  # Match project settings
	if global_position.x > screen_width + width/2:
		global_position.x = -width/2
	elif global_position.x < -width/2:
		global_position.x = screen_width + width/2

func on_player_landed(player: CharacterBody2D) -> void:
	if has_landed:
		return
	
	has_landed = true
	
	match platform_type:
		PlatformType.CONVEYOR_LEFT:
			# Apply horizontal push to player
			if player:
				player.velocity.x = min(player.velocity.x - 50.0, -100.0)
		PlatformType.CONVEYOR_RIGHT:
			if player:
				player.velocity.x = max(player.velocity.x + 50.0, 100.0)
		PlatformType.BREAKABLE:
			# Schedule break
			var tween = create_tween()
			tween.tween_callback(func(): queue_free()).set_delay(lifetime_on_break)
			modulate = Color(0.5, 0.5, 0.5, 1.0)  # Fade out
		PlatformType.BOUNCE:
			# Give extra jump force
			if player:
				player.velocity.y = -800.0  # Stronger bounce

func reset() -> void:
	has_landed = false
	modulate = Color.WHITE

func get_center_x() -> float:
	return global_position.x

