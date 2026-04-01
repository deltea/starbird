@tool
extends Node

const SAVE_FILE_PATH = "user://save.json"

@export_tool_button("Delete user data", "Remove") var delete_user_data_button = Callable(self, "delete_data")

var data = {}

func _enter_tree() -> void:
	data = load_game()

func get_level_data(level_name: String):
	if data["levels"].has(level_name):
		return data["levels"][level_name]
	else:
		return null

func save_level(level_name: String, stars_collected: int, time: float):
	var level_data = data["levels"].get(level_name, { "time": INF, "stars": 0 })
	level_data["stars"] = max(stars_collected, level_data["stars"])

	# only save time if all stars are collected
	if stars_collected == 5:
		level_data["time"] = min(time, level_data["time"])
	data["levels"][level_name] = level_data

	# count total stars
	var total_stars = 0
	for level in data["levels"]:
		total_stars += data["levels"][level]["stars"]
	data["total_stars"] = total_stars

func save_game():
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	save_file.store_string(JSON.stringify(data))
	print("saved!")

func load_game():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("save file not found, creating new save")
		return {
			"levels": {},
			"has_seen_cutscene": false,
			"next_level": 0,
			"current_level": 0,
			"total_stars": 0,
		}

	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	var content = save_file.get_as_text()
	data = JSON.parse_string(content)
	print("save loaded")
	print(JSON.parse_string(content))
	return JSON.parse_string(content)

func delete_data():
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print("save deleted")
	else:
		print("no save file to delete")
