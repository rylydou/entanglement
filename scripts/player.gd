class_name Player extends RigidBody2D

static var current: Player
static var respawn_point: Vector2

func _ready() -> void:
	if is_instance_valid(current):
		printerr('Cannot spawn player - A player already exsits')
		queue_free()
		return
	current = self
	
	respawn_point = global_position

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('debug_reload', true):
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed('debug_setspawn', true):
		respawn_point = global_position
	if Input.is_action_just_pressed('debug_respawn', true):
		global_position = respawn_point
	if Input.is_action_just_pressed('debug_teleport', true):
		global_position = get_global_mouse_position()
