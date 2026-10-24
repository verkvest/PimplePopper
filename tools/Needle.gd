extends Node2D
class_name Neddle

@export var needle_extraction_distance: float = 50

@onready var _sprites: AnimatedSprite2D = $tool/sprites

var _move: Tween
@onready var _hint: AudioStreamPlayer2D = $hint_sfx
@onready var _wrong: AudioStreamPlayer2D = $wrong_sfx

var _initial_tool_position: Vector2 
var _second_finger_position: Vector2
var _protuberance
var _space: PhysicsDirectSpaceState2D
var _ui

func _ready():
	_initial_tool_position = _sprites.position
	_space = get_world_2d().direct_space_state
	_ui = get_tree().get_nodes_in_group("ui")[0]

func _input(event):
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return
	if _ui.is_inside_container(event.position):
		return
	if event is InputEventScreenTouch:
		if event.index == 0:
			if event.pressed:
				bring_tool(event.position)
			else:
				hide_tool()
		elif event.index == 1:
			_second_finger_position = event.position
	elif event is InputEventScreenDrag:
		if event.index == 1 and _protuberance != null:
			_sprites.frame = _protuberance.extract()

func bring_tool(event_position: Vector2) -> void:
	_move_sprite(event_position, true)

func hide_tool() -> void:
	_move_sprite(_initial_tool_position, false)
	_protuberance = null

func _move_sprite(target: Vector2, probe: bool) -> void:
	if _move:
		_move.kill()
	_move = create_tween()
	_move.tween_property(_sprites, "position", target, 0.35)
	if probe:
		_move.finished.connect(_probe_arrival, CONNECT_ONE_SHOT)

func _probe_arrival() -> void:
	var collisions: Array = Query2D.point(_space, _sprites.position, 1, 1)
	if collisions.size() != 0:
		_hint.play()
		_protuberance = collisions[0].collider

func disable() -> void:
	set_process_input(false)
	visible = false

func enable() -> void:
	set_process_input(true)
	visible = true

