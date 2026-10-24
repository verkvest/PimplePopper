extends Node2D


func _ready():
	var bsize: Vector2 = $background.texture.get_size()
	var new_x: float = Global.view_size().x / bsize.x
	scale = Vector2(new_x, new_x)
