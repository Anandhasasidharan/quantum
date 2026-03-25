extends Node3D

var qubit_nodes = []
var database_nodes = []
var qubit_materials: Array = []
var database_materials: Array = []

# Educational visualization elements
var alice_label: Label3D
var alice_avatar: MeshInstance3D
var bob_label: Label3D
var bob_avatar: MeshInstance3D
var eve_label: Label3D
var eve_drone: MeshInstance3D
var quantum_channel: MeshInstance3D
var quantum_channel_label: Label3D
var photon_node: MeshInstance3D
var oracle_label: Label3D
var qft_portal: MeshInstance3D
var period_landscape: Node3D
var database_labels: Array = []
var classical_comparison_bar: MeshInstance3D

# BB84 specific elements
var sifting_indicators: Array = []
var key_bit_labels: Array = []

# E91 specific elements
var entanglement_beam: MeshInstance3D
var chsh_meter: MeshInstance3D
var chsh_meter_label: Label3D
var chsh_arrows: Array = []
var entanglement_particles: Array = []

# B92 specific elements
var angle_indicator: MeshInstance3D
var angle_indicator_2: MeshInstance3D
var state_label: Label3D
var state_arrows: Array = []

# Grover specific elements
var probability_bars: Array = []

# Shor specific elements
var input_number_label: Label3D
var factor_peaks: Array = []
var portal_particles: Array = []

# Enhanced animation elements
var photon_trail_particles: Array = []
var diffusion_wave: MeshInstance3D
var measurement_flash: MeshInstance3D

# Central step display
var step_display_label: Label3D
var step_display_background: MeshInstance3D

const MIN_SCALE = 0.3
const MAX_SCALE = 1.8
const GLOW_INTENSITY = 4.0
const PULSE_SPEED = 1.5

var current_mission: String = "bb84"
var animation_tween: Tween
var current_step_text: String = ""

func _ready():
	animation_tween = create_tween()
	animation_tween.set_loops()
	create_central_step_display()

func setup_for_mission(mission_type: String):
	"""Initialize visualization for specific mission type."""
	current_mission = mission_type

	match mission_type:
		"bb84":
			setup_bb84_visualization()
		"e91":
			setup_e91_visualization()
		"b92":
			setup_b92_visualization()
		"grover":
			setup_grover_visualization()
		"shor":
			setup_shor_visualization()
		_:
			print("Unknown mission type: %s" % mission_type)
			setup_bb84_visualization()  # Fallback

	print("QuantumUpdater configured for %s" % mission_type.to_upper())

func setup_bb84_visualization():
	"""Setup BB84 with Alice, Bob, Eve avatars, sifting highlights, and key bit display."""
	initialize_qubit_nodes()
	setup_qubit_materials()
	position_qubits_circular()

	# Create enhanced educational 3D elements
	create_alice_bob_eve_enhanced()
	create_quantum_channel_enhanced()
	create_photon_visualization_enhanced()
	create_sifting_indicators()
	create_key_bit_display()
	create_measurement_flash_effect()

	start_quantum_pulse_animation()

	# Hide database grid
	for node in database_nodes:
		if node:
			node.visible = false

func setup_grover_visualization():
	"""Setup Grover with enhanced database grid, oracle, probability bars, and diffusion waves."""
	initialize_database_grid()
	setup_database_materials()

	# Create enhanced educational elements
	create_database_labels_enhanced()
	create_probability_bars()
	create_oracle_enhanced()
	create_classical_comparison_bar_enhanced()
	create_diffusion_wave()
	create_measurement_collapse_effect()

	# Hide BB84 qubits
	for node in qubit_nodes:
		if node:
			node.visible = false

func setup_e91_visualization():
	"""Setup E91 with entanglement beam, CHSH arrows, and violation meter."""
	initialize_qubit_nodes()
	setup_qubit_materials()

	# Position qubits as entangled pair
	if qubit_nodes.size() >= 2:
		qubit_nodes[0].position = Vector3(-5, 0, 0)  # Alice's qubit
		qubit_nodes[1].position = Vector3(5, 0, 0)   # Bob's qubit
		# Hide third qubit if it exists
		if qubit_nodes.size() > 2:
			qubit_nodes[2].visible = false

	# Create enhanced educational elements for entanglement
	create_alice_bob_entangled_enhanced()
	create_entanglement_beam_enhanced()
	create_chsh_violation_meter()
	create_chsh_angle_arrows()
	create_bell_pair_animation()
	start_quantum_pulse_animation()

	# Hide database grid
	for node in database_nodes:
		if node:
			node.visible = false

func setup_b92_visualization():
	"""Setup B92 with enhanced angle indicators showing 0° and 45° states."""
	initialize_qubit_nodes()
	setup_qubit_materials()

	# Position single photon/qubit
	if qubit_nodes.size() >= 1:
		qubit_nodes[0].position = Vector3(0, 0, 0)  # Photon state
		# Hide other qubits
		for i in range(1, qubit_nodes.size()):
			if qubit_nodes[i]:
				qubit_nodes[i].visible = false

	# Create enhanced B92 setup with dual angle indicators
	create_alice_bob_b92_enhanced()
	create_photon_visualization_enhanced()
	create_dual_angle_indicators()
	create_non_orthogonal_state_display()
	start_quantum_pulse_animation()

	# Hide database grid
	for node in database_nodes:
		if node:
			node.visible = false

func setup_shor_visualization():
	"""Setup Shor's with period landscape, rotating QFT portal, and factor peaks."""
	# Use both qubits and database for complex visualization
	initialize_qubit_nodes()
	initialize_database_grid()
	setup_qubit_materials()
	setup_database_materials()

	# Position qubits as QFT registers
	position_qubits_linear()

	# Create enhanced Shor's elements
	create_period_landscape_enhanced()
	create_qft_portal_enhanced()
	create_portal_particles()
	create_factor_display_enhanced()
	create_input_number_display()

	start_quantum_pulse_animation()

func create_entanglement_beam():
	"""Create visual beam between entangled qubits."""
	# This would create a particle effect or beam between Alice and Bob qubits
	# For now, just ensure both qubits pulse in sync
	pass

func create_period_landscape():
	"""Create height-varying landscape for Shor's period finding."""
	# Database boxes represent the period structure
	for i in range(database_nodes.size()):
		if database_nodes[i]:
			var height = 0.5 + (i % 4) * 0.3  # Create period pattern
			var mesh = database_nodes[i].mesh as BoxMesh
			if mesh:
				mesh.size.y = height
				database_nodes[i].position.y = height / 2.0

func position_qubits_linear():
	"""Position qubits in a line for QFT visualization."""
	for i in range(qubit_nodes.size()):
		if qubit_nodes[i]:
			qubit_nodes[i].position = Vector3(i * 2.0 - 2.0, 0, 0)
			qubit_nodes[i].visible = true

# ============================================================================
# ENHANCED EDUCATIONAL VISUALIZATION FUNCTIONS
# ============================================================================

