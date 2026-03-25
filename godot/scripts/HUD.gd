extends CanvasLayer

@onready var mission_name_label = $Container/TopLeft/MissionName
@onready var step_label = $Container/TopLeft/StepLabel
@onready var error_rate_label = $Container/TopLeft/ErrorRate
@onready var key_bits_label = $Container/TopLeft/KeyBits
@onready var eve_status_label = $Container/TopLeft/EveStatus
@onready var backend_status_label = $Container/TopRight/BackendStatus

# Mission-specific UI elements
@onready var controls_label = $Container/BottomCenter/Controls

# Educational elements
var educational_text_label: RichTextLabel
var educational_panel: PanelContainer

# Drone POV title
var drone_pov_label: Label

const COLOR_SUCCESS = Color.GREEN
const COLOR_WARNING = Color.ORANGE
const COLOR_DANGER = Color.RED
const COLOR_INFO = Color.CYAN
const COLOR_NEUTRAL = Color.WHITE
const COLOR_DISABLED = Color.GRAY
const COLOR_EDUCATIONAL = Color.YELLOW

var current_mission: String = "bb84"

func _ready():
	print("HUD System initialized")
	create_educational_display()
	create_drone_pov_title()

func create_drone_pov_title():
	"""Create 'Drone POV' title in top-left corner."""
	drone_pov_label = Label.new()
	drone_pov_label.text = "DRONE POV"
	drone_pov_label.position = Vector2(20, 20)

	# Styling for visibility and consistency
	drone_pov_label.add_theme_font_size_override("font_size", 28)
	drone_pov_label.add_theme_color_override("font_color", Color(0.4, 0.9, 1.0, 0.9))  # Cyan with slight transparency
	drone_pov_label.add_theme_color_override("font_outline_color", Color.BLACK)
	drone_pov_label.add_theme_constant_override("outline_size", 8)

	# Add subtle background for readability
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0, 0, 0, 0.6)
	style_box.corner_radius_top_left = 8
	style_box.corner_radius_top_right = 8
	style_box.corner_radius_bottom_left = 8
	style_box.corner_radius_bottom_right = 8
	style_box.content_margin_left = 10
	style_box.content_margin_right = 10
	style_box.content_margin_top = 5
	style_box.content_margin_bottom = 5
	drone_pov_label.add_theme_stylebox_override("normal", style_box)

	add_child(drone_pov_label)
	print("Drone POV title created at top-left corner")

func create_educational_display():
	"""Create enhanced educational text display for step explanations."""
	# Create panel for educational text - positioned at bottom center for better visibility
	educational_panel = PanelContainer.new()
	educational_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	educational_panel.position = Vector2(200, -250)  # Bottom center positioning
	educational_panel.size = Vector2(1000, 220)  # Larger size for better readability

	# Enhanced panel styling with stronger background
	var panel_theme = StyleBoxFlat.new()
	panel_theme.bg_color = Color(0, 0, 0, 0.92)  # Stronger background alpha
	panel_theme.border_width_left = 4
	panel_theme.border_width_right = 4
	panel_theme.border_width_top = 4
	panel_theme.border_width_bottom = 4
	panel_theme.border_color = COLOR_EDUCATIONAL
	panel_theme.corner_radius_top_left = 15
	panel_theme.corner_radius_top_right = 15
	panel_theme.corner_radius_bottom_left = 15
	panel_theme.corner_radius_bottom_right = 15
	# Add subtle inner shadow effect
	panel_theme.shadow_color = Color(0, 0, 0, 0.5)
	panel_theme.shadow_size = 8
	panel_theme.shadow_offset = Vector2(0, 2)
	educational_panel.add_theme_stylebox_override("panel", panel_theme)

	# Create rich text label with enhanced styling
	educational_text_label = RichTextLabel.new()
	educational_text_label.autowrap_mode = 3  # AUTOWRAP_WORD_SMART
	educational_text_label.size = Vector2(960, 180)  # Larger text area
	educational_text_label.position = Vector2(20, 20)  # Padding from panel edges
	# Enable BBCode for rich formatting
	educational_text_label.bbcode_enabled = true
	educational_panel.add_child(educational_text_label)

	# Initially hidden
	educational_panel.visible = false
	add_child(educational_panel)

