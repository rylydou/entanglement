extends Node2D

@onready var grav := float(ProjectSettings.get_setting('physics/2d/default_gravity'))
@onready var click_area: Area2D = $ClickArea

@export var force := 2.

func _ready() -> void:
	click_area.input_event.connect(_on_input_event)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var mouse_btn_event := event as InputEventMouseButton
	if not mouse_btn_event: return
	
	if mouse_btn_event.button_index == 1 and mouse_btn_event.is_pressed():
		if $Sprite2D.frame != 0: return
		$Sprite2D.frame = 1
		$Timer.start()
		$AnimationPlayer.stop()
		$AnimationPlayer.play('shockwave')
		var player := Player.current
		var dir_to_player = global_position.direction_to(player.global_position)
		player.apply_impulse(dir_to_player*force*grav)


func _on_timer_timeout() -> void:
	$Sprite2D.frame = 0
