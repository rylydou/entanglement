extends Node2D

@onready var grav := float(ProjectSettings.get_setting('physics/2d/default_gravity'))
@onready var click_area: Area2D = $ClickArea

@export var force := 2.

var is_active := false
var contains_mouse := false

func _ready() -> void:
	click_area.input_event.connect(_on_input_event)
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)

func _physics_process(delta: float) -> void:
	if not is_active: return
	var player := Player.current
	var dir_from_player_to_self = player.global_position.direction_to(global_position)
	#player.apply_force(dir_from_player_to_self*force)
	player.linear_velocity.y -= grav*delta
	player.apply_central_force(dir_from_player_to_self*force*grav)

func update_state() -> void:
	if is_active or contains_mouse:
		click_area.scale = Vector2.ONE*3
		return
	click_area.scale = Vector2.ONE*1

func _input(event: InputEvent) -> void:
	var mouse_btn_event := event as InputEventMouseButton
	if not mouse_btn_event: return
	
	if mouse_btn_event.button_index == 1 and mouse_btn_event.is_released():
		is_active = false
		update_state()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var mouse_btn_event := event as InputEventMouseButton
	if mouse_btn_event:
		if mouse_btn_event.button_index == 1 and mouse_btn_event.is_pressed():
			is_active = true
			update_state()

func _on_mouse_entered() -> void:
	contains_mouse = true
	update_state()

func _on_mouse_exited() -> void:
	contains_mouse = false
	update_state()
