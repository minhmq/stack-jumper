extends Node
class_name Fx

## Visual and audio effects helper
## Camera shake, particles, squash/stretch animations

static func shake_camera(camera: Camera2D, intensity: float, duration: float) -> void:
	if not camera:
		return
	
	var original_offset = camera.offset
	
	# Create a timer node for shake updates
	var shake_timer = Timer.new()
	camera.add_child(shake_timer)
	shake_timer.wait_time = 0.02  # Update every 20ms (~50fps)
	shake_timer.one_shot = false
	shake_timer.timeout.connect(func():
		if is_instance_valid(camera):
			var shake = Vector2(
				randf_range(-intensity, intensity),
				randf_range(-intensity, intensity)
			)
			camera.offset = original_offset + shake
	)
	
	# Start shaking
	shake_timer.start()
	
	# Stop and clean up after duration
	var cleanup_timer = Timer.new()
	camera.add_child(cleanup_timer)
	cleanup_timer.wait_time = duration
	cleanup_timer.one_shot = true
	cleanup_timer.timeout.connect(func():
		if is_instance_valid(camera):
			camera.offset = original_offset
		if is_instance_valid(shake_timer):
			shake_timer.queue_free()
		cleanup_timer.queue_free()
	)
	cleanup_timer.start()

static func squash_and_stretch(node: Node2D, x_scale: float, y_scale: float, duration: float = 0.15) -> void:
	if not node:
		return
	
	var original_scale = node.scale
	var tween = node.create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(node, "scale", Vector2(x_scale, y_scale) * original_scale, duration / 2)
	tween.tween_property(node, "scale", original_scale, duration / 2)

static func emit_land_particles(particles: GPUParticles2D, position: Vector2) -> void:
	if not particles:
		return
	
	particles.global_position = position
	particles.restart()

static func haptic_light() -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(50)  # 50ms vibration

static func haptic_medium() -> void:
	if OS.has_feature("mobile"):
		Input.vibrate_handheld(100)  # 100ms vibration

