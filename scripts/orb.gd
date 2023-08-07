class_name Orb extends Node2D

signal pressed()
signal held(delta: float)
signal released()

@onready var gravity := float(ProjectSettings.get_setting('physics/2d/default_gravity'))
@onready var click_area: Area2D = %ClickArea

@export var hover_scale := 3.0

var is_held := false
var contains_mouse := false

func _ready() -> void:
	click_area.mouse_entered.connect(_on_mouse_entered)
	click_area.mouse_exited.connect(_on_mouse_exited)

func update_state() -> void:
	if is_held or contains_mouse:
		click_area.scale = Vector2.ONE*hover_scale
		return
	click_area.scale = Vector2.ONE*1

func _on_mouse_entered() -> void:
	contains_mouse = true
	update_state()

func _on_mouse_exited() -> void:
	contains_mouse = false
	update_state()
