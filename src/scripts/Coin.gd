extends Area2D
class_name Coin

## Collectible coin that awards bonus points

@export var coin_value: int = 5
@export var rotation_speed: float = 3.0

var collected: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	
	# Create visual (simple circle or sprite)
	var collision = $CollisionShape2D
	if collision and collision.shape is CircleShape2D:
		var circle_shape = collision.shape as CircleShape2D
		circle_shape.radius = 15.0
	
	# Create visual representation
	var sprite = get_node_or_null("Sprite2D")
	if not sprite:
		# Use Polygon2D for a simple coin visual
		var polygon = Polygon2D.new()
		polygon.name = "Sprite2D"
		polygon.color = Color(1.0, 0.84, 0.0)  # Gold
		polygon.polygon = _create_coin_shape()
		add_child(polygon)

func _create_coin_shape() -> PackedVector2Array:
	var radius = 15.0
	var points: PackedVector2Array = []
	for i in range(16):
		var angle = (i / 16.0) * TAU
		points.append(Vector2(cos(angle) * radius, sin(angle) * radius))
	return points

func _physics_process(delta: float) -> void:
	rotation += rotation_speed * delta
	
	# Float animation
	var float_offset = sin(Time.get_ticks_msec() / 500.0) * 3.0
	var base_y = global_position.y
	global_position.y = base_y + float_offset

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return
	
	if body is Player:
		collect()

func collect() -> void:
	if collected:
		return
	
	collected = true
	GameState.add_score(coin_value)
	
	# Play sound effect (if available)
	var audio_player = get_node_or_null("AudioStreamPlayer")
	if audio_player:
		audio_player.play()
	
	# Emit particles or effect
	Fx.haptic_light()
	
	# Animate collection
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.2)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_callback(queue_free)

func reset() -> void:
	collected = false
	scale = Vector2.ONE
	modulate = Color.WHITE