func create_alice_bob_eve_enhanced():
	"""Create enhanced 3D Alice, Bob, Eve with avatars and clean labels."""
	# Alice (sender - left side)
	alice_avatar = MeshInstance3D.new()
	var alice_mesh = CylinderMesh.new()
	alice_mesh.height = 2.2
	alice_mesh.top_radius = 0.9
	alice_mesh.bottom_radius = 0.9
	alice_avatar.mesh = alice_mesh
	alice_avatar.position = Vector3(-7, 1.1, 0)

	var alice_material = StandardMaterial3D.new()
	alice_material.albedo_color = Color.YELLOW
	alice_material.emission_enabled = true
	alice_material.emission = Color.YELLOW
	alice_material.emission_energy = 2.0
	alice_material.rim_enabled = true
	alice_material.rim = 1.0
	alice_avatar.set_surface_override_material(0, alice_material)
	add_child(alice_avatar)

	# Alice label with clean positioning
	alice_label = Label3D.new()
	alice_label.text = "ALICE\nSender"
	alice_label.position = Vector3(-7, 3.5, 0)
	alice_label.modulate = Color.YELLOW
	alice_label.font_size = 42
	alice_label.outline_size = 12
	alice_label.outline_modulate = Color.BLACK
	alice_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	alice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(alice_label)

	# Bob (receiver - right side)
	bob_avatar = MeshInstance3D.new()
	var bob_mesh = CylinderMesh.new()
	bob_mesh.height = 2.2
	bob_mesh.top_radius = 0.9
	bob_mesh.bottom_radius = 0.9
	bob_avatar.mesh = bob_mesh
	bob_avatar.position = Vector3(7, 1.1, 0)

	var bob_material = StandardMaterial3D.new()
	bob_material.albedo_color = Color.GREEN
	bob_material.emission_enabled = true
	bob_material.emission = Color.GREEN
	bob_material.emission_energy = 2.0
	bob_material.rim_enabled = true
	bob_material.rim = 1.0
	bob_avatar.set_surface_override_material(0, bob_material)
	add_child(bob_avatar)

	# Bob label with clean positioning
	bob_label = Label3D.new()
	bob_label.text = "BOB\nReceiver"
	bob_label.position = Vector3(7, 3.5, 0)
	bob_label.modulate = Color.GREEN
	bob_label.font_size = 42
	bob_label.outline_size = 12
	bob_label.outline_modulate = Color.BLACK
	bob_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bob_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(bob_label)

	# Quantum Channel label - centered and clean
	quantum_channel_label = Label3D.new()
	quantum_channel_label.text = "QUANTUM CHANNEL"
	quantum_channel_label.position = Vector3(0, 4.5, 0)
	quantum_channel_label.modulate = Color(0.5, 1.0, 1.0)
	quantum_channel_label.font_size = 38
	quantum_channel_label.outline_size = 10
	quantum_channel_label.outline_modulate = Color.BLACK
	quantum_channel_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	quantum_channel_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(quantum_channel_label)

	# Eve drone (interceptor - initially hidden)
	eve_drone = MeshInstance3D.new()
	var eve_mesh = SphereMesh.new()
	eve_mesh.radius = 0.7
	eve_mesh.height = 1.4
	eve_drone.mesh = eve_mesh
	eve_drone.position = Vector3(0, -2, 0)

	var eve_material = StandardMaterial3D.new()
	eve_material.albedo_color = Color.RED
	eve_material.emission_enabled = true
	eve_material.emission = Color.RED
	eve_material.emission_energy = 2.5
	eve_material.rim_enabled = true
	eve_material.rim = 1.2
	eve_drone.set_surface_override_material(0, eve_material)
	eve_drone.visible = false
	add_child(eve_drone)

	# Eve label - clean and visible when active
	eve_label = Label3D.new()
	eve_label.text = "EVE\nEavesdropper"
	eve_label.position = Vector3(0, -0.3, 0)
	eve_label.modulate = Color.RED
	eve_label.font_size = 38
	eve_label.outline_size = 10
	eve_label.outline_modulate = Color.BLACK
	eve_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	eve_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	eve_label.visible = false
	add_child(eve_label)

func create_quantum_channel_enhanced():
	"""Create clean, glowing quantum channel tunnel."""
	quantum_channel = MeshInstance3D.new()
	var tube_mesh = CylinderMesh.new()
	tube_mesh.height = 0.4
	tube_mesh.top_radius = 0.2
	tube_mesh.bottom_radius = 0.2
	quantum_channel.mesh = tube_mesh

	# Position and rotate to connect Alice and Bob
	quantum_channel.position = Vector3(0, 0.8, 0)
	quantum_channel.rotation_degrees = Vector3(0, 0, 90)
	quantum_channel.scale = Vector3(1, 35, 1)  # Connect across

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.4, 1.0, 1.0, 0.7)
	material.emission_enabled = true
	material.emission = Color.CYAN
	material.emission_energy = 2.0
	material.flags_transparent = true
	material.rim_enabled = true
	material.rim = 1.2
	quantum_channel.set_surface_override_material(0, material)

	add_child(quantum_channel)

	# Add pulsing animation
	animate_quantum_channel()

func animate_quantum_channel():
	"""Create pulsing effect for quantum channel."""
	if quantum_channel:
		var pulse_tween = create_tween()
		pulse_tween.set_loops()

		# First pulse: 1.5 → 2.5
		pulse_tween.parallel().tween_method(
			func(energy):
				if quantum_channel:
					var material = quantum_channel.get_surface_override_material(0)
					if material:
						material.emission_energy = energy,
			1.5, 2.5, 1.5
		).set_trans(Tween.TRANS_SINE)

		# Second pulse: 2.5 → 1.5
		pulse_tween.parallel().tween_method(
			func(energy):
				if quantum_channel:
					var material = quantum_channel.get_surface_override_material(0)
					if material:
						material.emission_energy = energy,
			2.5, 1.5, 1.5
		).set_trans(Tween.TRANS_SINE)

func create_photon_visualization_enhanced():
	"""Create enhanced animated photon with trail effects."""
	photon_node = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.35
	sphere_mesh.height = 0.7
	photon_node.mesh = sphere_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color.YELLOW
	material.emission_enabled = true
	material.emission = Color.YELLOW
	material.emission_energy = 3.5
	material.rim_enabled = true
	material.rim = 1.2
	photon_node.set_surface_override_material(0, material)

	photon_node.position = Vector3(-6, 0.8, 0)  # Start near Alice
	add_child(photon_node)

	# Create photon trail effect
	create_photon_trail()

func create_photon_trail():
	"""Create optimized trail particles behind the photon (6 particles for performance)."""
	photon_trail_particles.clear()

	for i in range(6):  # Reduced for performance
		var trail_particle = MeshInstance3D.new()
		var particle_mesh = SphereMesh.new()
		particle_mesh.radius = 0.18 - (i * 0.025)
		particle_mesh.height = 0.36 - (i * 0.05)
		trail_particle.mesh = particle_mesh

		var trail_material = StandardMaterial3D.new()
		var alpha = 0.85 - (i * 0.12)
		trail_material.albedo_color = Color(1, 1, 0, alpha)
		trail_material.emission_enabled = true
		trail_material.emission = Color(1, 1, 0, alpha * 0.7)
		trail_material.emission_energy = 2.8 - (i * 0.35)
		trail_material.flags_transparent = true
		trail_material.rim_enabled = true
		trail_material.rim = 0.9 - (i * 0.12)
		trail_particle.set_surface_override_material(0, trail_material)

		trail_particle.position = Vector3(-5.5 - (i * 0.3), 0.8, 0)
		trail_particle.visible = false
		add_child(trail_particle)
		photon_trail_particles.append(trail_particle)

func create_sifting_indicators():
	"""Create visual sifting indicators (green=match, red=mismatch)."""
	sifting_indicators.clear()

	# Create 4 indicator lights between Alice and Bob
	for i in range(4):
		var indicator = MeshInstance3D.new()
		var sphere_mesh = SphereMesh.new()
		sphere_mesh.radius = 0.3
		sphere_mesh.height = 0.6
		indicator.mesh = sphere_mesh

		var x_pos = -4 + (i * 2.5)
		indicator.position = Vector3(x_pos, -1, 0)

		var material = StandardMaterial3D.new()
		material.albedo_color = Color.GRAY
		material.emission_enabled = true
		material.emission = Color.GRAY
		material.emission_energy = 0.5
		material.rim_enabled = true
		material.rim = 0.8
		indicator.set_surface_override_material(0, material)

		indicator.visible = false
		add_child(indicator)
		sifting_indicators.append(indicator)

func create_key_bit_display():
	"""Create display for final key bits appearing one by one."""
	key_bit_labels.clear()

	# Create 8 key bit labels
	for i in range(8):
		var label = Label3D.new()
		label.text = "?"
		label.font_size = 32
		label.modulate = Color.YELLOW
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

		var x_pos = -3.5 + (i * 1.0)
		label.position = Vector3(x_pos, -2.5, 0)
		label.visible = false

		add_child(label)
		key_bit_labels.append(label)

	# Add header label
	var header_label = Label3D.new()
	header_label.text = "SECURE KEY:"
	header_label.font_size = 24
	header_label.modulate = Color.YELLOW
	header_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	header_label.position = Vector3(-4.5, -3.5, 0)
	header_label.visible = false
	add_child(header_label)
	key_bit_labels.append(header_label)  # Store header too

