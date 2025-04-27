extends Node3D

@export var weapon_1: Node3D
@export var weapon_2: Node3D

# @export var weapons: Array[Node3D]

func _ready() -> void:
	equip(weapon_1)

func equip(active_weapon: Node3D) -> void:
	for child in get_children():
		if child == active_weapon:
			child.visible = true
			child.set_process(true)
		else:
			child.visible = false
			child.set_process(false)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("weapon_1"):
		equip(weapon_1)
	if event.is_action_pressed("weapon_2"):
		equip(weapon_2)
	if event.is_action_pressed("next_weapon"):
		next_weapon(true)
	if event.is_action_pressed("prev_weapon"):
		next_weapon(false)

func next_weapon(next: bool) -> void:
	var idx = get_current_idx()
	if next:
		idx = wrap(idx + 1, 0, get_child_count())
		equip(get_child(idx))
	else: 
		idx = wrap(idx - 1, 0, get_child_count())
		equip(get_child(idx))

func get_current_idx() -> int:
	var total_weapons = get_child_count()
	for idx in total_weapons:
		if get_child(idx).visible:
			return idx
	return 0
