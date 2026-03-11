extends Node

const SAVE_FILE_PATH = "user://save.json"

var data = {}

func _ready() -> void:
	data = load_game()

func get_level_data(level_name: String):
	if data["levels"].has(level_name):
		return data["levels"][level_name]
	else:
		return null

func save_level(level_name: String, stars_collected: int, time: float):
	if time < data["levels"][level_name]["time"]:
		data["levels"][level_name]["time"] = time
	elif stars_collected > data["levels"][level_name]["stars"]:
		data["levels"][level_name]["stars"] = stars_collected
	save_game()

func save_game():
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(data))
	print("saved!")

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		printerr("save file not found")
		return {
			"levels": {},
			"has_seen_cutscene": false
		}

	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var content = save_file.get_as_text()
	print("save loaded")
	print(JSON.parse_string(content))
	return JSON.parse_string(content)