func setup_for_mission(mission_type: String):
	"""Configure HUD for specific mission type."""
	current_mission = mission_type.to_lower()

	update_mission_name(mission_type.to_upper())
	update_backend_status("Initializing...")

	# Mission-specific UI setup
	match current_mission:
		"bb84":
			setup_bb84_hud()
		"e91":
			setup_e91_hud()
		"b92":
			setup_b92_hud()
		"grover":
			setup_grover_hud()
		"shor":
			setup_shor_hud()

	print("HUD configured for %s mission" % mission_type.to_upper())

func setup_bb84_hud():
	"""Configure HUD for BB84 protocol."""
	update_step(0)
	update_error_rate(0.0)
	update_sifted_key([])
	update_eve_status(false)

	# Update controls text for BB84
	controls_label.text = "WASD: Move | Mouse: Look | SPACE: Measure | E: Toggle Eve | ESC: Exit"

func setup_grover_hud():
	"""Configure HUD for Grover's algorithm."""
	# Repurpose labels for Grover
	step_label.text = "Iteration: 0/3"
	error_rate_label.text = "Target Item: ?"
	key_bits_label.text = "Success: 12.5%"
	eve_status_label.text = "Oracle Status"
	eve_status_label.modulate = COLOR_DISABLED

	# Update controls text for Grover
	controls_label.text = "WASD: Move | Mouse: Look | SPACE: Measure Database | ESC: Exit"

func setup_e91_hud():
	"""Configure HUD for E91 entanglement protocol."""
	step_label.text = "Bell Pairs: 0"
	error_rate_label.text = "CHSH: --"
	key_bits_label.text = "Entangled Key: []"
	eve_status_label.text = "Entanglement"
	eve_status_label.modulate = COLOR_INFO

	# Update controls for E91
	controls_label.text = "WASD: Move | Mouse: Look | SPACE: Measure | E: Toggle Eve | ESC: Exit"

func setup_b92_hud():
	"""Configure HUD for B92 simple protocol."""
	step_label.text = "Photons: 0"
	error_rate_label.text = "Detection: 0%"
	key_bits_label.text = "Key Bits: []"
	eve_status_label.text = "Photon State"
	eve_status_label.modulate = COLOR_WARNING

	# Update controls for B92
	controls_label.text = "WASD: Move | Mouse: Look | SPACE: Measure | E: Toggle Eve | ESC: Exit"

func setup_shor_hud():
	"""Configure HUD for Shor's algorithm."""
	step_label.text = "QFT Iteration: 0"
	error_rate_label.text = "Period: ?"
	key_bits_label.text = "Factors: ? × ?"
	eve_status_label.text = "Factoring 15"
	eve_status_label.modulate = COLOR_INFO

	# Update controls for Shor
	controls_label.text = "WASD: Move | Mouse: Look | SPACE: Measure QFT | ESC: Exit"

