extends Node

const SAVE_PATH = 'user://player_data.json'

var type: String = "pimple" 
var bodypart: String = "cheek"
var level: String = "easy"

var _scenes = {
	"pimple": {
		"cheek": "res://bodyparts/pimple/cheek.tscn",
		"forehead": "res://bodyparts/pimple/forehead.tscn",
		"back": "res://bodyparts/pimple/back.tscn",
		"chest": "res://bodyparts/pimple/chest.tscn",
		"buttocks": "res://bodyparts/pimple/butt.tscn",
		"nose": "res://bodyparts/pimple/nose.tscn"
	},
	"blackhead": {
		"cheek": "res://bodyparts/blackhead/cheek.tscn",
		"forehead": "res://bodyparts/blackhead/forehead.tscn",
		"nose": "res://bodyparts/blackhead/nose.tscn",
		"shoulder": "res://bodyparts/blackhead/shoulder.tscn",
		"back": "res://bodyparts/blackhead/back.tscn",
		"ear": "res://bodyparts/blackhead/ear.tscn",
	},
	"cyst": {
		"forehead": "res://bodyparts/cyst/forehead.tscn",
		"wrist": "res://bodyparts/cyst/wrist.tscn",
		"back": "res://bodyparts/cyst/back.tscn",
		"shin": "res://bodyparts/cyst/shin.tscn"
	},
	"lipoma": {
		"back": "res://bodyparts/lipoma/back.tscn",
		"arm": "res://bodyparts/lipoma/arm.tscn"
	}
}

var _levels: Dictionary = {
	"pimple": [
		{
			"name": "K_CHEEK_LEVEL_BUTTON",
			"code": "cheek"
		},
		{
			"name": "K_FOREHEAD_LEVEL_BUTTON",
			"code": "forehead"
		},
		{
			"name": "K_BACK_LEVEL_BUTTON",
			"code": "back"
		},
		{
			"name": "K_CHEST_LEVEL_BUTTON",
			"code": "chest"
		},
		{
			"name": "K_BUTTOCKS_BUTTON",
			"code": "buttocks"
		},
		{
			"name": "K_NOSE_BUTTON",
			"code": "nose"
		}
	],
	"blackhead": [
		{
			"name": "K_CHEEK_LEVEL_BUTTON",
			"code": "cheek"
		},
		{
			"name": "K_FOREHEAD_LEVEL_BUTTON",
			"code": "forehead"
		},
		{
			"name": "K_NOSE_BUTTON",
			"code": "nose"
		},
		{
			"name": "K_SHOULDER_BUTTON",
			"code": "shoulder"
		},
		{
			"name": "K_BACK_LEVEL_BUTTON",
			"code": "back"
		},
		{
			"name": "K_EAR_LEVEL_BUTTON",
			"code": "ear"
		},
	],
	"cyst": [
		{
			"name": "K_FOREHEAD_LEVEL_BUTTON",
			"code": "forehead"
		},
		{
			"name": "K_WRIST_LEVEL_BUTTON",
			"code": "wrist"
		},
		{
			"name": "K_BACK_LEVEL_BUTTON",
			"code": "back"
		},
		{
			"name": "K_SHIN_BUTTON",
			"code": "shin"
		}
	],
	"lipoma": [
		{
			"name": "K_BACK_LEVEL_BUTTON",
			"code": "back"
		},
		{
			"name": "K_ARM_LEVEL_BUTTON",
			"code": "arm"
		}
	]
}

var _window_relation: Vector2
var _window_project_size: Vector2
var relative_screen_size_x: float

var player_data_orig = {}
var player_data: Dictionary = {
	'is_ad_active': false,
	'levels_completion': {
		'pimple':{
			'cheek': false,
			'back': false,
			'butt': false,
			'chest': false,
			'forehead': false,
			'nose': false,
		},
		'cyst':{
			'back': false,
			'forehead': false,
			'wrist': false,
			'shin': false,
		},
		'lipoma':{
			'back': false,
			'arm': false,
		},
		'blackhead':{
			'back': false,
			'cheek': false,
			'ear': false,
			'forehead': false,
			'nose': false,
			'shoulder': false,
		}
	},
	'day': 0,
	'month': 0,
	'day_streak':0,
	'month_streak':0
}

func _ready():
	player_data_orig = player_data.duplicate(true)
	
	var width: float = ProjectSettings.get_setting("display/window/size/viewport_width")
	var height: float = ProjectSettings.get_setting("display/window/size/viewport_height")
	_window_project_size = Vector2(width, height)
	_refresh_metrics()
	
	if FileAccess.file_exists(SAVE_PATH):
		load_game()
	else:
		save_game()
	
	check_time_achievements()


func view_size() -> Vector2:
	var tree := get_tree()
	if tree and tree.root:
		var r := tree.root.get_visible_rect().size
		if r.x > 1.0 and r.y > 1.0:
			return r
	if _window_project_size.x > 1.0:
		return _window_project_size
	return Vector2(1220, 540)


func _refresh_metrics() -> void:
	var visible := view_size()
	if _window_project_size.x < 1.0 or visible.x < 1.0 or visible.y < 1.0:
		return
	_window_relation = Vector2(_window_project_size.x / visible.x, _window_project_size.y / visible.y)
	var ry: float = visible.y / _window_project_size.y
	if ry > 0.0:
		relative_screen_size_x = visible.x / ry


func get_relative_screen_size_x() -> float:
	return relative_screen_size_x

func get_window_relation() -> Vector2:
	return _window_relation

func get_window_project_size() -> Vector2:
	return _window_project_size

func get_level() -> Node2D:
	return load(_scenes[type][bodypart]).instantiate()

func is_protuberance_type_available (t: String) -> bool:
	return _levels[t] != null

func is_level_available(bp: String) -> bool:
	var ls = _levels[type]
	for l in ls:
		if l["code"] == bp:
			return true
	return false

func get_bodypart_scale(sprite_size: Vector2) -> Vector2:
	var new_x: float = Global.view_size().x / sprite_size.x
	var new_y: float = Global.view_size().y / sprite_size.y
	var size: Vector2
	if new_y < new_x:
		size = Vector2(new_y, new_y)
	else:
		size = Vector2(new_x, new_x)
	return size

func get_bodyparts(plevel: String) -> Array:
	return _levels[plevel]


func load_game():
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	player_data = parsed
	player_data.merge(player_data_orig, false)


func save_game():
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(player_data))
	f.close()


func _notification(what):
	if what == NOTIFICATION_WM_SIZE_CHANGED:
		_refresh_metrics()
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		save_game()


func check_time_achievements():
	var time = Time.get_datetime_dict_from_system()
	
	var current_total_days = (time['month'] * 30) + time['day']
	
	if player_data['day'] == 0 and player_data['month'] == 0:
		player_data['day'] = current_total_days
	else:
		pass
	
	if player_data['day'] == player_data['day'] - 1:
		player_data['day_streak'] += 1
		
		if player_data['day_streak'] == 14:
			_unlock('CgkI5ILm9-4PEAIQBg')
		if player_data['day_streak'] == 30:
			_unlock('CgkI5ILm9-4PEAIQBw')
	else:
		player_data['day_streak'] = 0
	
	player_data['day'] = current_total_days


func _unlock(achievement_id: String) -> void:
	if ManagerPlayGames.playgames:
		ManagerPlayGames.playgames.achievementsUnlock(achievement_id, true)
