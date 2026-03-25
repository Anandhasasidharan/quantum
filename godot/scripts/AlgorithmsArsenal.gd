extends Control

# Algorithms Arsenal - Select quantum attack algorithms

func _ready():
	print("Algorithms Arsenal loaded")

func _on_back_pressed():
	"""Return to main menu."""
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_grover_launch():
	"""Launch Grover's Algorithm mission."""
	print("Launching Grover's Search mission...")
	GameState.set_mission("grover", "algorithm")
	get_tree().change_scene_to_file("res://scenes/DroneMission.tscn")

func _on_shor_launch():
	"""Launch Shor's Algorithm mission."""
	print("Launching Shor's Algorithm mission...")
	GameState.set_mission("shor", "algorithm")
	get_tree().change_scene_to_file("res://scenes/DroneMission.tscn")