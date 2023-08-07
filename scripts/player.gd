class_name Player extends RigidBody2D

static var current: Player
static var respawn_point: Vector2

@export_flags_2d_physics var orb_layer: int

@onready var target_node: Node2D = $Target

var rot_left := 1.

var active_orb: Orb

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
	if Input.is_action_just_pressed('debug_teleport', true):
		global_position = get_global_mouse_position()


var last_contact_count := 0

func _physics_process(delta: float) -> void:
	if active_orb:
		active_orb.held.emit(delta)
		target_node.global_position = active_orb.global_position
		target_node.show()
		
		if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			active_orb.is_held = false
			active_orb.update_state()
			active_orb.released.emit()
			active_orb = null
	else:
		var query := PhysicsPointQueryParameters2D.new()
		query.position = get_global_mouse_position()
		query.collision_mask = orb_layer
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var space := get_world_2d().direct_space_state
		var dicts := space.intersect_point(query, 1)
		
		if dicts.size() > 0:
			var dict := dicts.front()
			var collider := dict.collider as Node2D
			var obj := collider.get_parent() as Node2D
			
			target_node.global_position = obj.global_position
			target_node.show()
			
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
				active_orb = obj
				active_orb.is_held = true
				active_orb.update_state()
				active_orb.pressed.emit()
				active_orb.held.emit(delta)
		else:
			target_node.hide()
	
	if get_contact_count() > last_contact_count:
		$LandSound.play()
	
	last_contact_count = get_contact_count()
	
	if last_contact_count > 0:
		rot_left -= abs(angular_velocity)*delta
	if rot_left < 0:
		rot_left = 1.
		$RollSound.play()
