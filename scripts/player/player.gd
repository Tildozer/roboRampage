extends CharacterBody3D
class_name Player

@export var speed = 8.0
@export var max_health := 100
@export var jump_height := 1.0
@export var fall_multiplier := 2.5
@export var aim_multiplier := 0.7

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

@onready var gameover_menu: Control = $gameover_menu

@onready var ammo_handler: AmmoHandler = %ammo_handler

@onready var camera_pivot: Node3D = $camera_pivot
@onready var smooth_camera: Camera3D = %smooth_camera
@onready var smooth_default_fov := smooth_camera.fov

@onready var weapon_camera: Camera3D = %weapon_camera
@onready var weapon_default_fov := weapon_camera.fov


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	if Input.is_action_pressed("aim"):
		smooth_camera.fov = lerp(
			smooth_camera.fov, 
			smooth_default_fov * aim_multiplier, 
			delta * 20
		)
		weapon_camera.fov = lerp(
			weapon_camera.fov, 
			weapon_default_fov * aim_multiplier, 
			delta * 20
		)
	else:
		smooth_camera.fov = lerp(
			smooth_camera.fov, 
			smooth_default_fov, 
			delta * 30
		)
		weapon_camera.fov = lerp(
			weapon_camera.fov, 
			weapon_default_fov, 
			delta * 30
		)

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
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if Input.is_action_pressed("aim"):
			velocity.x *= aim_multiplier
			velocity.z *= aim_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.005
			if Input.is_action_pressed("aim"):
				mouse_motion *= aim_multiplier
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func handleCameraRotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(
		camera_pivot.rotation_degrees.x, -90.0, 90.0
	)
	mouse_motion = Vector2.ZERO
