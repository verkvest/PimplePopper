extends Node

const DEBUG_LANGUAGE_PATH: String = "res://data/language.txt"
const RELEASE_LANGUAGE_PATH: String = "user://language.txt"

var _data: Dictionary
var _language_path: String

func _ready():
	_language_path = RELEASE_LANGUAGE_PATH
	load_data()


func load_data() -> void:
	TranslationServer.set_locale(get_language())


func save_language(lang: String) -> void:
	var f := FileAccess.open(_language_path, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(lang)
	f.close()

func get_language() -> String:
	if FileAccess.file_exists(_language_path):
		var f := FileAccess.open(_language_path, FileAccess.READ)
		if f != null:
			var t := f.get_as_text().strip_edges()
			f.close()
			if t != "":
				return t
	return "en"
