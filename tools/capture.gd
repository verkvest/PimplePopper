extends Node

## Headless-friendly screenshot helper. `godot --path . -- --shot <dir>` saves a phone-sized menu and a cheek level.


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var dir := ""
	for i in args.size():
		if args[i] == "--shot" and i + 1 < args.size():
			dir = args[i + 1]
	if dir == "":
		return
	call_deferred("_shoot", dir)


func _shoot(dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(dir)
	DisplayServer.window_set_size(Vector2i(2340, 1080))
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().create_timer(1.0).timeout
	_save(dir.path_join("menu.png"))
	Global.type = "pimple"
	Global.bodypart = "cheek"
	get_tree().change_scene_to_file("res://game.tscn")
	await get_tree().process_frame
	await get_tree().create_timer(1.2).timeout
	_save(dir.path_join("gameplay.png"))
	get_tree().quit(0)


func _save(path: String) -> void:
	var image := get_viewport().get_texture().get_image()
	if image == null:
		push_warning("No viewport image for %s" % path)
		return
	image.save_png(path)
