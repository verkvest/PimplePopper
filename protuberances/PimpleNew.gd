class_name PimpleNew extends Area2D

signal protuberance_cleaned


enum State {
	NORMAL,
	REMOVED,
	CLEAN
}

@onready var _animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@export var max_pressure: float = 300.0
@export var normal_frames: int = 1
@export var state: State = State.NORMAL

var _frame: int = 0
var _final_frame: int = 0

func _ready():
	_final_frame = _animated_sprite.sprite_frames.get_frame_count("default")


func apply_pressure(p: float) -> bool:
	print ("Pressure: ", p)
	if state == State.NORMAL:
		print ("applying pressure...")
		var frame_index: int = int((p / max_pressure) * normal_frames)
		_animated_sprite.frame = frame_index
		print("fram index: ", frame_index)
		if p > max_pressure:
			if frame_index >= normal_frames:
				state = State.REMOVED
				print ("Exploted")
				return true
	return false

func clean() -> void:
	if state == State.REMOVED:
		state = State.CLEAN
		_animated_sprite.frame = _final_frame
		emit_signal("protuberance_cleaned")
