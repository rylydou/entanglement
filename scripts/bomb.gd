extends Orb

@export var force := 2.

func _ready() -> void:
	super._ready()
	pressed.connect(_pressed)

func _pressed() -> void:
	if $Sprite2D.frame != 0: return
	$Sprite2D.frame = 1
	$Timer.start()
	$AnimationPlayer.stop()
	$AnimationPlayer.play('shockwave')
	$ExplodeSound.play()
	var player := Player.current
	var dir_to_player = global_position.direction_to(player.global_position)
	player.apply_impulse(dir_to_player*force*gravity)

func _on_timer_timeout() -> void:
	$Sprite2D.frame = 0
