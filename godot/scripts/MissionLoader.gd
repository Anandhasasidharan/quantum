extends Node3D

@onready var polling_timer = $PollingTimer
@onready var hud = $HUD
@onready var quantum_updater = $QuantumSpace

var http_request: HTTPRequest
var measure_request: HTTPRequest
var current_mission: String = ""
var simulation_active: bool = false
var eve_active: bool = false
var backend_connected: bool = false
var request_in_flight: bool = false

func _ready():
	current_mission = GameState.get_mission()
	if current_mission.is_empty():
		current_mission = "bb84"

	print("Mission Loader: Starting %s mission" % current_mission.to_upper())
	setup_http_client()
	hud.update_mission_name(current_mission.to_upper())
	hud.update_backend_status("Connecting...")

	# Configure for this mission type
	quantum_updater.setup_for_mission(current_mission)
	hud.setup_for_mission(current_mission)

	# Start mission automatically
	call_deferred("start_mission")

func setup_http_client():
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.timeout = 5.0
	http_request.request_completed.connect(_on_request_completed)

	measure_request = HTTPRequest.new()
	add_child(measure_request)
	measure_request.timeout = 5.0
	measure_request.request_completed.connect(_on_measure_request_completed)

func start_mission():
	print("Starting %s mission with backend..." % current_mission)
	# Eve toggle configuration per mission
	var eve_missions = ["bb84", "e91", "b92"]  # Missions that support Eve eavesdropping
	send_request("start", {"eve_active": eve_active if current_mission in eve_missions else false})

func step_simulation():
	if not simulation_active:
		return

	# Eve support for QKD protocols
	var eve_missions = ["bb84", "e91", "b92"]
	send_request("step", {"eve_active": eve_active if current_mission in eve_missions else false})

func measure_qubit(qubit_id: int = 0):
	if not simulation_active:
		print("Cannot measure - simulation not active")
		return
	if measure_request == null:
		print("Cannot measure - request client not ready")
		return

	print("Measuring qubit %d..." % qubit_id)
	var url = GameState.backend_url + "/measure"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"mission_type": current_mission,
		"qubit_indices": [qubit_id],
		"basis": "rectilinear"
	})

	var error = measure_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		print("Failed to send measurement request")

func send_request(action: String, parameters: Dictionary):
	"""Unified request sender for all backend communication."""
	if request_in_flight:
		# Skip this poll tick rather than colliding requests.
		return

	var url = GameState.backend_url + "/simulate"
	var headers = ["Content-Type: application/json"]
	var body = JSON.stringify({
		"mission_type": current_mission,
		"action": action,
		"parameters": parameters
	})

	request_in_flight = true
	var error = http_request.request(url, headers, HTTPClient.METHOD_POST, body)
	if error != OK:
		request_in_flight = false
		print("Failed to send %s request" % action)
		handle_backend_offline()

func _on_request_completed(_result, response_code, _headers, body):
	request_in_flight = false

	if response_code != 200:
		print("HTTP Error: %d" % response_code)
		if not simulation_active and current_mission != "bb84":
			_switch_to_bb84_fallback("Mission unavailable - switching to stable BB84")
			return
		handle_backend_offline()
		return

	var json = JSON.new()
	var parse_result = json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("JSON parse error")
		handle_backend_offline()
		return

	var data = json.get_data()

	# Start polling on first successful response
	if not simulation_active:
		simulation_active = true
		backend_connected = true
		hud.update_backend_status("Connected")
		print("Mission started! Beginning 200ms polling...")

		if not polling_timer.timeout.is_connected(_on_polling_timeout):
			polling_timer.timeout.connect(_on_polling_timeout)
		polling_timer.wait_time = 0.2
		polling_timer.start()

	# Update visualization with quantum data
	update_visualization(data)

func _on_measure_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		print("Measurement HTTP Error: %d" % response_code)
		if response_code == 0:
			handle_backend_offline()
		return

	var json = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		print("Measurement JSON parse error")
		return

	var data = json.get_data()
	update_visualization(data)

