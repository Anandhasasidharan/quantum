extends Control

# Main Menu - Entry point of the game

@onready var backend_status_label = $VBoxContainer/BackendStatus

func _ready():
	"""Initialize main menu."""
	print("Main Menu loaded")
	check_backend_status()

func check_backend_status():
	"""Check if backend server is running."""
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_backend_check_completed)

	var url = GameState.backend_url + "/"
	var error = http.request(url)

	if error != OK:
		backend_status_label.text = "Backend: ERROR"
		backend_status_label.modulate = Color.RED

func _on_backend_check_completed(result, response_code, headers, body):
	"""Handle backend check response."""
	if response_code == 200:
		backend_status_label.text = "Backend: Online ✓"
		backend_status_label.modulate = Color.GREEN
		GameState.backend_connected = true
	else:
		backend_status_label.text = "Backend: Offline (Start with ./run.sh)"
		backend_status_label.modulate = Color.ORANGE

func _on_protocols_pressed():
	"""Navigate to Protocols hangar."""
	print("Loading Protocols hangar...")
	get_tree().change_scene_to_file("res://scenes/ProtocolsHangar.tscn")

func _on_algorithms_pressed():
	"""Navigate to Algorithms arsenal."""
	print("Loading Algorithms arsenal...")
	get_tree().change_scene_to_file("res://scenes/AlgorithmsArsenal.tscn")
