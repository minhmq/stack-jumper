extends Node

## Save system using JSON for local persistence
## Stores best score and user settings (sound, vibration)

const SAVE_PATH = "user://save.json"

var save_data: Dictionary = {
	"best": 0,
	"settings": {
		"sound_enabled": true,
		"vibration_enabled": true
	}
}

func _ready() -> void:
	load_save()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		save_to_file()
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open save file for reading")
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	if parse_result != OK:
		push_error("Failed to parse save JSON: %s" % json.get_error_message())
		return
	
	save_data = json.data

func save_to_file() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file for writing")
		return
	
	var json_string = JSON.stringify(save_data)
	file.store_string(json_string)
	file.close()

func save_best(value: int) -> void:
	save_data["best"] = value
	save_to_file()

func save_settings(settings: Dictionary) -> void:
	save_data["settings"].merge(settings, true)
	save_to_file()

func get_best() -> int:
	return save_data.get("best", 0)

func get_setting(key: String, default_value = null):
	return save_data.get("settings", {}).get(key, default_value)

func set_setting(key: String, value) -> void:
	if not save_data.has("settings"):
		save_data["settings"] = {}
	save_data["settings"][key] = value
	save_to_file()