func show_sifting_results(matches: Array):
	"""Show sifting results with green (match) or red (mismatch) indicators."""
	for i in range(min(matches.size(), sifting_indicators.size())):
		var indicator = sifting_indicators[i]
		if indicator:
			indicator.visible = true
			var material = indicator.get_surface_override_material(0)
			if material:
				if matches[i]:
					# Green for match
					material.albedo_color = Color.GREEN
					material.emission = Color.GREEN
					material.emission_energy = 2.0
				else:
					# Red for mismatch
					material.albedo_color = Color.RED
					material.emission = Color.RED
					material.emission_energy = 2.0

			# Animate indicator appearing
			var appear_tween = create_tween()
			indicator.scale = Vector3(0.1, 0.1, 0.1)
			appear_tween.tween_property(indicator, "scale", Vector3(1, 1, 1), 0.5).set_delay(i * 0.2)

func show_key_bits(bits: Array):
	"""Show final key bits appearing one by one."""
	# Show header first
	if key_bit_labels.size() > 0:
		key_bit_labels[key_bit_labels.size() - 1].visible = true

	# Show bits one by one
	for i in range(min(bits.size(), key_bit_labels.size() - 1)):
		var label = key_bit_labels[i]
		if label:
			label.text = str(bits[i])
			label.visible = true

			# Animate bit appearing
			var bit_tween = create_tween()
			label.scale = Vector3(0.1, 0.1, 0.1)
			bit_tween.tween_property(label, "scale", Vector3(1.5, 1.5, 1.5), 0.3).set_delay(i * 0.3)
			bit_tween.tween_property(label, "scale", Vector3(1, 1, 1), 0.2)
	"""Create enhanced entanglement visualization for E91."""
	# Alice's side with entangled qubit
	alice_avatar = MeshInstance3D.new()
	var alice_mesh = CylinderMesh.new()
	alice_mesh.height = 1.8
	alice_mesh.top_radius = 0.7
	alice_mesh.bottom_radius = 0.7
	alice_avatar.mesh = alice_mesh
	alice_avatar.position = Vector3(-7, 1, 0)

	var alice_material = StandardMaterial3D.new()
	alice_material.albedo_color = Color.MAGENTA
	alice_material.emission_enabled = true
	alice_material.emission = Color.MAGENTA
	alice_material.emission_energy = 1.8
	alice_material.rim_enabled = true
	alice_material.rim = 1.0
	alice_avatar.set_surface_override_material(0, alice_material)
	add_child(alice_avatar)

	alice_label = Label3D.new()
	alice_label.text = "ALICE\n(Entangled)"
	alice_label.position = Vector3(-7, 3, 0)
	alice_label.modulate = Color.MAGENTA
	alice_label.font_size = 24
	alice_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(alice_label)

	# Bob's side with entangled qubit
	bob_avatar = MeshInstance3D.new()
	var bob_mesh = CylinderMesh.new()
	bob_mesh.height = 1.8
	bob_mesh.top_radius = 0.7
	bob_mesh.bottom_radius = 0.7
	bob_avatar.mesh = bob_mesh
	bob_avatar.position = Vector3(7, 1, 0)

	var bob_material = StandardMaterial3D.new()
	bob_material.albedo_color = Color.MAGENTA
	bob_material.emission_enabled = true
	bob_material.emission = Color.MAGENTA
	bob_material.emission_energy = 1.8
	bob_material.rim_enabled = true
	bob_material.rim = 1.0
	bob_avatar.set_surface_override_material(0, bob_material)
	add_child(bob_avatar)

	bob_label = Label3D.new()
	bob_label.text = "BOB\n(Entangled)"
	bob_label.position = Vector3(7, 3, 0)
	bob_label.modulate = Color.MAGENTA
	bob_label.font_size = 24
	bob_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(bob_label)

func create_entanglement_beam_enhanced():
	"""Create pulsing entanglement beam with particle effects between Alice and Bob."""
	entanglement_beam = MeshInstance3D.new()
	var beam_mesh = CylinderMesh.new()
	beam_mesh.height = 0.2
	beam_mesh.top_radius = 0.12
	beam_mesh.bottom_radius = 0.12
	entanglement_beam.mesh = beam_mesh

	# Position and rotate to connect qubits
	entanglement_beam.position = Vector3(0, 0, 0)
	entanglement_beam.rotation_degrees = Vector3(0, 0, 90)
	entanglement_beam.scale = Vector3(1, 28, 1)

	var beam_material = StandardMaterial3D.new()
	beam_material.albedo_color = Color(1, 0, 1, 0.85)
	beam_material.emission_enabled = true
	beam_material.emission = Color.MAGENTA
	beam_material.emission_energy = 3.0
	beam_material.flags_transparent = true
	beam_material.rim_enabled = true
	beam_material.rim = 1.5
	# Add subtle animation to the beam
	beam_material.uv1_offset = Vector3(0, 0, 0)
	entanglement_beam.set_surface_override_material(0, beam_material)

	add_child(entanglement_beam)

	# Create entanglement particles along the beam
	create_entanglement_particles()

func create_chsh_violation_meter():
	"""Create CHSH inequality violation meter."""
	chsh_meter = MeshInstance3D.new()
	var meter_mesh = BoxMesh.new()
	meter_mesh.size = Vector3(0.2, 3.0, 0.2)
	chsh_meter.mesh = meter_mesh
	chsh_meter.position = Vector3(0, 1.5, 2)

	var meter_material = StandardMaterial3D.new()
	meter_material.albedo_color = Color.YELLOW
	meter_material.emission_enabled = true
	meter_material.emission = Color.YELLOW
	meter_material.emission_energy = 2.0
	chsh_meter.set_surface_override_material(0, meter_material)
	add_child(chsh_meter)

	chsh_meter_label = Label3D.new()
	chsh_meter_label.text = "CHSH METER\n2.0 = Classical\n2.8 = Quantum!"
	chsh_meter_label.position = Vector3(0, 4, 2)
	chsh_meter_label.modulate = Color.YELLOW
	chsh_meter_label.font_size = 16
	chsh_meter_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(chsh_meter_label)

func create_bell_pair_animation():
	"""Create Bell pair creation animation effect."""
	# This would show the creation of entangled states
	# Implementation can include particle effects for pair creation
	pass

func create_entanglement_particles():
	"""Create subtle particles along the entanglement beam."""
	for i in range(6):
		var particle = MeshInstance3D.new()
		var particle_mesh = SphereMesh.new()
		particle_mesh.radius = 0.08
		particle_mesh.height = 0.16
		particle.mesh = particle_mesh

		var particle_material = StandardMaterial3D.new()
		particle_material.albedo_color = Color(1, 0.5, 1, 0.6)
		particle_material.emission_enabled = true
		particle_material.emission = Color.MAGENTA
		particle_material.emission_energy = 2.0
		particle_material.flags_transparent = true
		particle.set_surface_override_material(0, particle_material)

		particle.position = Vector3((i - 2.5) * 2.2, 0, 0)
		add_child(particle)

		# Animate particle floating up and down
		var particle_tween = create_tween()
		particle_tween.set_loops()
		particle_tween.tween_property(particle, "position:y", 0.3, 1.0 + (i * 0.1))
		particle_tween.tween_property(particle, "position:y", -0.3, 1.0 + (i * 0.1))

func create_chsh_angle_arrows():
	"""Create rotating angle arrows for CHSH measurement angles."""
	chsh_arrows.clear()

	# Alice's measurement arrow
	var alice_arrow = MeshInstance3D.new()
	var alice_arrow_mesh = BoxMesh.new()
	alice_arrow_mesh.size = Vector3(1.5, 0.1, 0.1)
	alice_arrow.mesh = alice_arrow_mesh
	alice_arrow.position = Vector3(-5, 1, 0)

	var alice_arrow_material = StandardMaterial3D.new()
	alice_arrow_material.albedo_color = Color.MAGENTA
	alice_arrow_material.emission_enabled = true
	alice_arrow_material.emission = Color.MAGENTA
	alice_arrow_material.emission_energy = 2.0
	alice_arrow_material.rim_enabled = true
	alice_arrow_material.rim = 1.0
	alice_arrow.set_surface_override_material(0, alice_arrow_material)
	add_child(alice_arrow)
	chsh_arrows.append(alice_arrow)

	# Alice's arrow label
	var alice_label = Label3D.new()
	alice_label.text = "θ₁"
	alice_label.font_size = 28
	alice_label.modulate = Color.MAGENTA
	alice_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	alice_label.position = Vector3(-5, 2, 0)
	add_child(alice_label)
	chsh_arrows.append(alice_label)

	# Bob's measurement arrow
	var bob_arrow = MeshInstance3D.new()
	var bob_arrow_mesh = BoxMesh.new()
	bob_arrow_mesh.size = Vector3(1.5, 0.1, 0.1)
	bob_arrow.mesh = bob_arrow_mesh
	bob_arrow.position = Vector3(5, 1, 0)

	var bob_arrow_material = StandardMaterial3D.new()
	bob_arrow_material.albedo_color = Color.MAGENTA
	bob_arrow_material.emission_enabled = true
	bob_arrow_material.emission = Color.MAGENTA
	bob_arrow_material.emission_energy = 2.0
	bob_arrow_material.rim_enabled = true
	bob_arrow_material.rim = 1.0
	bob_arrow.set_surface_override_material(0, bob_arrow_material)
	add_child(bob_arrow)
	chsh_arrows.append(bob_arrow)

	# Bob's arrow label
	var bob_label = Label3D.new()
	bob_label.text = "θ₂"
	bob_label.font_size = 28
	bob_label.modulate = Color.MAGENTA
	bob_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	bob_label.position = Vector3(5, 2, 0)
	add_child(bob_label)
	chsh_arrows.append(bob_label)

	# Start rotating arrows
	animate_chsh_arrows()

