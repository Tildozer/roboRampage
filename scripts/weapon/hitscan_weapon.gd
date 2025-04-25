extends Node3D

@onready var cooldown_timer: Timer = $cooldown_timer

@export var fire_rate := 14.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("fire_weapon") and cooldown_timer.is_stopped():
		cooldown_timer.start(1.0 / fire_rate)
		print("Firing weapon!")
