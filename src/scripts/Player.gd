extends CharacterBody2D
class_name Player

## Player character with jump, double-jump, coyote time, and jump buffering

signal landed_on_platform(platform: Node2D)
signal fell_below_camera

@export var move_speed: float = 0.0  # Horizontal movement (optional air control)
@export var jump_force: float = 600.0
@export var double_jump_enabled: bool = true
@export var coyote_time_ms: float = 150.0  # Grace period after leaving platform
@export var jump_buffer_ms: float = 100.0  # Grace period before landing

@export var gravity: float = 1500.0
@export var max_fall_speed: float = 1000.0

var on_ground: bool = false
var has_double_jumped: bool = false
var coyote_time_remaining: float = 0.0
var jump_buffer_remaining: float = 0.0
var last_platform_landed: Node2D = null

var camera: Camera2D
var camera_bottom_y: float = 0.0

func _ready() -> void:
	camera = get_viewport().get_camera_2d()
	if camera:
		camera_bottom_y = global_position.y + get_viewport_rect().size.y / camera.zoom.y

func _physics_process(delta: float) -> void:
	# Update coyote time and jump buffer
	if on_ground:
		coyote_time_remaining = coyote_time_ms / 1000.0
		has_double_jumped = false
	else:
		coyote_time_remaining -= delta
		coyote_time_remaining = max(0.0, coyote_time_remaining)
	
	if jump_buffer_remaining > 0.0:
		jump_buffer_remaining -= delta
		jump_buffer_remaining = max(0.0, jump_buffer_remaining)
	
	# Apply gravity
	if not on_ground:
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, max_fall_speed)
	
	# Handle input
	if Input.is_action_just_pressed("ui_tap"):
		if on_ground or coyote_time_remaining > 0.0:
			# Normal jump
			jump()
			coyote_time_remaining = 0.0
			jump_buffer_remaining = 0.0
		elif double_jump_enabled and not has_double_jumped:
			# Double jump
			jump()
			has_double_jumped = true
		else:
			# Buffer jump for next landing
			jump_buffer_remaining = jump_buffer_ms / 1000.0
	
	# Try buffered jump
	if on_ground and jump_buffer_remaining > 0.0:
		jump()
		jump_buffer_remaining = 0.0
	
	# Optional: horizontal air control toward platform center
	if not on_ground and move_speed > 0.0:
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction != 0.0:
			velocity.x = move_toward(velocity.x, direction * move_speed, move_speed * delta)
		else:
			velocity.x = move_toward(velocity.x, 0.0, move_speed * delta)
	
	# Move
	move_and_slide()
	
	# Check ground collision
	var was_on_ground = on_ground
	on_ground = is_on_floor()
	
	# Detect landing on new platform
	if on_ground and not was_on_ground:
		var collision_count = get_slide_collision_count()
		if collision_count > 0:
			var collision = get_slide_collision(0)
			var platform = collision.get_collider()
			if platform and platform != last_platform_landed:
				landed_on_platform.emit(platform)
				last_platform_landed = platform
	
	# Check if fell below camera
	if camera:
		var camera_bottom = camera.global_position.y + get_viewport_rect().size.y / (2.0 * camera.zoom.y)
		if global_position.y > camera_bottom + 100.0:
			fell_below_camera.emit()
	
	# Optional: limit fall speed to prevent glitches
	velocity.y = clamp(velocity.y, -1000.0, max_fall_speed)

func jump() -> void:
	velocity.y = -jump_force
	if $AudioStreamPlayer:
		$AudioStreamPlayer.play()
	Fx.haptic_light()

func reset() -> void:
	velocity = Vector2.ZERO
	on_ground = false
	has_double_jumped = false
	coyote_time_remaining = 0.0
	jump_buffer_remaining = 0.0
	last_platform_landed = null