func animate_chsh_arrows():
	"""Animate CHSH measurement angle arrows rotating."""
	if chsh_arrows.size() >= 2:
		# Rotate Alice's arrow
		var alice_arrow_tween = create_tween()
		alice_arrow_tween.set_loops()
		alice_arrow_tween.tween_property(chsh_arrows[0], "rotation_degrees", Vector3(0, 0, 360), 4.0)

		# Rotate Bob's arrow at different speed
		var bob_arrow_tween = create_tween()
		bob_arrow_tween.set_loops()
		bob_arrow_tween.tween_property(chsh_arrows[2], "rotation_degrees", Vector3(0, 0, 360), 3.5)

func show_eve_cutting_beam():
	"""Show Eve cutting/attacking the entanglement beam."""
	if eve_drone and entanglement_beam:
		eve_drone.visible = true
		eve_drone.position = Vector3(0, -1.5, 0)

		var cut_tween = create_tween()
		# Eve moves to beam
		cut_tween.parallel().tween_property(eve_drone, "position", Vector3(0, 0, 0), 0.8)

		# Beam flickers and weakens
		cut_tween.parallel().tween_method(
			func(energy):
				var material = entanglement_beam.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			3.0, 0.5, 0.8
		)

		# Add red flash
		cut_tween.parallel().tween_method(
			func(alpha):
				var material = eve_drone.get_surface_override_material(0)
				if material:
					material.emission_energy = alpha * 4.0,
			1.0, 8.0, 0.4
		)

		# Beam breaks apart
		cut_tween.tween_callback(
			func():
				if entanglement_beam:
					entanglement_beam.scale.y = 0.1
		)
	"""Create enhanced Alice/Bob setup for B92 with state indicators."""
	# Alice with non-orthogonal state preparation
	alice_avatar = MeshInstance3D.new()
	var alice_mesh = CylinderMesh.new()
	alice_mesh.height = 1.6
	alice_mesh.top_radius = 0.6
	alice_mesh.bottom_radius = 0.6
	alice_avatar.mesh = alice_mesh
	alice_avatar.position = Vector3(-4, 1, 0)

	var alice_material = StandardMaterial3D.new()
	alice_material.albedo_color = Color.ORANGE
	alice_material.emission_enabled = true
	alice_material.emission = Color.ORANGE
	alice_material.emission_energy = 1.5
	alice_material.rim_enabled = true
	alice_material.rim = 0.8
	alice_avatar.set_surface_override_material(0, alice_material)
	add_child(alice_avatar)

	alice_label = Label3D.new()
	alice_label.text = "ALICE\n|0⟩ or |+⟩"
	alice_label.position = Vector3(-4, 3, 0)
	alice_label.modulate = Color.ORANGE
	alice_label.font_size = 22
	alice_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(alice_label)

	# Bob with detector
	bob_avatar = MeshInstance3D.new()
	var bob_mesh = CylinderMesh.new()
	bob_mesh.height = 1.6
	bob_mesh.top_radius = 0.6
	bob_mesh.bottom_radius = 0.6
	bob_avatar.mesh = bob_mesh
	bob_avatar.position = Vector3(4, 1, 0)

	var bob_material = StandardMaterial3D.new()
	bob_material.albedo_color = Color.ORANGE
	bob_material.emission_enabled = true
	bob_material.emission = Color.ORANGE
	bob_material.emission_energy = 1.5
	bob_material.rim_enabled = true
	bob_material.rim = 0.8
	bob_avatar.set_surface_override_material(0, bob_material)
	add_child(bob_avatar)

	bob_label = Label3D.new()
	bob_label.text = "BOB\n(Detector)"
	bob_label.position = Vector3(4, 3, 0)
	bob_label.modulate = Color.ORANGE
	bob_label.font_size = 22
	bob_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(bob_label)

func create_dual_angle_indicators():
	"""Create clear dual angle indicators showing 0° and 45° states."""
	# 0° (horizontal) indicator
	angle_indicator = MeshInstance3D.new()
	var arrow_mesh_1 = BoxMesh.new()
	arrow_mesh_1.size = Vector3(2.5, 0.15, 0.15)
	angle_indicator.mesh = arrow_mesh_1
	angle_indicator.position = Vector3(-1.5, 0.5, 0)
	angle_indicator.rotation_degrees = Vector3(0, 0, 0)  # Horizontal

	var angle_material_1 = StandardMaterial3D.new()
	angle_material_1.albedo_color = Color.YELLOW
	angle_material_1.emission_enabled = true
	angle_material_1.emission = Color.YELLOW
	angle_material_1.emission_energy = 2.5
	angle_material_1.rim_enabled = true
	angle_material_1.rim = 1.2
	angle_indicator.set_surface_override_material(0, angle_material_1)
	add_child(angle_indicator)

	# 45° (diagonal) indicator
	angle_indicator_2 = MeshInstance3D.new()
	var arrow_mesh_2 = BoxMesh.new()
	arrow_mesh_2.size = Vector3(2.5, 0.15, 0.15)
	angle_indicator_2.mesh = arrow_mesh_2
	angle_indicator_2.position = Vector3(1.5, 0.5, 0)
	angle_indicator_2.rotation_degrees = Vector3(0, 0, 45)  # 45 degree angle

	var angle_material_2 = StandardMaterial3D.new()
	angle_material_2.albedo_color = Color.ORANGE
	angle_material_2.emission_enabled = true
	angle_material_2.emission = Color.ORANGE
	angle_material_2.emission_energy = 2.5
	angle_material_2.rim_enabled = true
	angle_material_2.rim = 1.2
	angle_indicator_2.set_surface_override_material(0, angle_material_2)
	add_child(angle_indicator_2)

	# Add labels
	var label_0 = Label3D.new()
	label_0.text = "|0⟩\n0°"
	label_0.font_size = 26
	label_0.modulate = Color.YELLOW
	label_0.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_0.position = Vector3(-1.5, 1.8, 0)
	add_child(label_0)

	var label_45 = Label3D.new()
	label_45.text = "|+⟩\n45°"
	label_45.font_size = 26
	label_45.modulate = Color.ORANGE
	label_45.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label_45.position = Vector3(1.5, 1.8, 0)
	add_child(label_45)

	# Create pulsing animation for the active state
	animate_angle_indicators()

func animate_angle_indicators():
	"""Animate angle indicators to show which state is active."""
	if angle_indicator and angle_indicator_2:
		# Pulse between the two states
		var pulse_tween = create_tween()
		pulse_tween.set_loops()

		# Pulse first indicator
		pulse_tween.parallel().tween_method(
			func(energy):
				var material = angle_indicator.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			2.5, 4.0, 1.0
		)
		pulse_tween.parallel().tween_method(
			func(energy):
				var material = angle_indicator.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			4.0, 2.5, 1.0
		)

		# Pulse second indicator (offset)
		pulse_tween.parallel().tween_method(
			func(energy):
				var material = angle_indicator_2.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			2.5, 4.0, 1.0
		).set_delay(0.5)
		pulse_tween.parallel().tween_method(
			func(energy):
				var material = angle_indicator_2.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			4.0, 2.5, 1.0
		).set_delay(0.5)

func create_non_orthogonal_state_display():
	"""Create visual display of non-orthogonal quantum states."""
	state_label = Label3D.new()
	state_label.text = "NON-ORTHOGONAL\nSTATES\n⟨0|+⟩ = 1/√2"
	state_label.position = Vector3(0, 2.5, 0)
	state_label.modulate = Color.YELLOW
	state_label.font_size = 18
	state_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(state_label)

