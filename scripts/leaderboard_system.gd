extends Node

signal error(error: String)
signal auth()
signal name_changed()
signal leaderboard_changed()

const debug := false
@onready var game_API_key := 'dev_b48459a9e5704d14a1d6e391cbbe64bf' if debug else 'prod_7ccfa4e98900459f9a74a627272e1eae'
@onready var development_mode := debug
var leaderboard_key := 'time_anypercent'
var session_token := ''
var player_name := ''
var leaderboard := []

# HTTP Request node can only handle one call per node
var auth_http := HTTPRequest.new()
var leaderboard_http := HTTPRequest.new()
var submit_score_http := HTTPRequest.new()
var set_name_http := HTTPRequest.new()
var get_name_http := HTTPRequest.new()

func check_error(json: Dictionary) -> bool:
	if not json:
		print('LEADERBOARD Not JSON')
		return true
	if json.has('error'):
		print('LEADERBOARD Error: ', json.error)
		return true
	return false

func _ready():
	request_authentication()
	process_mode = Node.PROCESS_MODE_ALWAYS

func request_authentication():
	# Check if a player session has been saved
	var player_session_exists := false
	var player_identifier := ''
	if FileAccess.file_exists("user://LootLocker.data"):
		var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
		player_identifier = file.get_as_text()
		file.close()
	
	if(player_identifier.length() > 1):
		player_session_exists = true
		
	## Convert data to json string:
	var data = { "game_key": game_API_key, "game_version": "0.0.0.1", "development_mode": true }
	
	# If a player session already exists, send with the player identifier
	if(player_session_exists == true):
		data = { "game_key": game_API_key, "player_identifier": player_identifier, "game_version": "0.0.0.1", "development_mode": true }
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	# Create a HTTPRequest node for authentication
	auth_http = HTTPRequest.new()
	add_child(auth_http)
	auth_http.request_completed.connect(_on_authentication_request_completed)
	# Send request
	auth_http.request("https://api.lootlocker.io/game/v2/session/guest", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	print('LOADBOARD Auth Send: ', data)

func _on_authentication_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if check_error(json): return
	print('LEADERBOARD Auth Recive: ', json)
	
	# Save player_identifier to file
	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	file.store_string(json.player_identifier)
	file.close()
	
	# Save session_token to memory
	session_token = json.session_token
	
	auth.emit()
	
	# Clear node
	auth_http.queue_free()
	
	get_player_name()

func get_leaderboards():
	if session_token.length() == 0: return
	
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPRequest.new()
	add_child(leaderboard_http)
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	leaderboard_http.request(url, headers, HTTPClient.METHOD_GET, "")

func _on_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if check_error(json): return
	print('LEADERBOARD Data: ', json)
	
	leaderboard = json.items
	
	# Formatting as a leaderboard
	var leaderboardFormatted = ""
	for n in json.items.size():
		leaderboardFormatted += str(json.items[n].rank)+str(". ")
		leaderboardFormatted += str(json.items[n].player.id)+str(" - ")
		leaderboardFormatted += str(json.items[n].score)+str("\n")
	
	# Print the formatted leaderboard to the console
	print(leaderboardFormatted)
	
	leaderboard_changed.emit()
	
	# Clear node
	leaderboard_http.queue_free()

func upload_score(score: int):
	if session_token.length() == 0: return
	
	var data = { "score": str(score) }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPRequest.new()
	add_child(submit_score_http)
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request("https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	print('LOADBOARD Upload Data: ', data)

func _on_upload_score_request_completed(result, response_code, headers, body) :
	var json = JSON.parse_string(body.get_string_from_utf8())
	if check_error(json): return
	
	# Print data
	print('LEADERBOARD Upload Response: ', json)
	
	# Clear node
	submit_score_http.queue_free()

func change_player_name():
	if session_token.length() == 0: return
	
	var data = { "name": str(player_name) }
	var url =  "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	set_name_http = HTTPRequest.new()
	add_child(set_name_http)
	set_name_http.request_completed.connect(_on_player_set_name_request_completed)
	# Send request
	set_name_http.request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	
func _on_player_set_name_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if check_error(json): return
	print('LEADERBOARD Set Player Name', json)
	
	player_name = json.name
	
	set_name_http.queue_free()
	name_changed.emit()

func get_player_name():
	if session_token.length() == 0: return
	
	var url = "https://api.lootlocker.io/game/player/name"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	get_name_http = HTTPRequest.new()
	add_child(get_name_http)
	get_name_http.request_completed.connect(_on_player_get_name_request_completed)
	# Send request
	get_name_http.request(url, headers, HTTPClient.METHOD_GET, "")

func _on_player_get_name_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	if check_error(json): return
	print('LEADERBOARD Get Name: ', json)
	
	player_name = json.name
	
	get_name_http.queue_free()
	name_changed.emit()
