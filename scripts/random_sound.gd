extends Node2D

@export_dir var folder := ''
var sounds: Array[AudioStream] = []

var next_index := 0
var players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	for file in DirAccess.get_files_at(folder):
		if file.ends_with('.wav.import'):
			var sound := load(folder + '/' + file.trim_suffix('.import'))
			sounds.append(sound)
	generate(4)

func generate(amount: int) -> void:
	var player := AudioStreamPlayer2D.new()
	player.max_distance = 800
	player.top_level = true
	add_child(player)
	players.append(player)

func play() -> void:
	var player := players[next_index] as AudioStreamPlayer2D
	next_index += 1
	if next_index == players.size():
		next_index = 0
	
	player.stream = sounds.pick_random()
	player.global_position = global_position
	player.play()
