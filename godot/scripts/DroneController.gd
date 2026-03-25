extends CharacterBody3D

const SPEED = 12.0
const ACCEL = 8.0
const DECEL = 10.0
const MOUSE_SENSITIVITY = 0.002
const MAX_PITCH = deg_to_rad(89.0)

var mouse_input = Vector2.ZERO
var camera: Camera3D
var is_mouse_captured = false

func _ready():
	camera = $Camera3D
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_mouse_captured = true
	print("Drone Controller ready - WASD+Mouse controls active")

func _input(event):
	if not is_mouse_captured:
		return
	if event is InputEventMouseMotion:
		mouse_input = event.relative

func _physics_process(delta):
	if mouse_input.length() > 0:
		handle_mouse_look()
	handle_movement(delta)
	move_and_slide()

func handle_mouse_look():
	rotate_y(-mouse_input.x * MOUSE_SENSITIVITY)
	camera.rotate_x(-mouse_input.y * MOUSE_SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, -MAX_PITCH, MAX_PITCH)
	mouse_input = Vector2.ZERO

func handle_movement(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = Vector3.ZERO

	if input_dir != Vector2.ZERO:
		direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction.length() > 0:
		velocity.x = move_toward(velocity.x, direction.x * SPEED, ACCEL * delta * SPEED)
		velocity.z = move_toward(velocity.z, direction.z * SPEED, ACCEL * delta * SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0.0, DECEL * delta * SPEED)
		velocity.z = move_toward(velocity.z, 0.0, DECEL * delta * SPEED)

	velocity.y = 0.0

func _unhandled_input(event):
	if event.is_action_pressed("exit_mission"):
		exit_mission()

func exit_mission():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")