func create_quantum_channel():
	"""Create visual representation of quantum channel."""
	# Create a simple tube/cylinder between Alice and Bob
	var channel = MeshInstance3D.new()
	var tube_mesh = CylinderMesh.new()
	tube_mesh.height = 0.2
	tube_mesh.top_radius = 0.1
	tube_mesh.bottom_radius = 0.1
	channel.mesh = tube_mesh

	# Position and rotate to connect Alice and Bob
	channel.position = Vector3(0, 0, 0)
	channel.rotation_degrees = Vector3(0, 0, 90)
	channel.scale = Vector3(1, 30, 1)  # Stretch across

	var material = StandardMaterial3D.new()
	material.albedo_color = Color.WHITE
	material.emission_enabled = true
	material.emission = Color.CYAN
	material.emission_energy = 0.5
	channel.set_surface_override_material(0, material)

	add_child(channel)

func create_photon_visualization():
	"""Create animated photon flying from Alice to Bob."""
	photon_node = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 0.2
	sphere_mesh.height = 0.4
	photon_node.mesh = sphere_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color.YELLOW
	material.emission_enabled = true
	material.emission = Color.YELLOW
	material.emission_energy = 2.0
	photon_node.set_surface_override_material(0, material)

	photon_node.position = Vector3(-4, 0, 0)  # Start at Alice
	add_child(photon_node)

func create_database_labels_enhanced():
	"""Create enhanced labels for each database item with probability indicators."""
	database_labels.clear()

	for i in range(8):
		var label = Label3D.new()
		label.text = "Item %d\n0%%\nClassical" % i
		label.font_size = 16
		label.modulate = Color.WHITE
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED

		# Position above each database box
		var row = i / 4
		var col = i % 4
		var x = col * 2.0 - 3.0
		var z = row * 2.0 - 1.0
		label.position = Vector3(x, 2.5, z)

		database_labels.append(label)
		add_child(label)

func create_oracle_enhanced():
	"""Create enhanced Oracle with visual effects."""
	oracle_label = Label3D.new()
	oracle_label.text = "ORACLE\n(Marks Target)\nΦ → -Φ"
	oracle_label.position = Vector3(0, 5, 0)
	oracle_label.modulate = Color.RED
	oracle_label.font_size = 20
	oracle_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	oracle_label.visible = false
	add_child(oracle_label)

func create_classical_comparison_bar_enhanced():
	"""Create enhanced classical search comparison with animation."""
	classical_comparison_bar = MeshInstance3D.new()
	var bar_mesh = BoxMesh.new()
	bar_mesh.size = Vector3(0.4, 1.0, 0.4)  # Fixed height for 12.5%
	classical_comparison_bar.mesh = bar_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color.GRAY
	material.emission_enabled = true
	material.emission = Color.GRAY
	material.emission_energy = 1.2
	material.rim_enabled = true
	material.rim = 0.5
	classical_comparison_bar.set_surface_override_material(0, material)

	# Position on the side
	classical_comparison_bar.position = Vector3(-6, 0.5, 0)
	add_child(classical_comparison_bar)

	# Enhanced label for classical bar
	var classical_label = Label3D.new()
	classical_label.text = "CLASSICAL\nSEARCH\n12.5%"
	classical_label.position = Vector3(-6, 2.5, 0)
	classical_label.modulate = Color.GRAY
	classical_label.font_size = 16
	classical_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(classical_label)

func create_probability_bars():
	"""Create rising probability bars for each database item (mountain visualization)."""
	probability_bars.clear()

	for i in range(8):
		var bar = MeshInstance3D.new()
		var bar_mesh = BoxMesh.new()
		bar_mesh.size = Vector3(0.6, 0.1, 0.6)  # Start very small
		bar.mesh = bar_mesh

		# Position bars underneath database items
		var row = i / 4
		var col = i % 4
		var x = col * 2.0 - 3.0
		var z = row * 2.0 - 1.0
		bar.position = Vector3(x, 0.05, z)

		var bar_material = StandardMaterial3D.new()
		bar_material.albedo_color = Color.CYAN.lerp(Color.BLUE, 0.5)
		bar_material.emission_enabled = true
		bar_material.emission = Color.CYAN
		bar_material.emission_energy = 1.5
		bar_material.rim_enabled = true
		bar_material.rim = 0.8
		bar.set_surface_override_material(0, bar_material)

		add_child(bar)
		probability_bars.append(bar)

func update_probability_bars(probabilities: Array):
	"""Update probability bars to rise like mountains based on quantum amplitudes."""
	for i in range(min(probabilities.size(), probability_bars.size())):
		var bar = probability_bars[i]
		var prob = probabilities[i]

		if bar:
			var mesh = bar.mesh as BoxMesh
			if mesh:
				# Height based on probability (max 4.0 for 100%)
				var target_height = prob * 4.0

				# Animate height change
				var bar_tween = create_tween()
				bar_tween.parallel().tween_method(
					func(h):
						mesh.size.y = h
						bar.position.y = h / 2.0
					mesh.size.y,
					target_height,
					0.5
				).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

				# Change color based on height (blue → cyan → yellow for high probability)
				var material = bar.get_surface_override_material(0)
				if material:
					if prob > 0.7:
						material.albedo_color = Color.YELLOW
						material.emission = Color.YELLOW
						material.emission_energy = 3.0
					elif prob > 0.4:
						material.albedo_color = Color.CYAN
						material.emission = Color.CYAN
						material.emission_energy = 2.0
					else:
						material.albedo_color = Color.BLUE.lerp(Color.CYAN, prob)
						material.emission = Color.CYAN
						material.emission_energy = 1.5
	"""Create diffusion wave effect for Grover's algorithm."""
	diffusion_wave = MeshInstance3D.new()
	var wave_mesh = SphereMesh.new()
	wave_mesh.radius = 0.5
	wave_mesh.height = 0.1
	diffusion_wave.mesh = wave_mesh
	diffusion_wave.position = Vector3(0, 0, 0)
	diffusion_wave.visible = false

	var wave_material = StandardMaterial3D.new()
	wave_material.albedo_color = Color(0, 1, 1, 0.3)
	wave_material.emission_enabled = true
	wave_material.emission = Color.CYAN
	wave_material.emission_energy = 2.0
	wave_material.flags_transparent = true
	diffusion_wave.set_surface_override_material(0, wave_material)
	add_child(diffusion_wave)

func create_measurement_collapse_effect():
	"""Create measurement collapse animation."""
	measurement_flash = MeshInstance3D.new()
	var flash_mesh = SphereMesh.new()
	flash_mesh.radius = 1.0
	flash_mesh.height = 2.0
	measurement_flash.mesh = flash_mesh
	measurement_flash.position = Vector3(0, 1, 0)
	measurement_flash.visible = false

	var flash_material = StandardMaterial3D.new()
	flash_material.albedo_color = Color(1, 1, 1, 0.8)
	flash_material.emission_enabled = true
	flash_material.emission = Color.WHITE
	flash_material.emission_energy = 5.0
	flash_material.flags_transparent = true
	measurement_flash.set_surface_override_material(0, flash_material)
	add_child(measurement_flash)

func create_period_landscape_enhanced():
	"""Create enhanced height-varying landscape for Shor's period finding."""
	# Database boxes represent the period structure with enhanced visuals
	for i in range(database_nodes.size()):
		if database_nodes[i]:
			var height = 0.5 + (i % 4) * 0.4  # Create period pattern
			var mesh = database_nodes[i].mesh as BoxMesh
			if mesh:
				mesh.size.y = height
				database_nodes[i].position.y = height / 2.0

			# Enhanced materials for period landscape
			var landscape_material = StandardMaterial3D.new()
			landscape_material.albedo_color = Color.BLUE.lerp(Color.PURPLE, i / 8.0)
			landscape_material.emission_enabled = true
			landscape_material.emission = landscape_material.albedo_color
			landscape_material.emission_energy = 1.5
			landscape_material.rim_enabled = true
			landscape_material.rim = 0.6
			database_nodes[i].set_surface_override_material(0, landscape_material)

	# Create factor peaks (initially hidden)
	create_factor_peaks()

