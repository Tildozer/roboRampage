extends CharacterBody3D
class_name Player

const SPEED = 5.0

@export var max_health := 100
@export var jump_height := 1.0
@export var fall_multiplier := 2.5

var mouse_motion := Vector2.ZERO
var curr_health := max_health:
	set(value):
		if value < curr_health:
			animation_player.stop(false)
			animation_player.play("take_damage")
		curr_health = value
		if curr_health <= 0:
			gameover_menu.gameover()

@onready var animation_player: AnimationPlayer = $damage_texture/AnimationPlayer
@onready var camera_pivot: Node3D = $camera_pivot
@onready var gameover_menu: Control = $gameover_menu
@onready var ammo_handler: AmmoHandler = %ammo_handler

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	handleCameraRotation()
	# Add the gravity.
	if not is_on_floor():
		if velocity.y >= 0:
			velocity += get_gravity() * delta
		else:
			velocity.y += get_gravity().y * delta * fall_multiplier

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * 2.0 * -get_gravity().y)

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.005
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func handleCameraRotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0
	)
	mouse_motion = Vector2.ZERO