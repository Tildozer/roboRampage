extends Node3D

@export var fire_rate := 14.0
@export var recoil := 0.05
@export var weapon_mesh: Node3D
@export var weapon_damage := 15

@onready var cooldown_timer: Timer = $cooldown_timer
@onready var weapon_position: Vector3 = weapon_mesh.position
@onready var raycast: RayCast3D = $RayCast3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("fire_weapon") and cooldown_timer.is_stopped():
		shoot()
	
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta * 10.0)

func shoot() -> void:
	cooldown_timer.start(1.0 / fire_rate)
	var collider = raycast.get_collider()
	weapon_mesh.position.z += recoil
	if collider is Enemy:
		collider.curr_health -= weapon_damage