func create_factor_peaks():
	"""Create sharp factor peaks that appear after QFT."""
	factor_peaks.clear()

	# Create two prominent peaks at factor positions
	for i in range(2):
		var peak = MeshInstance3D.new()
		var peak_mesh = CylinderMesh.new()
		peak_mesh.height = 3.0
		peak_mesh.top_radius = 0.3
		peak_mesh.bottom_radius = 0.8
		peak.mesh = peak_mesh

		var peak_material = StandardMaterial3D.new()
		peak_material.albedo_color = Color.GOLD
		peak_material.emission_enabled = true
		peak_material.emission = Color.GOLD
		peak_material.emission_energy = 4.0
		peak_material.rim_enabled = true
		peak_material.rim = 1.2
		peak.set_surface_override_material(0, peak_material)

		peak.position = Vector3((i * 4) - 2, 1.5, 0)
		peak.visible = false
		factor_peaks.append(peak)
		add_child(peak)

func create_qft_portal_enhanced():
	"""Create enhanced rotating QFT portal with particle effects."""
	qft_portal = MeshInstance3D.new()
	var torus_mesh = SphereMesh.new()
	torus_mesh.radius = 2.0
	torus_mesh.height = 0.4
	qft_portal.mesh = torus_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.5, 0, 1, 0.7)
	material.emission_enabled = true
	material.emission = Color.PURPLE
	material.emission_energy = 4.0
	material.flags_transparent = true
	material.rim_enabled = true
	material.rim = 1.5
	qft_portal.set_surface_override_material(0, material)

	qft_portal.position = Vector3(0, 4, 0)
	qft_portal.visible = false
	add_child(qft_portal)

	# Enhanced QFT label
	var qft_label = Label3D.new()
	qft_label.text = "QFT PORTAL\n(Fourier Transform)\nExtracting Period..."
	qft_label.position = Vector3(0, 6.5, 0)
	qft_label.modulate = Color.PURPLE
	qft_label.font_size = 18
	qft_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(qft_label)

func create_factor_display_enhanced():
	"""Create enhanced factor display with animation."""
	var factor_label = Label3D.new()
	factor_label.text = "TARGET: 15\nFACTORS: ? × ?\nRSA STATUS: Secure"
	factor_label.position = Vector3(6, 4, 0)
	factor_label.modulate = Color.GOLD
	factor_label.font_size = 18
	factor_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(factor_label)

func create_input_number_display():
	"""Create input number display for Shor's algorithm."""
	input_number_label = Label3D.new()
	input_number_label.text = "INPUT NUMBER\n15 = 3 × 5\n(To be factored)"
	input_number_label.position = Vector3(-6, 4, 0)
	input_number_label.modulate = Color.CYAN
	input_number_label.font_size = 18
	input_number_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	add_child(input_number_label)

func create_measurement_flash_effect():
	"""Create measurement flash effect for all missions."""
	measurement_flash = MeshInstance3D.new()
	var flash_mesh = SphereMesh.new()
	flash_mesh.radius = 1.5
	flash_mesh.height = 3.0
	measurement_flash.mesh = flash_mesh
	measurement_flash.position = Vector3(0, 1.5, 0)
	measurement_flash.visible = false

	var flash_material = StandardMaterial3D.new()
	flash_material.albedo_color = Color(1, 1, 1, 0.9)
	flash_material.emission_enabled = true
	flash_material.emission = Color.WHITE
	flash_material.emission_energy = 6.0
	flash_material.flags_transparent = true
	measurement_flash.set_surface_override_material(0, flash_material)
	add_child(measurement_flash)

# ============================================================================
# ENHANCED EDUCATIONAL UPDATE FUNCTIONS
# ============================================================================

func show_eve_attack_enhanced():
	"""Show enhanced Eve eavesdropping with drone and attack effects."""
	if eve_label and eve_drone:
		eve_label.visible = true
		eve_drone.visible = true

		# Create dramatic red flash effect
		var flash_tween = create_tween()
		flash_tween.parallel().tween_method(
			func(intensity):
				if eve_label:
					eve_label.modulate = Color(1, 0, 0, intensity)
			0.3, 1.0, 0.3
		)
		flash_tween.parallel().tween_method(
			func(intensity):
				if eve_drone:
					var material = eve_drone.get_surface_override_material(0)
					if material:
						material.emission_energy = intensity * 4.0,
			1.0, 8.0, 0.3
		)

		# Animate Eve drone intercepting
		flash_tween.parallel().tween_property(eve_drone, "position", Vector3(0, 0.5, 0), 0.5)

		# State collapse effect on quantum channel
		if quantum_channel:
			flash_tween.parallel().tween_method(
				func(energy):
					var material = quantum_channel.get_surface_override_material(0)
					if material:
						material.emission_energy = energy,
				1.2, 0.3, 0.5
			)

func hide_eve_attack_enhanced():
	"""Hide Eve with smooth retreat animation."""
	if eve_label and eve_drone:
		var retreat_tween = create_tween()
		retreat_tween.parallel().tween_property(eve_drone, "position", Vector3(0, -1.5, 0), 0.8)
		retreat_tween.parallel().tween_method(
			func(alpha):
				if eve_label:
					eve_label.modulate = Color(1, 0, 0, alpha)
			1.0, 0.0, 0.8
		)
		retreat_tween.tween_callback(
			func():
				if eve_label:
					eve_label.visible = false
				if eve_drone:
					eve_drone.visible = false
		)

func animate_photon_flight_enhanced():
	"""Animate smooth photon flight from Alice to Bob."""
	if photon_node:
		# Show trail particles
		for i in range(photon_trail_particles.size()):
			var particle = photon_trail_particles[i]
			if particle:
				particle.visible = true

		var flight_tween = create_tween()

		# Smooth photon flight from Alice (-6) to Bob (+6)
		flight_tween.parallel().tween_property(photon_node, "position", Vector3(6, 0.8, 0), 2.5)

		# Animate trail with smooth following
		for i in range(photon_trail_particles.size()):
			var particle = photon_trail_particles[i]
			if particle:
				flight_tween.parallel().tween_property(
					particle, "position", Vector3(6 - (i * 0.3), 0.8, 0), 2.5
				).set_delay(i * 0.08)

		# Reset positions after animation
		flight_tween.tween_callback(
			func():
				photon_node.position = Vector3(-6, 0.8, 0)
				for i in range(photon_trail_particles.size()):
					var particle = photon_trail_particles[i]
					if particle:
						particle.position = Vector3(-5.5 - (i * 0.3), 0.8, 0)
						particle.visible = false
		)

func flash_oracle_enhanced(target_id: int):
	"""Enhanced oracle flash with phase flip wave effect."""
	if oracle_label:
		oracle_label.visible = true
		var flash_tween = create_tween()
		flash_tween.parallel().tween_method(
			func(intensity):
				if oracle_label:
					oracle_label.modulate = Color(1, 0, 0, intensity)
			0.5, 1.0, 0.2
		)
		flash_tween.parallel().tween_method(
			func(intensity):
				if oracle_label:
					oracle_label.modulate = Color(1, 0, 0, intensity)
			1.0, 0.8, 0.3
		)

	# Flash target database item with enhanced effects
	if target_id < database_labels.size() and database_labels[target_id]:
		database_labels[target_id].modulate = Color.RED
		database_labels[target_id].text = "Item %d\nTARGET!\nPhase Flip" % target_id

		var item_flash = create_tween()
		item_flash.tween_property(database_labels[target_id], "modulate", Color.WHITE, 1.0)
		item_flash.tween_callback(
			func():
				if target_id < database_labels.size() and database_labels[target_id]:
					database_labels[target_id].text = "Item %d\nMarked\nOracle" % target_id
		)

func animate_diffusion_wave():
	"""Animate diffusion operator wave across database."""
	if diffusion_wave:
		diffusion_wave.visible = true
		var wave_tween = create_tween()

		# Expand wave across database
		wave_tween.parallel().tween_property(diffusion_wave, "scale", Vector3(8, 1, 4), 1.0)
		wave_tween.parallel().tween_method(
			func(energy):
				var material = diffusion_wave.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			2.0, 0.5, 1.0
		)

		# Hide and reset
		wave_tween.tween_callback(
			func():
				diffusion_wave.visible = false
				diffusion_wave.scale = Vector3(1, 1, 1)
		)

