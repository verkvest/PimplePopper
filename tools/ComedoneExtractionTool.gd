extends Node2D

enum State {
	NORMAL,
	ON_BLACKHEAD
}

signal double_pressed

@onready var _sprite: Sprite2D = $tool/sprite
@onready var _sfx: AudioStreamPlayer2D = $hint_sfx

var _move: Tween

@export var pressed_timeout: float = 0.3
@export var max_down_distance: float = 20.0

var _tool_initial_position: Vector2
var _timeout: float
var _first_press: bool = false
var _protuberance
var _double_pressed: bool
var _state = State.NORMAL

var _initial_down_position: Vector2
var _space: PhysicsDirectSpaceState2D
var _ui: UI

func _ready():
	set_process(false)
	_tool_initial_position = Vector2(Global.view_size().x + 500, Global.view_size().y * 0.5)
	_sprite.position = _tool_initial_position
	_space = get_world_2d().direct_space_state
	_ui = get_tree().get_nodes_in_group("ui")[0]


func _process(delta):
	_timeout -= delta
	if _timeout <= 0:
		set_process(false)
		_first_press = false

func _input(event):
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return
	if _ui.is_inside_container(event.position):
		return
	
	if _state == State.NORMAL:
		position_tool(event)
	elif _state == State.ON_BLACKHEAD:
		remove_blackhead(event)

# In orer to remove the blackhead the player must
# touch the screen and drag the finger down an amount of
# "remove_distance" in order to apply pressure to the blackhead and remove it.
func remove_blackhead(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_initial_down_position = event.position
	elif event is InputEventScreenDrag:
#		print ("event_y: %d, down_y: %d" % [event.position.y, _initial_down_position.y])
		if event.position.y >= _initial_down_position.y:
			var distance: float = _initial_down_position.distance_to(event.position)
			var relation: float = distance / max_down_distance
			_protuberance.remove(relation)
			if relation >= 1.0:
				_state = State.NORMAL

func position_tool(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and event.index == 0:
				if not _first_press:
					_first_press = true
					_timeout = pressed_timeout
					set_process(true)
				elif _first_press and _timeout > 0:
					emit_signal("double_pressed")
					bring_tool(event.position)

func bring_tool(destiny_position: Vector2) -> void:
	set_process_input(false)
	if _move:
		_move.kill()
	_move = create_tween()
	_move.tween_property(_sprite, "position", destiny_position, 0.35)
	_move.finished.connect(_on_tool_arrived, CONNECT_ONE_SHOT)


func _on_tool_arrived() -> void:
	var collisions: Array = Query2D.point(_space, _sprite.position, 1, 1)
	if collisions.size() != 0:
		var collider = collisions[0].collider
		if collider is Blackhead:
			_sfx.play()
			_protuberance = collider
			_state = State.ON_BLACKHEAD
	set_process_input(true)

func disable() -> void:
	set_process_input(false)
	visible = false

func enable() -> void:
	set_process_input(true)
	visible = true
