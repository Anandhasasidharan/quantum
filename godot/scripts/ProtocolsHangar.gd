extends Control

# Protocols Hangar - Select quantum defense missions

func _ready():
	print("Protocols Hangar loaded")

func _on_back_pressed():
	"""Return to main menu."""
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_bb84_launch():
	"""Launch BB84 mission."""
	print("Launching BB84 mission...")
	GameState.set_mission("bb84", "protocol")
	get_tree().change_scene_to_file("res://scenes/DroneMission.tscn")

func _on_e91_launch():
	"""Launch E91 mission."""
	print("Launching E91 mission...")
	GameState.set_mission("e91", "protocol")
	get_tree().change_scene_to_file("res://scenes/DroneMission.tscn")

func _on_b92_launch():
	"""Launch B92 mission."""
	print("Launching B92 mission...")
	GameState.set_mission("b92", "protocol")
	get_tree().change_scene_to_file("res://scenes/DroneMission.tscn")
