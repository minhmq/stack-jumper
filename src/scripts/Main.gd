extends Node
class_name Main

## Entry point - loads menu

func _ready() -> void:
	# Autoloads should be loaded by now
	# Transition to menu
	get_tree().change_scene_to_file("res://src/scenes/Menu.tscn")

