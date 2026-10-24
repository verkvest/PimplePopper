extends Node


var playgames = null


func _ready() -> void:
	if OS.get_name() != "Android":
		return
	if not Engine.has_singleton("GodotGooglePlayGameServices"):
		return
	playgames = Engine.get_singleton("GodotGooglePlayGameServices")
	if playgames == null:
		return
	playgames.connect("leaderboardsAllLoaded", Callable(self, "_on_allLeaderboardsLoaded"))
	playgames.connect("signInUserAuthenticated", Callable(self, "_on_signInUserAuthenticated"))


func _on_allLeaderboardsLoaded(leaderboards: String) -> void:
	var parsed_leaderboards = JSON.parse_string(leaderboards)
	prints(parsed_leaderboards)


func _on_signInUserAuthenticated():
	print('login sucessful!')