func update_visualization(data):
	"""Unified visualization update dispatcher with educational explanations."""
	print("Updating visualization for %s mission" % current_mission)

	# Extract step information for educational text
	var step_number = data.get("step", 0)
	var mission_data = data.get("mission_data", {})

	# Generate educational step explanations
	generate_step_explanation(step_number, mission_data)

	# Handle Eve attacks for QKD protocols
	var eve_missions = ["bb84", "e91", "b92"]
	if current_mission in eve_missions:
		var eve_active_now = mission_data.get("eve_active", false)
		if eve_active_now:
			if quantum_updater and quantum_updater.has_method("show_eve_attack_enhanced"):
				quantum_updater.show_eve_attack_enhanced()
			if hud and hud.has_method("show_educational_text"):
				hud.show_educational_text("🔴 EVE INTERCEPTING! Quantum state collapsed - errors introduced!")
		else:
			if quantum_updater and quantum_updater.has_method("hide_eve_attack_enhanced"):
				quantum_updater.hide_eve_attack_enhanced()

	# Route to appropriate visualization
	if data.has("qubits"):
		quantum_updater.update_qubits(data["qubits"])

	# Handle mission-specific visualizations
	match current_mission:
		"bb84", "e91", "b92":
			handle_protocol_visualization(mission_data)
		"grover":
			handle_grover_visualization(mission_data)
		"shor":
			handle_shor_visualization(mission_data)

	if data.has("mission_data"):
		hud.update_mission_data(data["mission_data"])

	if data.has("step"):
		hud.update_step(data["step"])

	if data.has("measurements"):
		print("Measurement results: %s" % str(data["measurements"]))

func generate_step_explanation(step: int, mission_data: Dictionary):
	"""Generate educational step-by-step explanations."""
	var explanation = ""

	match current_mission:
		"bb84":
			explanation = get_bb84_explanation(step, mission_data)
		"e91":
			explanation = get_e91_explanation(step, mission_data)
		"b92":
			explanation = get_b92_explanation(step, mission_data)
		"grover":
			explanation = get_grover_explanation(step, mission_data)
		"shor":
			explanation = get_shor_explanation(step, mission_data)

	if not explanation.is_empty():
		if quantum_updater and quantum_updater.has_method("update_step_text"):
			quantum_updater.update_step_text(explanation)
		if hud and hud.has_method("show_educational_text"):
			hud.show_educational_text(explanation)

func get_bb84_explanation(step: int, data: Dictionary) -> String:
	"""Get clean BB84 protocol step explanations."""
	var eve_enabled = data.get("eve_active", false)

	match step % 4:
		1:
			return "STEP 1: Alice Prepares Qubits"
		2:
			if eve_enabled:
				return "STEP 2: Eve Intercepts - Errors Introduced!"
			else:
				return "STEP 2: Qubits Travel Through Channel"
		3:
			return "STEP 3: Bob Measures Qubits"
		0:
			var error_rate = data.get("error_rate", 0.0)
			if error_rate > 0.11:
				return "STEP 4: Sifting - EVE DETECTED (%.1f%% errors)" % (error_rate * 100)
			else:
				return "STEP 4: Sifting Complete - Secure Key!"
	return ""

func get_e91_explanation(step: int, data: Dictionary) -> String:
	"""Get clean E91 entanglement protocol explanations."""
	var chsh_value = data.get("chsh_value", 0.0)
	var violation = data.get("chsh_violation", false)

	match step % 6:
		1:
			return "STEP 1: Creating Entangled Bell Pairs"
		2:
			return "STEP 2: Alice Measures at Angle θ₁"
		3:
			return "STEP 3: Bob Measures at Angle θ₂"
		4:
			return "STEP 4: Computing Quantum Correlations"
		5:
			if violation:
				return "STEP 5: CHSH = %.2f - Bell Inequality VIOLATED!" % chsh_value
			else:
				return "STEP 5: CHSH = %.2f - Classical Result" % chsh_value
		0:
			return "STEP 6: Generating Secure Key"
	return ""

