extends Node2D


func _ready():
	var background = $lipoma/sheet.sprite_frames.get_frame_texture("default", 0)
	var bsize: Vector2 = background.get_size()
	var new_scale: float = Global.view_size().x / bsize.x
	scale = Vector2(new_scale, new_scale)
