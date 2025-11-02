extends Control
class_name HUD

## Heads-up display with score, best, and pause controls

@onready var score_label: Label = $ScoreLabel
@onready var best_label: Label = $BestLabel
@onready var pause_button: Button = $PauseButton
@onready var pause_panel: Control = $PausePanel

func _ready() -> void:
	setup_ui()
	connect_signals()
	update_display()

func setup_ui() -> void:
	if pause_panel:
		pause_panel.visible = false
	
	var resume_btn = pause_panel.get_node_or_null("VBox/ResumeButton") if pause_panel else null
	if resume_btn:
		resume_btn.pressed.connect(_on_resume_pressed)
	
	var home_btn = pause_panel.get_node_or_null("VBox/HomeButton") if pause_panel else null
	if home_btn:
		home_btn.pressed.connect(_on_home_pressed)
	
	var share_btn = pause_panel.get_node_or_null("VBox/ShareButton") if pause_panel else null
	if share_btn:
		share_btn.pressed.connect(_on_share_pressed)

func connect_signals() -> void:
	GameState.score_changed.connect(_on_score_changed)
	GameState.best_changed.connect(_on_best_changed)
	GameState.state_changed.connect(_on_state_changed)
	
	if pause_button:
		pause_button.pressed.connect(_on_pause_pressed)

func update_display() -> void:
	if score_label:
		score_label.text = "Score: %d" % GameState.score
	if best_label:
		best_label.text = "Best: %d" % GameState.best

func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "Score: %d" % new_score

func _on_best_changed(new_best: int) -> void:
	if best_label:
		best_label.text = "Best: %d" % new_best

func _on_pause_pressed() -> void:
	GameState.pause_game()
	if pause_panel:
		pause_panel.visible = true

func _on_resume_pressed() -> void:
	GameState.resume_game()
	if pause_panel:
		pause_panel.visible = false

func _on_home_pressed() -> void:
	GameState.go_to_menu()
	get_tree().change_scene_to_file("res://src/scenes/Menu.tscn")

func _on_share_pressed() -> void:
	var score_text = "I scored %d in Stack Jumper!" % GameState.score
	var store_link = "https://play.google.com/store/apps/details?id=com.yourgame.stackjumper"  # Placeholder
	
	var share_text = "%s\n\n%s" % [score_text, store_link]
	
	# Use OS shell to share (works on mobile)
	if OS.has_feature("mobile"):
		OS.shell_open("mailto:?subject=Stack%20Jumper%20Score&body=" + share_text.uri_encode())
	else:
		# Desktop fallback: copy to clipboard
		DisplayServer.clipboard_set(share_text)

func _on_state_changed(new_state: String) -> void:
	if new_state == "paused" and pause_panel:
		pause_panel.visible = true
	elif new_state == "playing" and pause_panel:
		pause_panel.visible = false

