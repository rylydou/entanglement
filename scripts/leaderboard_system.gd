extends Node

# Use this game API key if you want to test it with a functioning leaderboard
# "987dbd0b9e5eb3749072acc47a210996eea9feb0"
var game_API_key = "dev_b48459a9e5704d14a1d6e391cbbe64bf"
var development_mode = true
var leaderboard_key = "time_anypercent"
var session_token = ""
var score = 0

# HTTP Request node can only handle one call per node
var auth_http = HTTPClient.new()
var leaderboard_http = HTTPClient.new()
var submit_score_http = HTTPClient.new()

func _ready():
	_authentication_request()

func _process(_delta):
	if(Input.is_action_just_pressed("ui_up")):
		score += 1
		print("CurrentScore:"+str(score))
	
	if(Input.is_action_just_pressed("ui_down")):
		score -= 1
		print("CurrentScore:"+str(score))
	
	# Upload score when pressing enter
	if(Input.is_action_just_pressed("ui_accept")):
		_upload_score(score)
	
	# Get score when pressing spacebar
	if(Input.is_action_just_pressed("ui_select")):
		_get_leaderboards()


func _authentication_request():
	# Check if a player session has been saved
	var player_session_exists = false
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	var player_identifier = file.get_as_text()
	file.close()
	if(player_identifier.length() > 1):
		player_session_exists = true
		
	## Convert data to json string:
	var data = { "game_key": game_API_key, "game_version": "0.0.0.1", "development_mode": true }
	
	# If a player session already exists, send with the player identifier
	if(player_session_exists == true):
		data = { "game_key": game_API_key, "player_identifier":player_identifier, "game_version": "0.0.0.1", "development_mode": true }
	
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	
	# Create a HTTPRequest node for authentication
	auth_http = HTTPClient.new()
	auth_http.request_completed.connect(_on_authentication_request_completed)
	# Send request
	auth_http.request(HTTPClient.METHOD_POST, "https://api.lootlocker.io/game/v2/session/guest", headers, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	print('LOADBOARD Auth Send: ', data)


func _on_authentication_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	# Save player_identifier to file
	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	file.store_string(json.result.player_identifier)
	file.close()
	
	# Save session_token to memory
	session_token = json.result.session_token
	
	# Print server response
	print('LEADERBOARD Auth Recive: ', json.result)
	
	# Clear node
	auth_http.queue_free()
	# Get leaderboards
	_get_leaderboards()


func _get_leaderboards():
	print("Getting leaderboards")
	var url = "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/list?count=10"
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	
	# Create a request node for getting the highscore
	leaderboard_http = HTTPClient.new()
	leaderboard_http.request_completed.connect(_on_leaderboard_request_completed)
	leaderboard_http.request(HTTPClient.METHOD_GET, url, headers, "")


func _on_leaderboard_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# Print data
	print('LEADERBOARD Data: ', json.result)
	
	# Formatting as a leaderboard
	var leaderboardFormatted = ""
	for n in json.result.items.size():
		leaderboardFormatted += str(json.result.items[n].rank)+str(". ")
		leaderboardFormatted += str(json.result.items[n].player.id)+str(" - ")
		leaderboardFormatted += str(json.result.items[n].score)+str("\n")
	
	# Print the formatted leaderboard to the console
	print(leaderboardFormatted)
	
	# Clear node
	leaderboard_http.queue_free()


func _upload_score(score):
	var data = { "score": str(score) }
	var headers = ["Content-Type: application/json", "x-session-token:"+session_token]
	submit_score_http = HTTPClient.new()
	submit_score_http.request_completed.connect(_on_upload_score_request_completed)
	# Send request
	submit_score_http.request(HTTPClient.METHOD_POST, "https://api.lootlocker.io/game/leaderboards/"+leaderboard_key+"/submit", headers, JSON.stringify(data))
	# Print what we're sending, for debugging purposes:
	print('LOADBOARD Upload Data: ', data)


func _on_upload_score_request_completed(result, response_code, headers, body) :
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	# Print data
	print('LEADBOARD Upload Response: ', json.result)
	
	# Clear node
	submit_score_http.queue_free()