func show_educational_text(text: String):
	"""Display enhanced educational step-by-step explanation with superior readability."""
	if educational_text_label and educational_panel:
		# Mission-specific formatting with enhanced styling
		var header_text = ""
		var header_color = "yellow"
		var border_color = COLOR_EDUCATIONAL
		var accent_color = "white"

		match current_mission:
			"bb84":
				header_text = "🔐 BB84 QUANTUM CRYPTOGRAPHY"
				header_color = "aqua"
				border_color = Color.CYAN
				accent_color = "cyan"
			"e91":
				header_text = "🔗 E91 QUANTUM ENTANGLEMENT"
				header_color = "fuchsia"
				border_color = Color.MAGENTA
				accent_color = "magenta"
			"b92":
				header_text = "💫 B92 NON-ORTHOGONAL QKD"
				header_color = "orange"
				border_color = Color.ORANGE
				accent_color = "orange"
			"grover":
				header_text = "🔍 GROVER'S QUANTUM SEARCH"
				header_color = "lime"
				border_color = Color.GREEN
				accent_color = "lime"
			"shor":
				header_text = "⚡ SHOR'S FACTORING ALGORITHM"
				header_color = "gold"
				border_color = Color.GOLD
				accent_color = "gold"
			_:
				header_text = "🌌 QUANTUM COMPUTING"

		# Enhanced formatted text with superior contrast and styling
		var formatted_text = "[center]"
		formatted_text += "[bgcolor=black][color=%s][font_size=32][b]%s[/b][/font_size][/color][/bgcolor]" % [header_color, header_text]
		formatted_text += "\n[color=%s]═══════════════════════════════════════════════════[/color]" % accent_color
		formatted_text += "[/center]\n\n"

		# Main content with enhanced readability
		formatted_text += "[color=white][font_size=22][b]%s[/b][/font_size][/color]\n\n" % text

		# Footer with branding
		formatted_text += "[center]"
		formatted_text += "[color=gray][font_size=16][i]● Real-time Quantum Visualization ● Educational Mode ●[/i][/font_size][/color]"
		formatted_text += "[/center]"

		educational_text_label.text = formatted_text
		educational_panel.visible = true

		# Update panel border color to match mission with glow effect
		var panel_theme = educational_panel.get_theme_stylebox("panel")
		if panel_theme:
			panel_theme.border_color = border_color
			# Add subtle glow effect by increasing border width temporarily
			var glow_tween = create_tween()
			glow_tween.tween_method(
				func(width):
					if panel_theme:
						panel_theme.border_width_left = width
						panel_theme.border_width_right = width
						panel_theme.border_width_top = width
						panel_theme.border_width_bottom = width,
				4, 8, 0.3
			)
			glow_tween.tween_method(
				func(width):
					if panel_theme:
						panel_theme.border_width_left = width
						panel_theme.border_width_right = width
						panel_theme.border_width_top = width
						panel_theme.border_width_bottom = width,
				8, 4, 0.3
			)

		# Enhanced auto-hide with extended time for readability
		var hide_timer = get_tree().create_timer(8.0)  # Longer display time for complex explanations
		hide_timer.timeout.connect(hide_educational_text_animated)

func hide_educational_text_animated():
	"""Hide educational text with smooth fade animation."""
	if educational_panel:
		var fade_tween = create_tween()
		fade_tween.tween_property(educational_panel, "modulate", Color(1, 1, 1, 0), 0.5)
		fade_tween.tween_callback(
			func():
				educational_panel.visible = false
				educational_panel.modulate = Color.WHITE
		)

func hide_educational_text():
	"""Hide educational text display."""
	if educational_panel:
		educational_panel.visible = false

func update_mission_name(mission: String):
	var formatted_name = ""

	match mission.to_lower():
		"bb84":
			formatted_name = "BB84 Protocol"
		"e91":
			formatted_name = "E91 Entanglement"
		"b92":
			formatted_name = "B92 Protocol"
		"grover":
			formatted_name = "Grover's Search"
		"shor":
			formatted_name = "Shor's Algorithm"
		_:
			formatted_name = "%s Protocol" % mission.to_upper()

	mission_name_label.text = formatted_name
	mission_name_label.modulate = COLOR_INFO

func update_backend_status(status: String):
	backend_status_label.text = "Backend: %s" % status

	if status in ["Online", "Connected"]:
		backend_status_label.modulate = COLOR_SUCCESS
	elif status.begins_with("Connecting") or status.begins_with("Retrying"):
		backend_status_label.modulate = COLOR_WARNING
	else:
		backend_status_label.modulate = COLOR_DANGER

func update_step(step: int):
	if current_mission == "bb84":
		step_label.text = "Step: %d" % step
	elif current_mission == "grover":
		step_label.text = "Iteration: %d/3" % step

	if step > 0:
		step_label.modulate = COLOR_INFO

# BB84-specific updates
func update_error_rate(rate: float):
	"""Update BB84 error rate with security color coding."""
	var percentage = rate * 100.0
	error_rate_label.text = "Error Rate: %.1f%%" % percentage

	if rate <= 0.05:
		error_rate_label.modulate = COLOR_SUCCESS
	elif rate <= 0.11:
		error_rate_label.modulate = COLOR_WARNING
	else:
		error_rate_label.modulate = COLOR_DANGER

