extends Control
class_name Menu

## Main menu scene

@onready var play_button: Button = $VBox/PlayButton
@onready var sound_toggle: CheckBox = $VBox/SoundToggle
@onready var vibration_toggle: CheckBox = $VBox/VibrationToggle
@onready var reset_button: Button = $VBox/ResetButton
@onready var credits_label: Label = $VBox/CreditsLabel

func _ready() -> void:
	setup_ui()
	connect_signals()
	load_settings()

func setup_ui() -> void:
	if play_button:
		play_button.text = "Play"
		play_button.custom_minimum_size = Vector2(300, 80)
	
	if sound_toggle:
		sound_toggle.text = "Sound"
	
	if vibration_toggle:
		vibration_toggle.text = "Vibration"
	
	if reset_button:
		reset_button.text = "Reset Best Score"
	
	if credits_label:
		credits_label.text = "Stack Jumper v1.0.0\nBuilt with Godot 4.3"
		credits_label.add_theme_font_size_override("font_size", 16)

func connect_signals() -> void:
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	
	if sound_toggle:
		sound_toggle.toggled.connect(_on_sound_toggled)
	
	if vibration_toggle:
		vibration_toggle.toggled.connect(_on_vibration_toggled)
	
	if reset_button:
		reset_button.pressed.connect(_on_reset_pressed)

func load_settings() -> void:
	if sound_toggle:
		sound_toggle.button_pressed = Save.get_setting("sound_enabled", true)
	if vibration_toggle:
		vibration_toggle.button_pressed = Save.get_setting("vibration_enabled", true)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/Game.tscn")

func _on_sound_toggled(enabled: bool) -> void:
	Save.set_setting("sound_enabled", enabled)

func _on_vibration_toggled(enabled: bool) -> void:
	Save.set_setting("vibration_enabled", enabled)

func _on_reset_pressed() -> void:
	# Confirm dialog
	var confirm = AcceptDialog.new()
	confirm.dialog_text = "Reset best score to 0?"
	confirm.confirmed.connect(func(): 
		Save.save_best(0)
		GameState.best = 0
		GameState.best_changed.emit(0)
	)
	add_child(confirm)
	confirm.popup_centered()