func show_qft_portal_enhanced():
	"""Show enhanced QFT portal with rotation and particle effects."""
	if qft_portal:
		qft_portal.visible = true
		var portal_tween = create_tween()
		portal_tween.set_loops()

		# Rotate portal continuously
		portal_tween.parallel().tween_property(qft_portal, "rotation_degrees", Vector3(0, 360, 0), 1.5)

		# Pulsing energy effect
		portal_tween.parallel().tween_method(
			func(energy):
				var material = qft_portal.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			4.0, 6.0, 0.75
		).set_trans(Tween.TRANS_SINE)

		portal_tween.parallel().tween_method(
			func(energy):
				var material = qft_portal.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			6.0, 4.0, 0.75
		).set_trans(Tween.TRANS_SINE)

func show_factor_discovery():
	"""Show factor peaks appearing after successful QFT."""
	for peak in factor_peaks:
		if peak:
			peak.visible = true
			var discovery_tween = create_tween()

			# Dramatic rise from ground
			peak.position.y = 0
			discovery_tween.parallel().tween_property(peak, "position:y", 1.5, 1.0)
			discovery_tween.parallel().tween_property(peak, "scale", Vector3(1.2, 1.2, 1.2), 1.0)

func update_chsh_meter(chsh_value: float):
	"""Update CHSH violation meter visualization."""
	if chsh_meter and chsh_meter_label:
		var height = (chsh_value / 3.0) * 3.0  # Scale to meter height
		var mesh = chsh_meter.mesh as BoxMesh
		if mesh:
			mesh.size.y = height
			chsh_meter.position.y = height / 2.0

		# Color based on violation
		var material = chsh_meter.get_surface_override_material(0)
		if material:
			if chsh_value > 2.0:
				material.albedo_color = Color.RED
				material.emission = Color.RED
				chsh_meter_label.text = "CHSH METER\nVALUE: %.2f\nQUANTUM!" % chsh_value
			else:
				material.albedo_color = Color.YELLOW
				material.emission = Color.YELLOW
				chsh_meter_label.text = "CHSH METER\nVALUE: %.2f\nClassical" % chsh_value

func animate_bell_pair_creation():
	"""Animate Bell pair creation between Alice and Bob."""
	if entanglement_beam:
		var creation_tween = create_tween()

		# Beam grows from center outward
		entanglement_beam.scale = Vector3(0.1, 0.1, 0.1)
		entanglement_beam.visible = true

		creation_tween.parallel().tween_property(entanglement_beam, "scale", Vector3(1, 28, 1), 1.0)
		creation_tween.parallel().tween_method(
			func(energy):
				var material = entanglement_beam.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			0.5, 2.5, 1.0
		)

func animate_measurement_collapse():
	"""Animate quantum measurement collapse effect."""
	if measurement_flash:
		measurement_flash.visible = true
		var collapse_tween = create_tween()

		# Sudden bright flash
		measurement_flash.scale = Vector3(0.1, 0.1, 0.1)
		collapse_tween.parallel().tween_property(measurement_flash, "scale", Vector3(3, 3, 3), 0.3)
		collapse_tween.parallel().tween_method(
			func(energy):
				var material = measurement_flash.get_surface_override_material(0)
				if material:
					material.emission_energy = energy,
			6.0, 0.0, 0.8
		)

		# Fade out
		collapse_tween.tween_callback(
			func():
				measurement_flash.visible = false
				measurement_flash.scale = Vector3(1, 1, 1)
		)

func create_portal_particles():
	"""Create optimized swirling particles around QFT portal (8 particles)."""
	portal_particles.clear()

	for i in range(8):  # Reduced for performance
		var particle = MeshInstance3D.new()
		var particle_mesh = SphereMesh.new()
		particle_mesh.radius = 0.12
		particle_mesh.height = 0.24
		particle.mesh = particle_mesh

		var particle_material = StandardMaterial3D.new()
		particle_material.albedo_color = Color.PURPLE
		particle_material.emission_enabled = true
		particle_material.emission = Color.PURPLE
		particle_material.emission_energy = 3.5
		particle_material.flags_transparent = true
		particle_material.rim_enabled = true
		particle_material.rim = 1.2
		particle.set_surface_override_material(0, particle_material)

		# Position in circle around portal
		var angle = (TAU * i) / 8
		var radius = 2.5
		particle.position = Vector3(cos(angle) * radius, 4, sin(angle) * radius)
		particle.visible = false

		add_child(particle)
		portal_particles.append(particle)

func animate_portal_fly_through():
	"""Animate flying through the QFT portal with surrounding particles."""
	# Show portal particles
	for particle in portal_particles:
		if particle:
			particle.visible = true

	# Create spiral animation
	for i in range(portal_particles.size()):
		var particle = portal_particles[i]
		if particle:
			var spiral_tween = create_tween()
			spiral_tween.set_loops()

			# Rotate around portal
			var angle = (TAU * i) / portal_particles.size()
			var radius_start = 2.5
			var radius_end = 0.5

			spiral_tween.tween_method(
				func(t):
					var current_angle = angle + (t * TAU * 2)  # 2 full rotations
					var current_radius = lerp(radius_start, radius_end, t)
					particle.position = Vector3(
						cos(current_angle) * current_radius,
						4,
						sin(current_angle) * current_radius
					)
				0.0, 1.0, 3.0
			).set_delay(i * 0.1)

func collapse_landscape_to_peaks():
	"""Collapse period landscape into sharp factor peaks."""
	# Hide/flatten period landscape
	for node in database_nodes:
		if node:
			var flatten_tween = create_tween()
			flatten_tween.tween_method(
				func(h):
					var mesh = node.mesh as BoxMesh
					if mesh:
						mesh.size.y = h
						node.position.y = h / 2.0
				node.mesh.size.y,
				0.2,
				1.0
			)

	# Show factor peaks emerging
	call_deferred("show_factor_discovery")
func create_central_step_display():
	"""Create big centered step text display at the top."""
	# Create background box for contrast
	step_display_background = MeshInstance3D.new()
	var bg_mesh = BoxMesh.new()
	bg_mesh.size = Vector3(10, 1.5, 0.1)
	step_display_background.mesh = bg_mesh
	step_display_background.position = Vector3(0, 6, 0)

	var bg_material = StandardMaterial3D.new()
	bg_material.albedo_color = Color(0, 0, 0, 0.9)
	bg_material.emission_enabled = true
	bg_material.emission = Color(0.1, 0.1, 0.1)
	bg_material.emission_energy = 0.5
	bg_material.flags_transparent = true
	step_display_background.set_surface_override_material(0, bg_material)
	step_display_background.visible = false
	add_child(step_display_background)

	# Create centered step label
	step_display_label = Label3D.new()
	step_display_label.text = ""
	step_display_label.position = Vector3(0, 6.5, 0)
	step_display_label.modulate = Color.WHITE
	step_display_label.font_size = 48
	step_display_label.outline_size = 10
	step_display_label.outline_modulate = Color.BLACK
	step_display_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	step_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	step_display_label.visible = false
	add_child(step_display_label)

func show_step_text(text: String, duration: float = 5.0):
	"""Show big step text at the top center of the screen."""
	if step_display_label and step_display_background:
		step_display_label.text = text
		step_display_label.visible = true
		step_display_background.visible = true

		# Auto-hide after duration
		var hide_timer = get_tree().create_timer(duration)
		hide_timer.timeout.connect(hide_step_text)

func hide_step_text():
	"""Hide the step text display."""
	if step_display_label:
		step_display_label.visible = false
	if step_display_background:
		step_display_background.visible = false

func update_step_text(step_text: String):
	"""Update current step explanation text."""
	current_step_text = step_text
	print("STEP: %s" % step_text)
	show_step_text(step_text, 6.0)

# ============================================================================
# LEGACY COMPATIBILITY FUNCTIONS - redirect to enhanced versions
# ============================================================================

func show_eve_attack():
	"""Legacy compatibility - redirect to enhanced version."""
	show_eve_attack_enhanced()

func hide_eve_attack():
	"""Legacy compatibility - redirect to enhanced version."""
	hide_eve_attack_enhanced()

func animate_photon_flight():
	"""Legacy compatibility - redirect to enhanced version."""
	animate_photon_flight_enhanced()

func flash_oracle(target_id: int):
	"""Legacy compatibility - redirect to enhanced version."""
	flash_oracle_enhanced(target_id)

func show_qft_portal():
	"""Legacy compatibility - redirect to enhanced version."""
	show_qft_portal_enhanced()

# ============================================================================
# CORE INITIALIZATION FUNCTIONS
# ============================================================================