func update_sifted_key(key_bits: Array):
	"""Update BB84 sifted key display."""
	if key_bits.is_empty():
		key_bits_label.text = "Sifted Key: []"
		key_bits_label.modulate = COLOR_DISABLED
		return

	var key_length = key_bits.size()

	if key_length <= 10:
		key_bits_label.text = "Sifted Key: %s (%d bits)" % [str(key_bits), key_length]
	else:
		var preview = str(key_bits.slice(0, 5)) + "..."
		key_bits_label.text = "Sifted Key: %s (%d bits)" % [preview, key_length]

	if key_length >= 8:
		key_bits_label.modulate = COLOR_SUCCESS
	elif key_length >= 4:
		key_bits_label.modulate = COLOR_WARNING
	else:
		key_bits_label.modulate = COLOR_DANGER

func update_eve_status(active: bool):
	"""Update BB84 Eve eavesdropping status."""
	if active:
		eve_status_label.text = "Eve: ACTIVE"
		eve_status_label.modulate = COLOR_WARNING
	else:
		eve_status_label.text = "Eve: Inactive"
		eve_status_label.modulate = COLOR_DISABLED

func update_eve_detected(detected: bool):
	"""Update BB84 Eve detection alert."""
	if detected:
		eve_status_label.text = "Eve: DETECTED!"
		eve_status_label.modulate = COLOR_DANGER
		print("HUD: EVE INTRUSION DETECTED!")
	else:
		eve_status_label.text = "Eve: Not detected"
		eve_status_label.modulate = COLOR_SUCCESS

# Grover-specific updates
func update_grover_data(data: Dictionary):
	"""Update HUD with Grover algorithm progress."""
	print("HUD: Updating Grover data")

	# Iteration counter
	if data.has("iteration"):
		var iteration = data["iteration"]
		step_label.text = "Iteration: %d/3" % iteration
		step_label.modulate = COLOR_INFO

	# Target item display
	if data.has("target_item"):
		var target = data["target_item"]
		error_rate_label.text = "Target Item: %d" % target
		error_rate_label.modulate = COLOR_INFO

	# Success probability with classical comparison
	if data.has("success_probability"):
		var prob = data["success_probability"]
		var percentage = prob * 100.0
		var classical_prob = 12.5  # Classical: 1/8 = 12.5%

		key_bits_label.text = "Success: %.1f%% (Classical: %.1f%%)" % [percentage, classical_prob]

		# Color based on quantum advantage
		if prob >= 0.8:  # Strong quantum advantage
			key_bits_label.modulate = COLOR_SUCCESS
		elif prob >= 0.4:  # Moderate advantage
			key_bits_label.modulate = COLOR_WARNING
		else:  # No advantage yet
			key_bits_label.modulate = COLOR_NEUTRAL

	# Database search status
	eve_status_label.text = "Quantum Search Active"
	eve_status_label.modulate = COLOR_INFO

# Unified mission data handler
func update_mission_data(data: Dictionary):
	"""Route mission data to appropriate handler."""
	print("HUD: Updating %s mission data" % current_mission.to_upper())

	if current_mission == "bb84":
		update_bb84_data(data)
	elif current_mission == "grover":
		update_grover_data(data)

func update_bb84_data(data: Dictionary):
	"""Handle BB84-specific data updates."""
	if data.has("error_rate"):
		update_error_rate(data["error_rate"])

	if data.has("sifted_key"):
		update_sifted_key(data["sifted_key"])

	if data.has("eve_detected"):
		update_eve_detected(data["eve_detected"])

	if data.has("eve_active"):
		update_eve_status(data["eve_active"])

func get_current_status() -> Dictionary:
	"""Get current HUD status for debugging."""
	return {
		"mission": mission_name_label.text,
		"step": step_label.text,
		"error_rate": error_rate_label.text,
		"key_bits": key_bits_label.text,
		"eve_status": eve_status_label.text,
		"backend_status": backend_status_label.text
	}