func get_b92_explanation(step: int, data: Dictionary) -> String:
	"""Get clean B92 protocol explanations."""
	var detection_rate = data.get("detection_rate", 0.0)
	var photon_count = data.get("photon_count", 0)

	if step % 3 == 1:
		return "STEP 1: Alice Sends Non-Orthogonal Photon"
	elif step % 3 == 2:
		return "STEP 2: Bob Measures in Random Basis"
	else:
		return "STEP 3: Detection Rate %.1f%% (%d photons)" % [detection_rate * 100, photon_count]

func get_grover_explanation(step: int, data: Dictionary) -> String:
	"""Get clean Grover's algorithm step explanations."""
	var iteration = data.get("current_iteration", 0)
	var target_item = data.get("target_item", -1)

	match step % 3:
		1:
			if target_item >= 0:
				quantum_updater.flash_oracle_enhanced(target_item)
			return "Oracle: Marking Target Item %d (Phase Flip)" % target_item
		2:
			return "Diffusion: Amplifying Target Probability"
		0:
			return "Grover Iteration %d/3 Complete" % iteration
	return ""

func get_shor_explanation(step: int, data: Dictionary) -> String:
	"""Get clean Shor's algorithm step explanations."""
	var period = data.get("period", null)
	var factors = data.get("factors", [])
	var iteration = data.get("iteration", 0)

	match step % 5:
		1:
			return "STEP 1: Creating Quantum Superposition"
		2:
			return "STEP 2: Modular Exponentiation (Finding Period)"
		3:
			quantum_updater.show_qft_portal_enhanced()
			return "STEP 3: QFT Extracting Period Structure"
		4:
			if period:
				return "STEP 4: Period Found - r = %d" % period
			else:
				return "STEP 4: Measuring QFT Output (Attempt %d)" % iteration
		0:
			if factors.size() > 0:
				return "SUCCESS! Factors: %d × %d = 15 - RSA Broken!" % [factors[0], factors[1]]
			else:
				return "STEP 5: Classical Post-Processing"
	return ""

func handle_protocol_visualization(data: Dictionary):
	"""Handle enhanced QKD protocol visualizations with sifting and key bits."""
	# Animate photon flight periodically with enhanced effects
	if Time.get_ticks_msec() % 3000 < 100:  # Every 3 seconds
		if quantum_updater and quantum_updater.has_method("animate_photon_flight_enhanced"):
			quantum_updater.animate_photon_flight_enhanced()

	# Handle BB84 specific visualizations
	if current_mission == "bb84":
		# Show sifting results if available
		if data.has("sifting_matches"):
			if quantum_updater and quantum_updater.has_method("show_sifting_results"):
				quantum_updater.show_sifting_results(data["sifting_matches"])

		# Show key bits if available
		if data.has("key_bits"):
			if quantum_updater and quantum_updater.has_method("show_key_bits"):
				quantum_updater.show_key_bits(data["key_bits"])

	# Handle E91 specific visualizations
	if current_mission == "e91":
		var chsh_value = data.get("chsh_value", 2.0)
		if quantum_updater and quantum_updater.has_method("update_chsh_meter"):
			quantum_updater.update_chsh_meter(chsh_value)

		# Animate Bell pair creation periodically
		if Time.get_ticks_msec() % 4000 < 100:
			if quantum_updater and quantum_updater.has_method("animate_bell_pair_creation"):
				quantum_updater.animate_bell_pair_creation()

		# Show Eve cutting beam if active
		var eve_enabled = data.get("eve_active", false)
		if eve_enabled and Time.get_ticks_msec() % 5000 < 100:
			if quantum_updater and quantum_updater.has_method("show_eve_cutting_beam"):
				quantum_updater.show_eve_cutting_beam()

