extends Node2D
class_name Game

## Main game scene manager

@onready var player: Player = $Player
@onready var platform_spawner: PlatformSpawner = $PlatformSpawner
@onready var camera: Camera2D = $Camera2D
@onready var hud: Control = $CanvasLayer/HUD
@onready var background: ColorRect = $Background

var game_over_panel: Control
var gradient_colors: Array[Color] = [
	Color(0.2, 0.4, 0.8),
	Color(0.4, 0.6, 0.9),
	Color(0.6, 0.8, 0.9),
	Color(0.5, 0.7, 0.9)
]
var current_gradient_index: int = 0

func _ready() -> void:
	setup_camera()
	setup_background()
	connect_signals()
	GameState.new_run()

func setup_camera() -> void:
	if camera:
		camera.position_smoothing_enabled = true
		camera.position_smoothing_speed = 5.0
		camera.limit_left = -1000
		camera.limit_right = 2000
		camera.global_position = player.global_position

func setup_background() -> void:
	if background:
		background.color = gradient_colors[0]
		background.mouse_filter = Control.MOUSE_FILTER_IGNORE
		background.anchors_preset = Control.PRESET_FULL_RECT

func connect_signals() -> void:
	if player:
		player.landed_on_platform.connect(_on_player_landed)
		player.fell_below_camera.connect(_on_player_fell)
	
	GameState.state_changed.connect(_on_state_changed)

func _process(delta: float) -> void:
	if not GameState.is_playing():
		return
	
	# Update camera to follow player
	if camera and player:
		var target_y = player.global_position.y - 400.0  # Keep player in upper portion
		camera.global_position.y = lerp(camera.global_position.y, target_y, delta * 2.0)
		
		# Cleanup platforms below camera
		var camera_bottom = camera.global_position.y + get_viewport_rect().size.y / (2.0 * camera.zoom.y)
		if platform_spawner:
			platform_spawner.cleanup_below_y(camera_bottom)
	
	# Update background gradient based on score
	update_background_gradient()

func update_background_gradient() -> void:
	if not background:
		return
	
	var score = GameState.score
	var color_index = int(score / 20) % gradient_colors.size()
	var next_index = (color_index + 1) % gradient_colors.size()
	var t = float(score % 20) / 20.0
	
	background.color = gradient_colors[color_index].lerp(gradient_colors[next_index], t)

func _on_player_landed(platform: Platform) -> void:
	# Add score
	GameState.add_score(1)
	
	# Trigger platform-specific behavior
	if platform:
		platform.on_player_landed(player)
	
	# Effects
	if camera:
		Fx.shake_camera(camera, 2.0, 0.1)
	if player:
		Fx.squash_and_stretch(player, 1.2, 0.8, 0.15)
	
	# Play landing sound
	var audio = get_node_or_null("AudioStreamPlayer")
	if audio and Save.get_setting("sound_enabled", true):
		audio.play()
	
	Fx.haptic_light()
	
	# Check if spawner needs to create more platforms
	if platform_spawner:
		platform_spawner.spawn_if_needed()

func _on_player_fell() -> void:
	game_over()

func game_over() -> void:
	GameState.end_run()
	show_game_over_panel()

func show_game_over_panel() -> void:
	# Create or show game over UI
	if not game_over_panel:
		create_game_over_panel()
	
	if game_over_panel:
		game_over_panel.visible = true

func create_game_over_panel() -> void:
	game_over_panel = preload("res://src/scenes/GameOverPanel.tscn").instantiate() if ResourceLoader.exists("res://src/scenes/GameOverPanel.tscn") else null
	
	if not game_over_panel:
		# Create simple game over panel programmatically
		game_over_panel = Control.new()
		game_over_panel.name = "GameOverPanel"
		game_over_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		var vbox = VBoxContainer.new()
		vbox.anchors_preset = Control.PRESET_CENTER
		vbox.offset_left = -200
		vbox.offset_top = -300
		vbox.offset_right = 200
		vbox.offset_bottom = 300
		
		var title = Label.new()
		title.text = "GAME OVER"
		title.add_theme_font_size_override("font_size", 48)
		
		var score_label = Label.new()
		score_label.name = "ScoreLabel"
		score_label.text = "Score: %d" % GameState.score
		
		var best_label = Label.new()
		best_label.name = "BestLabel"
		best_label.text = "Best: %d" % GameState.best
		
		var retry_btn = Button.new()
		retry_btn.text = "Retry"
		retry_btn.pressed.connect(_on_retry_pressed)
		
		var home_btn = Button.new()
		home_btn.text = "Home"
		home_btn.pressed.connect(_on_home_pressed)
		
		vbox.add_child(title)
		vbox.add_child(score_label)
		vbox.add_child(best_label)
		vbox.add_child(retry_btn)
		vbox.add_child(home_btn)
		
		game_over_panel.add_child(vbox)
		hud.add_child(game_over_panel)
	
	game_over_panel.visible = true

func _on_retry_pressed() -> void:
	get_tree().reload_current_scene()

func _on_home_pressed() -> void:
	GameState.go_to_menu()
	get_tree().change_scene_to_file("res://src/scenes/Menu.tscn")

func _on_state_changed(new_state: String) -> void:
	if new_state == "menu":
		get_tree().change_scene_to_file("res://src/scenes/Menu.tscn")

