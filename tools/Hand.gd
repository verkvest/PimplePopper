extends Node2D

@onready var _hint_sfx: AudioStreamPlayer2D = $hint_sfx

var _ui
var _fingers: Dictionary = {}
var _protuberance
var space_state: PhysicsDirectSpaceState2D
var _initial_distance: float
var _explode_protuberances: Array = []
var _holding := false
var _hold_pos := Vector2.ZERO
var _hold_pressure := 0.0
var _fingers_down := 0

func _ready():
	_fingers[0] = $finger_cero
	_fingers[1] = $finger_one
	space_state = get_world_2d().direct_space_state
	_ui = get_tree().get_nodes_in_group("ui")[0]

func _process(delta: float) -> void:
	if not _holding or _fingers_down != 1 or _protuberance != null:
		return
	var hits: Array = Query2D.point(space_state, _hold_pos, 0x7FFFFFFF, 8)
	for hit in hits:
		var collider = hit.collider
		if not collider.has_method("apply_pressure"):
			continue
		if _explode_protuberances.has(collider):
			continue
		_hold_pressure += 140.0 * delta
		if collider.apply_pressure(_hold_pressure):
			_explode_protuberances.append(collider)
			_hold_pressure = 0.0
			_hint_sfx.play()
		return

func _input(event):
	if not (event is InputEventScreenTouch or event is InputEventScreenDrag):
		return
	if _ui.is_inside_container(event.position):
		return
	if event is InputEventScreenTouch:
		if event.index > 1:
			return
		if event.pressed:
			_fingers_down += 1
			var finger = _fingers[event.index]
			finger.position = event.position
			finger.draw_pointer()
			if event.index == 0:
				_holding = true
				_hold_pos = event.position
				_hold_pressure = 0.0
			if event.index == 1:
				var f0_position: Vector2 = $finger_cero.position
				var f1_position: Vector2 = $finger_one.position
				var result: Dictionary = Query2D.ray(space_state, f0_position, f1_position, _explode_protuberances)
				if not result.is_empty():
					_hint_sfx.play()
					_protuberance = result['collider']
					_initial_distance = (f0_position - f1_position).length()
		else:
			_fingers_down = maxi(_fingers_down - 1, 0)
			var finger = _fingers[event.index]
			finger.position = event.position
			finger.hide_pointer()
			if event.index == 0:
				_holding = false
				_hold_pressure = 0.0
			if event.index == 1:
				_protuberance = null
			
	elif event is InputEventScreenDrag:
		if event.index > 1:
			return
		var finger = _fingers[event.index]
		finger.position = event.position
		if event.index == 0:
			_hold_pos = event.position
		if event.index == 1:
			if _protuberance:
				var f0_position: Vector2 = _fingers[0].position
				var f1_position: Vector2 = _fingers[1].position
				var new_distance: float = (f0_position - f1_position).length()
				if new_distance < _initial_distance:
					if _protuberance.apply_pressure(_initial_distance - new_distance):
						_explode_protuberances.append(_protuberance)
						_hint_sfx.play()

func disable() -> void:
	set_process_input(false)
	set_process(false)
	visible = false

func enable() -> void:
	set_process_input(true)
	set_process(true)
	visible = true