func handle_grover_visualization(data: Dictionary):
	"""Handle enhanced Grover's algorithm visualization with probability bars."""
	if data.has("database_items"):
		if quantum_updater and quantum_updater.has_method("update_database_grid"):
			quantum_updater.update_database_grid(data["database_items"])

		# Extract probabilities and update bars
		var probabilities = []
		for item in data["database_items"]:
			probabilities.append(item.get("probability", 0.0))

		if quantum_updater and quantum_updater.has_method("update_probability_bars"):
			quantum_updater.update_probability_bars(probabilities)

	# Flash oracle on certain steps with enhanced effects
	var target_item = data.get("target_item", -1)
	if target_item >= 0 and Time.get_ticks_msec() % 2000 < 100:
		if quantum_updater and quantum_updater.has_method("flash_oracle_enhanced"):
			quantum_updater.flash_oracle_enhanced(target_item)

	# Check for measurement collapse
	var final_measurement = data.get("final_measurement", false)
	if final_measurement:
		if quantum_updater and quantum_updater.has_method("animate_measurement_collapse"):
			quantum_updater.animate_measurement_collapse()

func handle_shor_visualization(data: Dictionary):
	"""Handle enhanced Shor's algorithm visualization with portal fly-through."""
	var period = data.get("period", null)
	var factors = data.get("factors", [])
	var qft_step = data.get("qft_active", false)

	# Show QFT portal when active
	if qft_step or period:
		if quantum_updater and quantum_updater.has_method("show_qft_portal_enhanced"):
			quantum_updater.show_qft_portal_enhanced()

		# Animate portal fly-through
		if Time.get_ticks_msec() % 6000 < 100:
			if quantum_updater and quantum_updater.has_method("animate_portal_fly_through"):
				quantum_updater.animate_portal_fly_through()

	# Show factor discovery and collapse landscape
	if factors.size() > 0:
		if quantum_updater and quantum_updater.has_method("collapse_landscape_to_peaks"):
			quantum_updater.collapse_landscape_to_peaks()

	# Show factor discovery when factors found
	if factors.size() > 0:
		if quantum_updater and quantum_updater.has_method("show_factor_discovery"):
			quantum_updater.show_factor_discovery()

func _on_polling_timeout():
	step_simulation()

func handle_backend_offline():
	backend_connected = false
	simulation_active = false
	hud.update_backend_status("Backend offline - start backend/run.sh")
	if hud and hud.has_method("show_educational_text"):
		hud.show_educational_text("Backend offline. Start backend and return to mission.")

	if polling_timer.timeout.is_connected(_on_polling_timeout):
		polling_timer.stop()

	print("Backend offline. Run './run.sh' to start backend.")

func _switch_to_bb84_fallback(message: String):
	print(message)
	current_mission = "bb84"
	GameState.set_mission("bb84", "protocol")
	hud.update_mission_name("BB84")
	hud.setup_for_mission("bb84")
	quantum_updater.setup_for_mission("bb84")
	hud.update_backend_status("Fallback: BB84")
	if hud and hud.has_method("show_educational_text"):
		hud.show_educational_text("Fallback active: BB84 is loaded for demo stability.")
	start_mission()

func _unhandled_input(event):
	# Eve toggle (QKD protocols only)
	var eve_missions = ["bb84", "e91", "b92"]
	if event.is_action_pressed("toggle_eve") and current_mission in eve_missions:
		eve_active = not eve_active
		hud.update_eve_status(eve_active)
		print("Eve eavesdropping: %s" % ("ACTIVE" if eve_active else "INACTIVE"))

	# Measure qubit
	if event.is_action_pressed("measure_qubit"):
		if simulation_active:
			match current_mission:
				"bb84":
					measure_qubit(0)  # BB84: measure single qubit
				"e91":
					print("E91: Measuring Bell pair...")
					measure_qubit(0)  # E91: measure entangled qubit
				"b92":
					print("B92: Measuring photon state...")
					measure_qubit(0)  # B92: measure photon
				"grover":
					print("Grover: Performing final database measurement...")
					measure_qubit(0)  # Grover: trigger final measurement
				"shor":
					print("Shor: Measuring QFT register...")
					measure_qubit(0)  # Shor: measure QFT output
		else:
			print("Cannot measure - backend not connected")

func get_simulation_status() -> Dictionary:
	return {
		"mission": current_mission,
		"active": simulation_active,
		"connected": backend_connected,
		"eve_active": eve_active
	}

func _exit_tree():
	request_in_flight = false
	if polling_timer:
		polling_timer.stop()
