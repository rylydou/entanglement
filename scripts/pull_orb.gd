extends Orb

@export var force := 2.
var last_sound := 0.

func _ready() -> void:
	super._ready()
	pressed.connect(_pressed)
	held.connect(_held)
	released.connect(_released)

func _pressed() -> void:
	$Line.show()
	$Target.show()
	last_sound = 0.

func _released() -> void:
	$Line.hide()
	$Target.hide()

func _held(delta: float) -> void:
	last_sound -= delta
	if last_sound < 0:
		$PullSound.play()
		last_sound = .5
	var player := Player.current
	var dir_from_player_to_self = player.global_position.direction_to(global_position)
	player.linear_velocity.y -= gravity*delta
	player.apply_central_force(dir_from_player_to_self*force*gravity)
	
	$Line.set_point_position(1, to_local(player.global_position))
	$Target.global_position = player.global_position