func initialize_qubit_nodes():
	"""Initialize qubit spheres - create them if they don't exist."""
	qubit_nodes.clear()

	# Try to get existing nodes first, create if not found
	for i in range(3):
		var qubit_name = "Qubit%d" % i
		var qubit_node = get_node_or_null(qubit_name)

		if not qubit_node:
			# Create new qubit sphere
			qubit_node = MeshInstance3D.new()
			var sphere_mesh = SphereMesh.new()
			sphere_mesh.radius = 0.5
			sphere_mesh.height = 1.0
			qubit_node.mesh = sphere_mesh
			qubit_node.name = qubit_name
			add_child(qubit_node)

		qubit_nodes.append(qubit_node)
		qubit_node.visible = true

func initialize_database_grid():
	"""Create enhanced Grover database grid."""
	database_nodes.clear()

	for i in range(8):
		var box = MeshInstance3D.new()
		var mesh = BoxMesh.new()
		mesh.size = Vector3(0.8, 1.0, 0.8)
		box.mesh = mesh

		# Position in 2x4 grid
		var row = i / 4
		var col = i % 4
		var x = col * 2.0 - 3.0
		var z = row * 2.0 - 1.0
		box.position = Vector3(x, 0, z)

		add_child(box)
		database_nodes.append(box)

	print("Created database grid with %d items" % database_nodes.size())

func setup_qubit_materials():
	"""Create enhanced materials for BB84 qubits."""
	qubit_materials.clear()

	for i in qubit_nodes.size():
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.CYAN
		material.metallic = 0.3
		material.roughness = 0.1
		material.emission_enabled = true
		material.emission = Color.CYAN
		material.emission_energy = GLOW_INTENSITY

		# Enhanced visual effects
		material.rim_enabled = true
		material.rim = 0.6
		material.rim_tint = 0.8

		qubit_materials.append(material)

		if qubit_nodes[i]:
			qubit_nodes[i].set_surface_override_material(0, material)

func setup_database_materials():
	"""Create enhanced materials for Grover database."""
	database_materials.clear()

	for i in database_nodes.size():
		var material = StandardMaterial3D.new()
		material.albedo_color = Color.BLUE
		material.metallic = 0.4
		material.roughness = 0.2
		material.emission_enabled = true
		material.emission = Color.BLUE
		material.emission_energy = 1.5

		# Enhanced glow effect
		material.rim_enabled = true
		material.rim = 0.4
		material.rim_tint = 0.6

		database_materials.append(material)

		if database_nodes[i]:
			database_nodes[i].set_surface_override_material(0, material)

# BB84 visualization methods
func update_qubits(qubits_data: Array):
	"""Update BB84 qubit spheres with enhanced effects."""
	if current_mission != "bb84" or qubits_data.is_empty():
		return

	print("BB84: Updating %d qubits" % qubits_data.size())

	for qubit_data in qubits_data:
		var qubit_id = qubit_data["id"]

		if qubit_id >= qubit_nodes.size() or not qubit_nodes[qubit_id]:
			continue

		var phase = qubit_data.get("phase", 0.0)
		var probability = qubit_data.get("probability", 1.0)

		update_qubit_color(qubit_id, phase)
		update_qubit_scale(qubit_nodes[qubit_id], probability)
		update_qubit_glow(qubit_id, probability)

# Grover visualization methods
func update_database_grid(database_items: Array):
	"""Update Grover database with enhanced mountain effect."""
	if current_mission != "grover" or database_items.is_empty():
		return

	print("Grover: Updating %d database items" % database_items.size())

	for item_data in database_items:
		var item_id = item_data["id"]

		if item_id >= database_nodes.size() or not database_nodes[item_id]:
			continue

		var probability = item_data.get("probability", 0.0)
		var is_target = item_data.get("is_target", false)

		update_database_height(database_nodes[item_id], probability, is_target)
		update_database_color(item_id, probability, is_target)

func start_quantum_pulse_animation():
	"""Start subtle pulsing animation for qubits."""
	if not animation_tween:
		return

	for i in range(qubit_materials.size()):
		var material = qubit_materials[i]
		if not material:
			continue

		# Ensure emission is enabled in Godot 4
		material.emission_enabled = true

		# Get base energy value (default to 1.0 if not set)
		var base_energy = 1.0
		if material.has_method("get") and material.get("emission_energy") != null:
			base_energy = material.emission_energy
		else:
			material.emission_energy = base_energy

		animation_tween.parallel().tween_method(
			func(energy):
				if material and is_instance_valid(material):
					material.emission_energy = energy,
			base_energy * 0.7,
			base_energy * 1.3,
			PULSE_SPEED
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		animation_tween.parallel().tween_method(
			func(energy):
				if material and is_instance_valid(material):
					material.emission_energy = energy,
			base_energy * 1.3,
			base_energy * 0.7,
			PULSE_SPEED
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func update_database_height(box_node: MeshInstance3D, probability: float, is_target: bool):
	"""Enhanced database height with smooth animations and probability display."""
	var min_height = 0.5
	var max_height = 5.0 if is_target else 3.5  # Target can grow taller
	var height = lerp(min_height, max_height, probability)

	# Smooth animation
	if animation_tween:
		animation_tween.parallel().tween_method(
			func(h):
				var mesh = box_node.mesh as BoxMesh
				mesh.size.y = h
				box_node.position.y = h / 2.0
			box_node.mesh.size.y,
			height,
			0.4
		).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

	# Update label with probability percentage
	var item_id = -1
	for i in range(database_nodes.size()):
		if database_nodes[i] == box_node:
			item_id = i
			break

	if item_id >= 0 and item_id < database_labels.size() and database_labels[item_id]:
		var percentage = probability * 100.0
		var status = "Quantum" if is_target else "Amplified" if percentage > 15 else "Classical"
		database_labels[item_id].text = "Item %d\n%.1f%%\n%s" % [item_id, percentage, status]

		# Animate diffusion wave effect periodically
		if is_target and probability > 0.6:
			animate_diffusion_wave()

func update_database_color(item_id: int, probability: float, is_target: bool):
	"""Enhanced database coloring with glow effects."""
	if item_id >= database_materials.size():
		return

	var material = database_materials[item_id]
	var base_color: Color
	var glow_intensity: float

	if is_target:
		# Target: Red spectrum with high intensity
		base_color = Color.RED.lerp(Color(1.0, 0.3, 0.1), probability)
		glow_intensity = lerp(2.0, 6.0, probability)
	else:
		# Non-target: Blue to cyan spectrum
		base_color = Color.BLUE.lerp(Color.CYAN, probability * 0.7)
		glow_intensity = lerp(0.8, 2.5, probability)

	material.albedo_color = base_color
	material.emission = base_color
	material.emission_energy = glow_intensity

# Helper methods
func update_qubit_color(qubit_id: int, phase: float):
	if qubit_id >= qubit_materials.size():
		return

	var material = qubit_materials[qubit_id]
	var color = phase_to_color(phase)

	material.albedo_color = color
	material.emission = color

func phase_to_color(phase: float) -> Color:
	var hue = (phase + PI) / (2 * PI)
	hue = fmod(hue + 1.0, 1.0)
	return Color.from_hsv(hue, 0.9, 1.0)

func update_qubit_scale(qubit_node: MeshInstance3D, probability: float):
	var target_scale = lerp(MIN_SCALE, MAX_SCALE, probability)
	var scale_vector = Vector3(target_scale, target_scale, target_scale)

	if animation_tween:
		animation_tween.parallel().tween_property(qubit_node, "scale", scale_vector, 0.2)
	else:
		qubit_node.scale = scale_vector

func update_qubit_glow(qubit_id: int, probability: float):
	if qubit_id >= qubit_materials.size():
		return

	var material = qubit_materials[qubit_id]
	var glow_strength = lerp(2.0, GLOW_INTENSITY, probability)
	material.emission_energy = glow_strength

func position_qubits_circular(radius: float = 5.0):
	for i in range(qubit_nodes.size()):
		if not qubit_nodes[i]:
			continue

		var angle = (TAU * i) / qubit_nodes.size()
		var x = radius * cos(angle)
		var z = radius * sin(angle)
		var y = sin(angle * 2) * 2.0

		qubit_nodes[i].position = Vector3(x, y, z)

	print("Positioned %d qubits in circular formation" % qubit_nodes.size())

func _exit_tree():
	if animation_tween:
		animation_tween.kill()
