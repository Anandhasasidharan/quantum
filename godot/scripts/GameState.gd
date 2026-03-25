extends Node

# Global game state - autoloaded singleton
# Stores current mission selection and backend connection info

var current_mission: String = ""
var current_mission_type: String = ""  # "protocol" or "algorithm"
var backend_url: String = "http://localhost:8000"
var backend_connected: bool = false

func set_mission(mission_name: String, mission_type: String):
	"""Set the current mission to load."""
	current_mission = mission_name
	current_mission_type = mission_type
	print("GameState: Mission set to %s (%s)" % [mission_name, mission_type])

func get_mission() -> String:
	return current_mission

func check_backend() -> bool:
	"""Check if backend is running."""
	# This will be implemented in MissionLoader
	return backend_connected
